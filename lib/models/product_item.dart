import 'package:cloud_firestore/cloud_firestore.dart';

class ProductItem {
  final String id;
  final String name;
  final String? description;
  final double price;
  final double cost;
  final int stockQuantity;
  final int reorderThreshold;
  final String unit;
  final DateTime? lastPurchasedDate;
  final DateTime? lastSoldDate;
  final String? location;
  final String? imageUrl;

  ProductItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.cost,
    required this.stockQuantity,
    required this.reorderThreshold,
    required this.unit,
    this.lastPurchasedDate,
    this.lastSoldDate,
    this.location,
    this.imageUrl,
  });

  factory ProductItem.fromMap(Map<String, dynamic> data, String id) {
    DateTime? parseDateTimeNullable(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is Timestamp) return value.toDate();
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {
          return null;
        }
      }
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      return null;
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

    return ProductItem(
      id: id,
      name: data['name'] ?? '',
      description: data['description'],
      price: parseDouble(data['price']),
      cost: parseDouble(data['cost']),
      stockQuantity: parseInt(data['stockQuantity'] ?? data['stock_quantity']),
      reorderThreshold:
          parseInt(data['reorderThreshold'] ?? data['reorder_threshold']),
      unit: data['unit'] ?? 'Packs',
      lastPurchasedDate: parseDateTimeNullable(
          data['lastPurchasedDate'] ?? data['last_purchased_date']),
      lastSoldDate:
          parseDateTimeNullable(data['lastSoldDate'] ?? data['last_sold_date']),
      location: data['location'],
      imageUrl: data['imageUrl'] ?? data['image_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'cost': cost,
      'stockQuantity': stockQuantity,
      'reorderThreshold': reorderThreshold,
      'unit': unit,
      'lastPurchasedDate': lastPurchasedDate,
      'lastSoldDate': lastSoldDate,
      'location': location,
      'imageUrl': imageUrl,
    };
  }
}
