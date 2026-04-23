import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/favourite_customer.dart';
import '../../providers/shared_providers.dart';
import '../../services/general/messenger.dart';
import '../interfaces/i_favourite_customer_service.dart';
import '../interfaces/i_transaction_service.dart';

class FavouriteCustomerServiceSupabase implements IFavouriteCustomerService {
  final Ref _ref;
  final ITransactionService _transactionService;
  final SupabaseClient _supabase = Supabase.instance.client;

  FavouriteCustomerServiceSupabase(this._ref, this._transactionService);

  String _requireUserId() {
    final user = _ref.read(userProvider);
    if (user == null) throw Exception('User not logged in!');
    return user.uid;
  }

  @override
  Stream<List<FavouriteCustomer>> streamFavouriteCustomers() {
    final user = _ref.read(userProvider);
    if (user == null) return Stream.value(<FavouriteCustomer>[]);

    return _supabase
        .from('favourite_customers')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.uid)
        .order('name', ascending: true)
        .asyncMap((rows) async {
          final customers = rows
              .map(
                  (row) => FavouriteCustomer.fromMap(row, row['id'].toString()))
              .toList(growable: false);

          // Match Firebase behavior: compute metrics based on a snapshot of transactions.
          final transactions =
              await _transactionService.streamTransactions().first;

          return customers.map((customer) {
            final customerTransactions = transactions
                .where((t) => t.customerId == customer.id)
                .toList(growable: false);

            if (customerTransactions.isEmpty) {
              return customer.copyWith(
                lastPurchaseDate: null,
                avgMonthlySpend: 0.0,
                loyaltyStatus: 'New',
              );
            }

            final lastPurchaseDate = customerTransactions
                .map((t) => t.timestamp)
                .reduce((a, b) => a.isAfter(b) ? a : b);

            final now = DateTime.now();
            final sixMonthsAgo = DateTime(now.year, now.month - 6, now.day);
            final recent = customerTransactions
                .where((t) => t.timestamp.isAfter(sixMonthsAgo))
                .toList(growable: false);

            double totalSpend = 0.0;
            for (final t in recent) {
              totalSpend += (t.price * t.quantity);
            }
            final avgMonthlySpend = recent.isEmpty ? 0.0 : totalSpend / 6;

            String loyaltyStatus;
            if (totalSpend > 1000) {
              loyaltyStatus = 'Gold';
            } else if (totalSpend > 500) {
              loyaltyStatus = 'Silver';
            } else {
              loyaltyStatus = 'Bronze';
            }

            return customer.copyWith(
              lastPurchaseDate: lastPurchaseDate,
              avgMonthlySpend: avgMonthlySpend,
              loyaltyStatus: loyaltyStatus,
            );
          }).toList(growable: false);
        });
  }

  @override
  Future<List<FavouriteCustomer>> getFavouriteCustomers() async {
    final uid = _requireUserId();
    final rows = await _supabase
        .from('favourite_customers')
        .select()
        .eq('user_id', uid)
        .order('name', ascending: true);

    return (rows as List).map((row) {
      final map = row as Map<String, dynamic>;
      return FavouriteCustomer.fromMap(map, map['id'].toString());
    }).toList(growable: false);
  }

  @override
  Future<bool> addFavouriteCustomer(
    String name, {
    String? phoneNumber,
    double? creditOutstanding,
  }) async {
    if (name.isEmpty) return false;
    try {
      final uid = _requireUserId();

      final customer = FavouriteCustomer(
        id: '',
        name: name,
        phoneNumber: phoneNumber,
        creditOutstanding: creditOutstanding,
      );

      await _supabase
          .from('favourite_customers')
          .insert(customer.toSupabaseMap(userId: uid, businessId: uid));

      _ref.read(messengerProvider).showSuccess('"$name" added to favourites.');
      return true;
    } catch (e) {
      _ref.read(messengerProvider).showError('Failed to add customer: $e');
      return false;
    }
  }

  @override
  Future<bool> updateFavouriteCustomer(
    String customerId, {
    String? name,
    String? phoneNumber,
    double? creditOutstanding,
    DateTime? lastPurchaseDate,
    double? avgMonthlySpend,
    String? loyaltyStatus,
  }) async {
    try {
      final uid = _requireUserId();
      final updates = <String, dynamic>{};

      if (name != null) updates['name'] = name;
      if (phoneNumber != null) updates['phone_number'] = phoneNumber;
      if (creditOutstanding != null)
        updates['credit_outstanding'] = creditOutstanding;
      if (lastPurchaseDate != null) {
        updates['last_purchase_date'] = lastPurchaseDate.toIso8601String();
      }
      if (avgMonthlySpend != null)
        updates['avg_monthly_spend'] = avgMonthlySpend;
      if (loyaltyStatus != null) updates['loyalty_status'] = loyaltyStatus;

      if (updates.isNotEmpty) {
        await _supabase
            .from('favourite_customers')
            .update(updates)
            .eq('user_id', uid)
            .eq('id', customerId);

        _ref
            .read(messengerProvider)
            .showSuccess('Customer updated successfully.');
      }
      return true;
    } catch (e) {
      _ref.read(messengerProvider).showError('Failed to update customer: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteFavouriteCustomer(String customerId) async {
    try {
      final uid = _requireUserId();
      await _supabase
          .from('favourite_customers')
          .delete()
          .eq('user_id', uid)
          .eq('id', customerId);

      _ref
          .read(messengerProvider)
          .showSuccess('Customer removed from favourites.');
      return true;
    } catch (e) {
      _ref.read(messengerProvider).showError('Failed to remove customer: $e');
      return false;
    }
  }
}
