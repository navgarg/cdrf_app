import 'package:cloud_firestore/cloud_firestore.dart';

class FavouriteCustomer {
  final String id;
  final String name;

  FavouriteCustomer({required this.id, required this.name});

  factory FavouriteCustomer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FavouriteCustomer(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Favourite',
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name};
  }
}