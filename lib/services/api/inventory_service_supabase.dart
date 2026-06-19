import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../models/product_item.dart';
import '../../components/payment_selection_bottom_sheet.dart';
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

  @override
  Future<bool> recordBulkSales({
    required List<InventorySaleRequest> sales,
    required PaymentMethod paymentMethod,
  }) async {
    if (sales.isEmpty) return false;

    try {
      final uid = _requireUserId();
      final now = DateTime.now();
      final transactionId = const Uuid().v4();

      // Validate stock availability for all items first
      for (final sale in sales) {
        if (sale.quantity <= 0) {
          throw Exception('Quantity must be greater than zero.');
        }
        if (sale.quantity > sale.item.stockQuantity) {
          throw Exception(
            'Not enough stock for ${sale.item.name}. Available: ${sale.item.stockQuantity}',
          );
        }
      }

      // Update inventory items - decrement stock and update lastSoldDate
      for (final sale in sales) {
        final newStock = sale.item.stockQuantity - sale.quantity;
        await _supabase
            .from('inventory_items')
            .update({
              'stock_quantity': newStock,
              'last_sold_date': now.toIso8601String(),
            })
            .eq('user_id', uid)
            .eq('id', sale.item.id);
      }

      // Create transaction records for each sale item
      final transactionsData = <Map<String, dynamic>>[];
      for (final sale in sales) {
        transactionsData.add({
          'user_id': uid,
          'business_id': uid,
          'product_id': sale.item.id,
          'item_name': sale.item.name,
          'quantity': sale.quantity,
          'price': sale.item.price,
          'cost': sale.item.cost,
          'payment_method': paymentMethod.name,
          'transaction_type': 'sale',
          'timestamp': now.toIso8601String(),
          'transaction_id': transactionId,
        });
      }

      await _supabase.from('transactions').insert(transactionsData);

      _ref
          .read(messengerProvider)
          .showSuccess('Sales logged successfully!');
      return true;
    } catch (e) {
      debugPrint('recordBulkSales failed: $e');
      _ref
          .read(messengerProvider)
          .showError('Failed to log sales: ${e.toString()}');
      return false;
    }
  }
}
