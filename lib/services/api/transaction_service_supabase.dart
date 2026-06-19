import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../components/payment_selection_bottom_sheet.dart';
import '../../models/transaction.dart';
import '../../providers/shared_providers.dart';
import '../../services/general/messenger.dart';
import '../interfaces/i_transaction_service.dart';

class TransactionServiceSupabase implements ITransactionService {
  final Ref _ref;
  final SupabaseClient _supabase = Supabase.instance.client;

  TransactionServiceSupabase(this._ref);

  String _requireUserId() {
    final user = _ref.read(userProvider);
    if (user == null) {
      throw Exception('User not logged in!');
    }
    return user.uid;
  }

  @override
  Stream<List<Transaction>> streamTransactions() {
    final user = _ref.read(userProvider);
    if (user == null) return Stream.value(<Transaction>[]);

    return _supabase
        .from('transactions')
        .stream(primaryKey: ['id']).map((rows) {
      final transactions = rows
          .where((row) => row['user_id'] == user.uid)
          .map((row) => Transaction.fromMap(
                row,
                row['id'].toString(),
              ))
          .toList(growable: true);

      transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return transactions;
    });
  }

  @override
  Stream<List<Transaction>> streamTransactionsByCustomerId(String customerId) {
    final user = _ref.read(userProvider);
    if (user == null) return Stream.value(<Transaction>[]);

    return _supabase
        .from('transactions')
        .stream(primaryKey: ['id']).map((rows) {
      final transactions = rows
          .where((row) =>
              row['user_id'] == user.uid &&
              row['customer_id']?.toString() == customerId)
          .map((row) => Transaction.fromMap(
                row,
                row['id'].toString(),
              ))
          .toList(growable: true);

      transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return transactions;
    });
  }

  @override
  Future<void> addTransaction({
    String? transactionId,
    required String productId,
    String? itemName,
    required int quantity,
    required double price,
    required double cost,
    required TransactionType transactionType,
    required PaymentMethod paymentMethod,
    String? customerId,
    double? rating,
  }) async {
    try {
      final uid = _requireUserId();

      final payload = <String, dynamic>{
        if (transactionId != null) 'transaction_id': transactionId,
        'user_id': uid,
        'business_id': uid,
        'product_id': productId,
        'item_name': itemName,
        'quantity': quantity,
        'price': price,
        'cost': cost,
        'transaction_type': transactionType.toString().split('.').last,
        'payment_method': paymentMethod.toString().split('.').last,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'customer_id': customerId,
        'rating': rating,
      };

      try {
        await _supabase.from('transactions').insert(payload);
      } on PostgrestException catch (e) {
        final combined =
            '${e.message} ${e.details ?? ''} ${e.hint ?? ''}'.toLowerCase();

        final missingTransactionIdColumn = combined
                .contains('transaction_id') &&
            (combined.contains('column') || combined.contains('schema cache'));

        if (missingTransactionIdColumn) {
          throw Exception(
            'Supabase DB is missing `public.transactions.transaction_id`. '
            'Run the migration to add this column, then retry.',
          );
        }

        rethrow;
      }

      _ref
          .read(messengerProvider)
          .showSuccess('Transaction added successfully!');
    } catch (e) {
      _ref
          .read(messengerProvider)
          .showError('Failed to add transaction: ${e.toString()}');

      // Surface the failure to callers as well.
      rethrow;
    }
  }

  @override
  Future<void> updateTransactionRating({
    required String transactionId,
    required double rating,
  }) async {
    try {
      await _supabase
          .from('transactions')
          .update({'rating': rating})
          .eq('transaction_id', transactionId);
    } catch (e) {
      _ref
          .read(messengerProvider)
          .showError('Failed to save feedback: ${e.toString()}');
      rethrow;
    }
  }
}
