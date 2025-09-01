import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nariudyam/models/product_item.dart';
import 'package:nariudyam/models/service_item.dart';
import 'package:nariudyam/services/api/auth_service.dart';
import 'package:nariudyam/services/general/messenger.dart';

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

  InventoryService(this._ref);

  bool _isServiceBusiness() {
    final user = _ref.read(userProvider);
    return user?.businessDomain == 'Beauty Parlor';
  }

  // Product items (physical) collection path depends on business type:
  // Service business: stored under 'inventory'
  // Non-service business: stored under 'products'
  CollectionReference<ProductItem> _getInventoryProductItemsCollection() {
    final user = _ref.read(userProvider);
    if (user == null) throw Exception('User not logged in!');
    final collectionName = _isServiceBusiness() ? 'inventory' : 'products';
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('businesses')
        .doc(user.uid)
        .collection(collectionName)
        .withConverter<ProductItem>(
          fromFirestore: (snap, _) =>
              ProductItem.fromMap(snap.data()!, snap.id),
          toFirestore: (item, _) => item.toMap(),
        );
  }

  // Service items for service business only (stored now in 'products').
  // For backward compatibility we migrate old 'services' collection into 'products' the first time we detect empty.
  CollectionReference<ServiceItem> _getServiceItemsCollection() {
    final user = _ref.read(userProvider);
    if (user == null) throw Exception('User not logged in!');
    final collectionName =
        'products'; // reserved for ServiceItem in service businesses
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('businesses')
        .doc(user.uid)
        .collection(collectionName)
        .withConverter<ServiceItem>(
          fromFirestore: (snap, _) =>
              ServiceItem.fromMap(snap.data()!, snap.id),
          toFirestore: (item, _) => item.toMap(),
        );
  }

  // Legacy services collection (old path) used only for migration.
  CollectionReference<ServiceItem> _getLegacyServicesCollection() {
    final user = _ref.read(userProvider);
    if (user == null) throw Exception('User not logged in!');
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('businesses')
        .doc(user.uid)
        .collection('services')
        .withConverter<ServiceItem>(
          fromFirestore: (snap, _) =>
              ServiceItem.fromMap(snap.data()!, snap.id),
          toFirestore: (item, _) => item.toMap(),
        );
  }

  Future<void> _migrateLegacyServicesIfNeeded() async {
    if (!_isServiceBusiness() || _migrationAttempted) return;
    _migrationAttempted = true;
    final target = await _getServiceItemsCollection().get();
    if (target.docs.isNotEmpty) return; // already have new data
    final legacy = await _getLegacyServicesCollection().get();
    if (legacy.docs.isEmpty) return;
    for (final doc in legacy.docs) {
      await _getServiceItemsCollection().doc(doc.id).set(doc.data());
    }
  }

  // Streams
  Stream<List<ProductItem>> streamInventoryProductItems() {
    return _getInventoryProductItemsCollection()
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) => d.data()).toList());
  }

  Stream<List<ServiceItem>> streamServiceItems() async* {
    if (_isServiceBusiness()) {
      await _migrateLegacyServicesIfNeeded();
      yield* _getServiceItemsCollection()
          .snapshots()
          .map((s) => s.docs.map((d) => d.data()).toList());
    } else {
      // Non-service businesses don't expose services; yield empty list.
      yield <ServiceItem>[];
    }
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

  Future<bool> addServiceItem({
    required String name,
    String? description,
    required double price,
    required int duration,
  }) async {
    try {
      final newService = ServiceItem(
        id: '', // Firestore will generate this
        name: name,
        description: description,
        price: price,
        duration: duration,
      );
      if (!_isServiceBusiness()) {
        throw Exception('addServiceItem called for non-service business');
      }
      await _getServiceItemsCollection().add(newService);
      _ref.read(messengerProvider).showSuccess('Service added successfully!');
      return true;
    } catch (e) {
      _ref
          .read(messengerProvider)
          .showError('Failed to add service: ${e.toString()}');
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
