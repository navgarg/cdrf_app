import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryItem {
  final String id;
  final String name;
  final String? description;
  final double price;
  final double cost;
  final int stockQuantity;
  final int reorderThreshold;
  final String unit;
  final DateTime? lastPurchasedDate;
  final DateTime? lastUsedDate;
  final String? location;

  InventoryItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.cost,
    required this.stockQuantity,
    required this.reorderThreshold,
    required this.unit,
    this.lastPurchasedDate,
    this.lastUsedDate,
    this.location,
  });

  // Factory constructor for creating an InventoryItem from a map (e.g., Firestore document)
  factory InventoryItem.fromMap(Map<String, dynamic> data, String id) {
    return InventoryItem(
      id: id,
      name: data['name'] ?? '',
      description: data['description'],
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      cost: (data['cost'] as num?)?.toDouble() ?? 0.0,
      stockQuantity: data['stockQuantity'] ?? 0,
      reorderThreshold: data['reorderThreshold'] ?? 0,
      unit: data['unit'] ?? 'Packs',
      lastPurchasedDate: (data['lastPurchasedDate'] as Timestamp?)?.toDate(),
      lastUsedDate: (data['lastUsedDate'] as Timestamp?)?.toDate(),
      location: data['location'],
    );
  }

  // Method for converting an InventoryItem to a map (e.g., for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'cost': cost,
      'stockQuantity': stockQuantity,
      'reorderThreshold': reorderThreshold,
      'unit': unit,
      'lastPurchasedDate': lastPurchasedDate != null ? Timestamp.fromDate(lastPurchasedDate!) : null,
      'lastUsedDate': lastUsedDate != null ? Timestamp.fromDate(lastUsedDate!) : null,
      'location': location,
    };
  }
}