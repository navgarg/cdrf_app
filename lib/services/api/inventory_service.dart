import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nariudyam/models/product_item.dart';
import 'package:nariudyam/models/transaction.dart';
import 'package:nariudyam/services/api/auth_service.dart';
import 'package:nariudyam/services/general/messenger.dart';
import 'package:nariudyam/components/payment_selection_bottom_sheet.dart';
import 'package:nariudyam/services/interfaces/i_inventory_service.dart';
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

  Future<bool> recordBulkSales({
    required List<InventorySaleRequest> sales,
    required PaymentMethod paymentMethod,
  }) async {
    if (sales.isEmpty) return false;

    try {
      final user = _ref.read(userProvider);
      if (user == null) throw Exception('User not logged in!');

      final batch = _firestore.batch();
      final now = DateTime.now();
      final inventoryCollection = _getInventoryProductItemsCollection();
      final transactionsCollection = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('businesses')
          .doc(user.uid)
          .collection('transactions');

      for (final sale in sales) {
        if (sale.quantity <= 0) {
          throw Exception('Quantity must be greater than zero.');
        }
        if (sale.quantity > sale.item.stockQuantity) {
          throw Exception(
            'Not enough stock for ${sale.item.name}. Available: ${sale.item.stockQuantity}',
          );
        }

        final inventoryDoc = inventoryCollection.doc(sale.item.id);
        batch.update(inventoryDoc, {
          'stockQuantity': sale.item.stockQuantity - sale.quantity,
          'lastSoldDate': now,
        });

        final transactionDoc = transactionsCollection.doc();
        final transaction = Transaction(
          id: transactionDoc.id,
          productId: sale.item.id,
          itemName: sale.item.name,
          quantity: sale.quantity,
          price: sale.item.price,
          cost: sale.item.cost,
          transactionType: TransactionType.sale,
          timestamp: now,
          businessId: user.uid,
          paymentMethod: paymentMethod,
        );
        batch.set(transactionDoc, transaction.toMap());
      }

      await batch.commit();
      _ref.read(messengerProvider).showSuccess('Sales logged successfully!');
      return true;
    } catch (e) {
      _ref
          .read(messengerProvider)
          .showError('Failed to log sales: ${e.toString()}');
      return false;
    }
  }
}
