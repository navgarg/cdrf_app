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
  Stream<List<ProductItem>> streamInventoryProductItems() async* {
    final user = _ref.read(userProvider);
    if (user == null) {
      yield <ProductItem>[];
      return;
    }
    final uid = user.uid;

    yield await _fetchInventoryProductItems(uid);

    try {
      await for (final rows
          in _supabase.from('inventory_items').stream(primaryKey: ['id'])) {
        yield _mapInventoryRows(rows, uid);
      }
    } catch (e) {
      debugPrint('streamInventoryProductItems realtime failed: $e');
    }
  }

  @override
  Stream<ProductItem> streamProductItem(String itemId) async* {
    final user = _ref.read(userProvider);
    if (user == null) {
      throw Exception('User not logged in!');
    }
    final uid = user.uid;

    yield await _fetchProductItem(uid, itemId);

    try {
      await for (final rows
          in _supabase.from('inventory_items').stream(primaryKey: ['id'])) {
        final row = rows.firstWhere(
          (r) => r['user_id'] == uid && r['id'].toString() == itemId,
          orElse: () => <String, dynamic>{},
        );
        if (row.isNotEmpty) {
          yield ProductItem.fromMap(row, row['id'].toString());
        }
      }
    } catch (e) {
      debugPrint('streamProductItem realtime failed: $e');
    }
  }

  Future<List<ProductItem>> _fetchInventoryProductItems(String uid) async {
    final rows = await _supabase
        .from('inventory_items')
        .select()
        .eq('user_id', uid)
        .order('name', ascending: true);
    return _mapInventoryRows(rows, uid);
  }

  Future<ProductItem> _fetchProductItem(String uid, String itemId) async {
    final rows = await _supabase
        .from('inventory_items')
        .select()
        .eq('user_id', uid)
        .eq('id', itemId)
        .limit(1);
    if (rows.isEmpty) {
      throw Exception('Item not found');
    }
    final row = rows.first;
    return ProductItem.fromMap(row, row['id'].toString());
  }

  List<ProductItem> _mapInventoryRows(
    List<Map<String, dynamic>> rows,
    String uid,
  ) {
    final items = rows
        .where((row) => row['user_id'] == uid)
        .map((row) => ProductItem.fromMap(row, row['id'].toString()))
        .toList(growable: true);
    items.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return items;
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
