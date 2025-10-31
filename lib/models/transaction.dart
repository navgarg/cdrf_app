import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nariudyam/components/payment_selection_bottom_sheet.dart';

enum TransactionType {
  sale,
  purchase,
  adjustment,
}

class Transaction {
  final String id;
  final String productId;
  final String? itemName; // denormalized name for quick display
  final int quantity;
  final double price;
  final double cost;
  final TransactionType transactionType;
  final DateTime timestamp;
  final String businessId;
  final PaymentMethod paymentMethod;

  Transaction({
    required this.id,
    required this.productId,
    this.itemName,
    required this.quantity,
    required this.price,
    required this.cost,
    required this.transactionType,
    required this.timestamp,
    required this.businessId,
    required this.paymentMethod,
  });

  factory Transaction.fromMap(Map<String, dynamic> data, String id) {
    return Transaction(
      id: id,
      productId: data['productId'] ?? '',
      itemName: data['itemName'],
      quantity: data['quantity'] ?? 0,
      price: data['price'] ?? 0.0,
      cost: data['cost'] ?? 0.0,
      transactionType: TransactionType.values.firstWhere(
          (e) => e.toString() == 'TransactionType.${data['transactionType']}',
          orElse: () => TransactionType.sale),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      businessId: data['businessId'] ?? '',
      paymentMethod: PaymentMethod.values.firstWhere(
          (e) => e.toString() == 'PaymentMethod.${data['paymentMethod']}',
          orElse: () => PaymentMethod.cash),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      if (itemName != null) 'itemName': itemName,
      'quantity': quantity,
      'price': price,
      'cost': cost,
      'transactionType': transactionType.toString().split('.').last,
      'timestamp': Timestamp.fromDate(timestamp),
      'businessId': businessId,
      'paymentMethod': paymentMethod.toString().split('.').last,
    };
  }
}
