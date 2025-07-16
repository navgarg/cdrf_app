import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/favourite_customer.dart';
import '../general/messenger.dart';
import 'auth_service.dart';

final favouriteCustomerServiceProvider = Provider((ref) => FavouriteCustomerService(ref));

final favouriteCustomersProvider = FutureProvider<List<FavouriteCustomer>>((ref) {
  return ref.watch(favouriteCustomerServiceProvider).getFavouriteCustomers();
});

class FavouriteCustomerService {
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FavouriteCustomerService(this._ref);

  // Helper to get the correct sub-collection
  CollectionReference<FavouriteCustomer> _getCollection() {
    final user = _ref.read(userProvider);
    if (user == null) throw Exception('User not logged in!');
    return _firestore
        .collection('users').doc(user.uid).collection('favourite_customers')
        .withConverter<FavouriteCustomer>(
      fromFirestore: (snap, _) => FavouriteCustomer.fromFirestore(snap),
      toFirestore: (fav, _) => fav.toMap(),
    );
  }

  Future<List<FavouriteCustomer>> getFavouriteCustomers() async {
    final snapshot = await _getCollection().get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<bool> addFavouriteCustomer(String name) async {
    if (name.isEmpty) return false;
    try {
      final newCustomer = FavouriteCustomer(id: '', name: name);
      await _getCollection().add(newCustomer);
      _ref.read(messengerProvider).showSuccess('"$name" added to favourites.');
      return true;
    } catch (e) {
      _ref.read(messengerProvider).showError('Failed to add customer: $e');
      return false;
    }
  }

  Future<bool> deleteFavouriteCustomer(String customerId) async {
    try {
      await _getCollection().doc(customerId).delete();
      _ref.read(messengerProvider).showSuccess('Customer removed from favourites.');
      return true;
    } catch (e) {
      _ref.read(messengerProvider).showError('Failed to remove customer: $e');
      return false;
    }
  }

}