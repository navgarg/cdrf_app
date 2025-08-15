import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType {
  sale,
  purchase,
  adjustment,
}

class Transaction {
  final String id;
  final String productId;
  final int quantity;
  final double price;
  final double cost;
  final TransactionType transactionType;
  final DateTime timestamp;
  final String businessId;

  Transaction({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.cost,
    required this.transactionType,
    required this.timestamp,
    required this.businessId,
  });

  factory Transaction.fromMap(Map<String, dynamic> data, String id) {
    return Transaction(
      id: id,
      productId: data['productId'] ?? '',
      quantity: data['quantity'] ?? 0,
      price: data['price'] ?? 0.0,
      cost: data['cost'] ?? 0.0,
      transactionType: TransactionType.values.firstWhere(
          (e) => e.toString() == 'TransactionType.${data['transactionType']}',
          orElse: () => TransactionType.sale),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      businessId: data['businessId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'quantity': quantity,
      'price': price,
      'cost': cost,
      'transactionType': transactionType.toString().split('.').last,
      'timestamp': Timestamp.fromDate(timestamp),
      'businessId': businessId,
    };
  }
}