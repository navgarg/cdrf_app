import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nariudyam/models/product_item.dart';
import 'package:nariudyam/services/api/auth_service.dart';
import 'package:nariudyam/services/general/messenger.dart';
import 'package:flutter/foundation.dart';

final inventoryServiceProvider = Provider((ref) => InventoryService(ref));

final productItemProvider =
    StreamProvider.family<ProductItem, String>((ref, itemId) {
  final inventoryService = ref.watch(inventoryServiceProvider);
  return inventoryService.streamProductItem(itemId);
});

class InventoryService {
  final Ref _ref;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _migrationAttempted = false;
  static bool _debugPrinted = false;

  InventoryService(this._ref);

  bool _isServiceBusiness() {
    final user = _ref.read(userProvider);
    final raw = user?.businessDomain ?? '';
    final normalized = raw.trim().toLowerCase();
    // Only current supported service domain string. Add more variants if needed.
    return normalized == 'beauty parlor';
  }

  // Product items now ALWAYS stored under 'inventory' (unified) for all business types.
  CollectionReference<ProductItem> _getInventoryProductItemsCollection() {
    final user = _ref.read(userProvider);
    if (user == null) throw Exception('User not logged in!');
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('businesses')
        .doc(user.uid)
        .collection('inventory')
        .withConverter<ProductItem>(
          fromFirestore: (snap, _) =>
              ProductItem.fromMap(snap.data()!, snap.id),
          toFirestore: (item, _) => item.toMap(),
        );
  }

  // Migration for non-service businesses: move legacy 'products' -> unified 'inventory' if inventory empty.
  Future<void> _migrateLegacyNonServiceProductsIfNeeded() async {
    if (_isServiceBusiness() || _migrationAttempted) return;
    _migrationAttempted = true;
    final invSnap = await _getInventoryProductItemsCollection().get();
    if (invSnap.docs.isNotEmpty) return;
    final user = _ref.read(userProvider);
    if (user == null) return;
    final legacyProducts = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('businesses')
        .doc(user.uid)
        .collection('products')
        .withConverter<ProductItem>(
          fromFirestore: (snap, _) =>
              ProductItem.fromMap(snap.data()!, snap.id),
          toFirestore: (item, _) => item.toMap(),
        )
        .get();
    if (legacyProducts.docs.isEmpty) return;
    for (final doc in legacyProducts.docs) {
      await _getInventoryProductItemsCollection().doc(doc.id).set(doc.data());
    }
  }

  // Streams
  Stream<List<ProductItem>> streamInventoryProductItems() {
    if (!_debugPrinted) {
      _debugPrinted = true;
      final user = _ref.read(userProvider);
      final isService = _isServiceBusiness();
      // ignore: avoid_print
      final raw = user?.businessDomain;
      final normalized = (raw ?? '').trim().toLowerCase();
      debugPrint(
          '[InventoryService] isService=$isService rawDomain=$raw normalizedDomain=$normalized');
    }
    // Only migrate legacy non-service products here. Service item migration moved to services_service.
    if (!_isServiceBusiness()) {
      _migrateLegacyNonServiceProductsIfNeeded();
    }
    return _getInventoryProductItemsCollection()
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) => d.data()).toList());
  }

  Stream<ProductItem> streamProductItem(String itemId) {
    return _getInventoryProductItemsCollection()
        .doc(itemId)
        .snapshots()
        .map((snapshot) => snapshot.data()!);
  }

  Future<bool> addProductItem({
    required String name,
    String? description,
    required double price,
    required double cost,
    required int stockQuantity,
    required int reorderThreshold,
    required String unit,
  }) async {
    try {
      final newItem = ProductItem(
        id: '', // Firestore will generate this
        name: name,
        description: description,
        price: price,
        cost: cost,
        stockQuantity: stockQuantity,
        reorderThreshold: reorderThreshold,
        unit: unit,
      );
      await _getInventoryProductItemsCollection().add(newItem);
      _ref.read(messengerProvider).showSuccess('Product added successfully!');
      return true;
    } catch (e) {
      _ref
          .read(messengerProvider)
          .showError('Failed to add product: ${e.toString()}');
      return false;
    }
  }

  Future<bool> updateProductItem(String id, {int? stockQuantity}) async {
    try {
      final updates = <String, dynamic>{};
      if (stockQuantity != null) {
        updates['stockQuantity'] = stockQuantity;
      }

      if (updates.isNotEmpty) {
        await _getInventoryProductItemsCollection().doc(id).update(updates);
        _ref
            .read(messengerProvider)
            .showSuccess('Product updated successfully!');
        return true;
      }
      return false;
    } catch (e) {
      _ref
          .read(messengerProvider)
          .showError('Failed to update product: ${e.toString()}');
      return false;
    }
  }
}
