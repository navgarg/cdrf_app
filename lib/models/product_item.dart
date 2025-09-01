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
  });

  factory ProductItem.fromMap(Map<String, dynamic> data, String id) {
    return ProductItem(
      id: id,
      name: data['name'] ?? '',
      description: data['description'],
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      cost: (data['cost'] as num?)?.toDouble() ?? 0.0,
      stockQuantity: data['stockQuantity'] ?? 0,
      reorderThreshold: data['reorderThreshold'] ?? 0,
      unit: data['unit'] ?? 'Packs',
      lastPurchasedDate: (data['lastPurchasedDate'] as Timestamp?)?.toDate(),
      lastSoldDate: (data['lastSoldDate'] as Timestamp?)?.toDate(),
      location: data['location'],
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
    };
  }
}
