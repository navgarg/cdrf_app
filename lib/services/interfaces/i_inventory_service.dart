import '../../models/product_item.dart';
import '../../components/payment_selection_bottom_sheet.dart';

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
    String? imageUrl,
  });

  Future<bool> updateProductItem(
    String id, {
    int? stockQuantity,
  });

  Future<bool> recordBulkSales({
    required List<InventorySaleRequest> sales,
    required PaymentMethod paymentMethod,
  });
}

class InventorySaleRequest {
  final ProductItem item;
  final int quantity;

  const InventorySaleRequest({
    required this.item,
    required this.quantity,
  });
}
