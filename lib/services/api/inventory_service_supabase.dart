import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/product_item.dart';
import '../../providers/shared_providers.dart';
import '../../services/general/messenger.dart';
import '../interfaces/i_inventory_service.dart';

class InventoryServiceSupabase implements IInventoryService {
  final Ref _ref;
  final SupabaseClient _supabase = Supabase.instance.client;

  InventoryServiceSupabase(this._ref);

  String _requireUserId() {
    final user = _ref.read(userProvider);
    if (user == null) throw Exception('User not logged in!');
    return user.uid;
  }

  @override
  Stream<List<ProductItem>> streamInventoryProductItems() {
    final user = _ref.read(userProvider);
    if (user == null) return Stream.value(<ProductItem>[]);

    return _supabase
        .from('inventory_items')
        .stream(primaryKey: ['id']).map((rows) {
      final items = rows
          .where((row) => row['user_id'] == user.uid)
          .map((row) => ProductItem.fromMap(row, row['id'].toString()))
          .toList(growable: false);

      final sorted = items.toList(growable: true)
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return sorted;
    });
  }

  @override
  Stream<ProductItem> streamProductItem(String itemId) {
    final user = _ref.read(userProvider);
    if (user == null) {
      return Stream.error(Exception('User not logged in!'));
    }

    return _supabase
        .from('inventory_items')
        .stream(primaryKey: ['id']).map((rows) {
      final row = rows.firstWhere(
        (r) => r['user_id'] == user.uid && r['id'].toString() == itemId,
        orElse: () => <String, dynamic>{},
      );
      if (row.isEmpty) {
        throw Exception('Item not found');
      }
      return ProductItem.fromMap(row, row['id'].toString());
    });
  }

  @override
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
      final uid = _requireUserId();

      await _supabase.from('inventory_items').insert({
        'user_id': uid,
        'business_id': uid,
        'name': name,
        'description': description,
        'price': price,
        'cost': cost,
        'stock_quantity': stockQuantity,
        'reorder_threshold': reorderThreshold,
        'unit': unit,
      });

      _ref.read(messengerProvider).showSuccess('Product added successfully!');
      return true;
    } catch (e) {
      debugPrint('addProductItem failed: $e');
      _ref
          .read(messengerProvider)
          .showError('Failed to add product: ${e.toString()}');
      return false;
    }
  }

  @override
  Future<bool> updateProductItem(String id, {int? stockQuantity}) async {
    try {
      final uid = _requireUserId();

      final updates = <String, dynamic>{};
      if (stockQuantity != null) {
        updates['stock_quantity'] = stockQuantity;
      }

      if (updates.isEmpty) return false;

      await _supabase
          .from('inventory_items')
          .update(updates)
          .eq('user_id', uid)
          .eq('id', id);

      _ref.read(messengerProvider).showSuccess('Product updated successfully!');
      return true;
    } catch (e) {
      debugPrint('updateProductItem failed: $e');
      _ref
          .read(messengerProvider)
          .showError('Failed to update product: ${e.toString()}');
      return false;
    }
  }
}
