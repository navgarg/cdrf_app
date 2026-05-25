import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/product_item.dart';
import '../api/inventory_service.dart' as firebase;
import '../interfaces/i_inventory_service.dart';

class FirebaseInventoryServiceAdapter implements IInventoryService {
  final firebase.InventoryService _service;

  FirebaseInventoryServiceAdapter(Ref ref)
      : _service = firebase.InventoryService(ref);

  @override
  Stream<List<ProductItem>> streamInventoryProductItems() =>
      _service.streamInventoryProductItems();

  @override
  Stream<ProductItem> streamProductItem(String itemId) =>
      _service.streamProductItem(itemId);

  @override
  Future<bool> addProductItem({
    required String name,
    String? description,
    required double price,
    required double cost,
    required int stockQuantity,
    required int reorderThreshold,
    required String unit,
    String? imageUrl,
  }) {
    return _service.addProductItem(
      name: name,
      description: description,
      price: price,
      cost: cost,
      stockQuantity: stockQuantity,
      reorderThreshold: reorderThreshold,
      unit: unit,
      imageUrl: imageUrl,
    );
  }

  @override
  Future<bool> updateProductItem(String id, {int? stockQuantity}) {
    return _service.updateProductItem(id, stockQuantity: stockQuantity);
  }
}
