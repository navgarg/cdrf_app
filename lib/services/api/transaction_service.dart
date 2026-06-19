import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:nariudyam/services/api/auth_service.dart';
import 'package:nariudyam/services/general/messenger.dart';
import 'package:nariudyam/components/payment_selection_bottom_sheet.dart';
import 'package:flutter/foundation.dart';

import '../../models/transaction.dart';

final transactionServiceProvider = Provider((ref) => TransactionService(ref));

final allTransactionsStreamProvider = StreamProvider<List<Transaction>>((ref) {
  final user = ref.watch(userProvider);
  if (user == null) {
    return Stream.value([]); // Return an empty stream if no user is logged in
  }
  final transactionService = ref.watch(transactionServiceProvider);
  return transactionService.streamTransactions();
});

class TransactionService {
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TransactionService(this._ref);

  CollectionReference<Transaction> _getCollection() {
    final user = _ref.read(userProvider);
    if (user == null) {
      debugPrint(
          'TransactionService: User not logged in when trying to get collection.');
      throw Exception('User not logged in!');
    }
    final collectionPath =
        'users/${user.uid}/businesses/${user.uid}/transactions';
    debugPrint('TransactionService: Fetching from path: $collectionPath');

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('businesses')
        .doc(user.uid) // Assuming businessId is user.uid for now
        .collection('transactions')
        .withConverter<Transaction>(
          fromFirestore: (snap, _) {
            final data = snap.data();
            if (data == null) {
              // Return a default or empty Transaction if data is null
              return Transaction(
                id: snap.id,
                productId: 'unknown',
                quantity: 0,
                price: 0.0,
                cost: 0.0,
                transactionType: TransactionType.sale,
                timestamp: DateTime.now(),
                businessId: 'unknown',
                paymentMethod: PaymentMethod.cash,
              );
            }
            return Transaction.fromMap(data, snap.id);
          },
          toFirestore: (transaction, _) => transaction.toMap(),
        );
  }

  Stream<List<Transaction>> streamTransactions() {
    return _getCollection().snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Stream<List<Transaction>> streamTransactionsByCustomerId(String customerId) {
    return _getCollection()
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

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
      final user = _ref.read(userProvider);
      if (user == null) throw Exception('User not logged in!');

      final newTransaction = Transaction(
        id: '', // Firestore will generate this
        transactionId: transactionId,
        productId: productId,
        itemName: itemName,
        quantity: quantity,
        price: price,
        cost: cost,
        transactionType: transactionType,
        timestamp: DateTime.now(),
        businessId: user.uid,
        paymentMethod: paymentMethod,
        customerId: customerId,
        rating: rating,
      );
      await _getCollection().add(newTransaction);
      _ref
          .read(messengerProvider)
          .showSuccess('Transaction added successfully!');
    } catch (e) {
      _ref
          .read(messengerProvider)
          .showError('Failed to add transaction: ${e.toString()}');
    }
  }

  @override
  Future<void> updateTransactionRating({
    required String transactionId,
    required double rating,
  }) async {
    try {
      final snapshot = await _getCollection()
          .where('transaction_id', isEqualTo: transactionId)
          .get();

      if (snapshot.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'rating': rating});
      }
      await batch.commit();
    } catch (e) {
      _ref
          .read(messengerProvider)
          .showError('Failed to save feedback: ${e.toString()}');
      rethrow;
    }
  }
}
