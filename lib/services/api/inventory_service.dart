import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nariudyam/services/general/messenger.dart';

final inventoryServiceProvider = Provider((ref) => InventoryService(ref));

class InventoryService {
  final Ref _ref;

  InventoryService(this._ref);

  Future<bool> addInventoryItem({
    required String name,
    String? description,
    required double price,
    required double cost,
    required int stockQuantity,
    required int reorderThreshold,
    String? unit,
  }) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      _ref.read(messengerProvider).showSuccess('Inventory item added successfully!');
      return true;
    } catch (e) {
      _ref.read(messengerProvider).showError('Failed to add inventory item: $e');
      return false;
    }
  }
}