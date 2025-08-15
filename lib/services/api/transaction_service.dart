import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:nariudyam/services/api/auth_service.dart';
import 'package:nariudyam/services/general/messenger.dart';

import '../../models/transaction.dart';

final transactionServiceProvider = Provider((ref) => TransactionService(ref));

class TransactionService {
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TransactionService(this._ref);

  CollectionReference<Transaction> _getCollection() {
    final user = _ref.read(userProvider);
    if (user == null) throw Exception('User not logged in!');
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('businesses')
        .doc(user.uid) // Assuming businessId is user.uid for now
        .collection('transactions')
        .withConverter<Transaction>(
          fromFirestore: (snap, _) => Transaction.fromMap(snap.data()!, snap.id),
          toFirestore: (transaction, _) => transaction.toMap(),
        );
  }

  Stream<List<Transaction>> streamTransactions() {
    return _getCollection().snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<void> addTransaction({
    required String productId,
    required int quantity,
    required double price,
    required double cost,
    required TransactionType transactionType,
  }) async {
    try {
      final user = _ref.read(userProvider);
      if (user == null) throw Exception('User not logged in!');

      final newTransaction = Transaction(
        id: '', // Firestore will generate this
        productId: productId,
        quantity: quantity,
        price: price,
        cost: cost,
        transactionType: transactionType,
        timestamp: DateTime.now(),
        businessId: user.uid,
      );
      await _getCollection().add(newTransaction);
      _ref.read(messengerProvider).showSuccess('Transaction added successfully!');
    } catch (e) {
      _ref.read(messengerProvider).showError('Failed to add transaction: ${e.toString()}');
    }
  }
}