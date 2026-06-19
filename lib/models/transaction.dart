import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nariudyam/components/payment_selection_bottom_sheet.dart';
import 'package:collection/collection.dart';

enum TransactionType { sale, purchase }

class Transaction {
  final String id;
  final String? transactionId;
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
  final double? rating;

  Transaction({
    required this.id,
    this.transactionId,
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
    this.rating,
  });

  factory Transaction.fromMap(Map<String, dynamic> data, String id) {
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value.toLocal();
      if (value is Timestamp) return value.toDate().toLocal();
      if (value is String) {
        try {
          return DateTime.parse(value).toLocal();
        } catch (_) {
          return DateTime.now();
        }
      }
      if (value is int) {
        // Assume millisecondsSinceEpoch
        return DateTime.fromMillisecondsSinceEpoch(value).toLocal();
      }
      return DateTime.now();
    }

    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return Transaction(
      id: id,
      transactionId: data['transactionId'] ?? data['transaction_id'],
      productId: (data['productId'] as String?) ??
          (data['product_id'] as String?) ??
          'unknown',
      itemName: (data['itemName'] as String?) ?? (data['item_name'] as String?),
      quantity: parseInt(data['quantity']),
      price: parseDouble(data['price']),
      cost: parseDouble(data['cost']),
      transactionType: TransactionType.values.firstWhereOrNull((e) =>
              e.toString() ==
              'TransactionType.${(data['transactionType'] as String?) ?? (data['transaction_type'] as String?)}') ??
          TransactionType.sale,
      timestamp: parseDateTime(data['timestamp']),
      businessId: (data['businessId'] as String?) ??
          (data['business_id'] as String?) ??
          'unknown',
      paymentMethod: PaymentMethod.values.firstWhereOrNull((e) =>
              e.toString() ==
              'PaymentMethod.${(data['paymentMethod'] as String?) ?? (data['payment_method'] as String?)}') ??
          PaymentMethod.cash,
      customerId:
          (data['customerId'] as String?) ?? (data['customer_id'] as String?),
      rating: (data['rating'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'transaction_id': transactionId,
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
      'rating': rating,
    };
  }
}
