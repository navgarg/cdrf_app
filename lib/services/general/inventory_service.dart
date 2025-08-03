import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/inventory_item.dart';

final inventoryServiceProvider = Provider((ref) => InventoryService());

class InventoryService {
  // Dummy data for demonstration
  final List<InventoryItem> _inventoryItems = [
    InventoryItem(
      id: '1',
      name: 'Product A',
      description: 'Description for Product A',
      price: 25.00,
      cost: 10.00,
      stockQuantity: 100,
      reorderThreshold: 20,
      unit: 'Packs',
    ),
    InventoryItem(
      id: '2',
      name: 'Product B',
      description: 'Description for Product B',
      price: 15.00,
      cost: 5.00,
      stockQuantity: 200,
      reorderThreshold: 50,
      unit: 'Pieces',
    ),
    InventoryItem(
      id: '3',
      name: 'Product C',
      description: 'Description for Product C',
      price: 50.00,
      cost: 20.00,
      stockQuantity: 50,
      reorderThreshold: 10,
      unit: 'Bottles',
    ),
  ];

  Future<List<InventoryItem>> getInventoryItems() async {
    // Simulate a network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _inventoryItems;
  }

  void addInventoryItem(InventoryItem item) {
    _inventoryItems.add(item);
  }

  void updateInventoryItem(InventoryItem updatedItem) {
    final index = _inventoryItems.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _inventoryItems[index] = updatedItem;
    }
  }

  void deleteInventoryItem(String id) {
    _inventoryItems.removeWhere((item) => item.id == id);
  }
}