import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nariudyam/components/payment_selection_bottom_sheet.dart';
import 'package:collection/collection.dart';

enum TransactionType { sale, purchase }

class Transaction {
  final String id;
  final String productId;
  final String? itemName;
  final int quantity;
  final double price;
  final double cost;
  final TransactionType transactionType;
  final DateTime timestamp;
  final String businessId;
  final PaymentMethod paymentMethod;
  final String? customerId;

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
    this.customerId,
  });

  factory Transaction.fromMap(Map<String, dynamic> data, String id) {
    return Transaction(
      id: id,
      productId: data['productId'] as String? ?? 'unknown',
      itemName: data['itemName'] as String?,
      quantity: (data['quantity'] as int?) ?? 0,
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      cost: (data['cost'] as num?)?.toDouble() ?? 0.0,
      transactionType: TransactionType.values.firstWhereOrNull((e) =>
              e.toString() == 'TransactionType.${data['transactionType'] as String?}') ??
          TransactionType.sale,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      businessId: data['businessId'] as String? ?? 'unknown',
      paymentMethod: PaymentMethod.values.firstWhereOrNull((e) =>
              e.toString() == 'PaymentMethod.${data['paymentMethod'] as String?}') ??
          PaymentMethod.cash,
      customerId: data['customerId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'itemName': itemName,
      'quantity': quantity,
      'price': price,
      'cost': cost,
      'transactionType': transactionType.toString().split('.').last,
      'timestamp': timestamp,
      'businessId': businessId,
      'paymentMethod': paymentMethod.toString().split('.').last,
      'customerId': customerId,
    };
  }
}
