import '../../components/payment_selection_bottom_sheet.dart';
import '../../models/transaction.dart';

abstract class ITransactionService {
  Stream<List<Transaction>> streamTransactions();

  Stream<List<Transaction>> streamTransactionsByCustomerId(String customerId);

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
  });

  Future<void> updateTransactionRating({
    required String transactionId,
    required double rating,
  });
}
