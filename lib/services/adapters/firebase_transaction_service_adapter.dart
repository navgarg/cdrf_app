import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../interfaces/i_transaction_service.dart';
import '../api/transaction_service.dart' as firebase;
import '../../components/payment_selection_bottom_sheet.dart';
import '../../models/transaction.dart';

class FirebaseTransactionServiceAdapter implements ITransactionService {
  final firebase.TransactionService _service;

  FirebaseTransactionServiceAdapter(Ref ref)
      : _service = firebase.TransactionService(ref);

  @override
  Stream<List<Transaction>> streamTransactions() =>
      _service.streamTransactions();

  @override
  Stream<List<Transaction>> streamTransactionsByCustomerId(String customerId) =>
      _service.streamTransactionsByCustomerId(customerId);

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
  }) {
    return _service.addTransaction(
      transactionId: transactionId,
      productId: productId,
      itemName: itemName,
      quantity: quantity,
      price: price,
      cost: cost,
      transactionType: transactionType,
      paymentMethod: paymentMethod,
      customerId: customerId,
    );
  }
}
