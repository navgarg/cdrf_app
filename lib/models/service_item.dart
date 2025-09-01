import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceItem {
  final String id;
  final String name;
  final String? description;
  final double price;
  final int duration; // in minutes

  ServiceItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.duration,
  });

  factory ServiceItem.fromMap(Map<String, dynamic> data, String id) {
    return ServiceItem(
      id: id,
      name: data['name'] ?? '',
      description: data['description'],
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      duration: data['duration'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
    };
  }
}
