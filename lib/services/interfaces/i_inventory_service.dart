import '../../models/product_item.dart';

abstract class IInventoryService {
  Stream<List<ProductItem>> streamInventoryProductItems();

  Stream<ProductItem> streamProductItem(String itemId);

  Future<bool> addProductItem({
    required String name,
    String? description,
    required double price,
    required double cost,
    required int stockQuantity,
    required int reorderThreshold,
    required String unit,
  });

  Future<bool> updateProductItem(
    String id, {
    int? stockQuantity,
  });
}
