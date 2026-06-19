import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/backend_config.dart';
import '../models/product_item.dart';
import '../services/adapters/firebase_inventory_service_adapter.dart';
import '../services/api/inventory_service_supabase.dart';
import '../services/interfaces/i_inventory_service.dart';

final inventoryServiceSwitchProvider = Provider<IInventoryService>((ref) {
  final backend = ref.watch(backendProvider);
  if (backend == BackendType.firebase) {
    return FirebaseInventoryServiceAdapter(ref);
  }
  return InventoryServiceSupabase(ref);
});

final inventoryServiceProvider = Provider<IInventoryService>((ref) {
  return ref.watch(inventoryServiceSwitchProvider);
});

final productItemProvider =
    StreamProvider.family<ProductItem, String>((ref, itemId) {
  return ref.watch(inventoryServiceProvider).streamProductItem(itemId);
});

final inventoryItemsProvider = StreamProvider<List<ProductItem>>((ref) {
  return ref.watch(inventoryServiceProvider).streamInventoryProductItems();
});
