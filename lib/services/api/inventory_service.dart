import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nariudyam/models/inventory_item.dart';
import 'package:nariudyam/services/api/auth_service.dart';
import 'package:nariudyam/services/general/messenger.dart';

final inventoryServiceProvider = Provider((ref) => InventoryService(ref));

final inventoryItemProvider =
StreamProvider.family<InventoryItem, String>((ref, itemId) {
  final inventoryService = ref.watch(inventoryServiceProvider);
  return inventoryService.streamInventoryItem(itemId);
});

class InventoryService {
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  InventoryService(this._ref);

  CollectionReference<InventoryItem> _getCollection() {
    final user = _ref.read(userProvider);
    if (user == null) throw Exception('User not logged in!');
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('businesses')
        .doc(user.uid) // Assuming businessId is user.uid for now
        .collection('products')
        .withConverter<InventoryItem>(
          fromFirestore: (snap, _) => InventoryItem.fromMap(snap.data()!, snap.id),
          toFirestore: (item, _) => item.toMap(),
        );
  }

  Stream<List<InventoryItem>> streamInventoryItems() {
    return _getCollection().snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Stream<InventoryItem> streamInventoryItem(String itemId) {
    return _getCollection()
        .doc(itemId)
        .snapshots()
        .map((snapshot) => snapshot.data()!); // The .withConverter handles the mapping
  }

  Future<bool> addInventoryItem({
    required String name,
    String? description,
    required double price,
    required double cost,
    required int stockQuantity,
    required int reorderThreshold,
    required String unit,
  }) async {
    try {
      final newItem = InventoryItem(
        id: '', // Firestore will generate this
        name: name,
        description: description,
        price: price,
        cost: cost,
        stockQuantity: stockQuantity,
        reorderThreshold: reorderThreshold,
        unit: unit,
      );
      await _getCollection().add(newItem);
      _ref.read(messengerProvider).showSuccess('Inventory item added successfully!');
      return true;
    } catch (e) {
      _ref.read(messengerProvider).showError('Failed to add inventory item: ${e.toString()}');
      return false;
    }
  }

  Future<bool> updateInventoryItem(String id, {int? stockQuantity}) async {
    try {
      final updates = <String, dynamic>{};
      if (stockQuantity != null) {
        updates['stockQuantity'] = stockQuantity;
      }

      if (updates.isNotEmpty) {
        await _getCollection().doc(id).update(updates);
        _ref.read(messengerProvider).showSuccess('Inventory item updated successfully!');
        return true;
      }
      return false;
    } catch (e) {
      _ref.read(messengerProvider).showError('Failed to update inventory item: ${e.toString()}');
      return false;
    }
  }
}