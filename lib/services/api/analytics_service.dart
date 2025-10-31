import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nariudyam/models/transaction.dart';
import 'package:nariudyam/services/api/transaction_service.dart';
import 'package:nariudyam/services/api/inventory_service.dart';
import 'package:nariudyam/services/api/services_service.dart';
import 'package:nariudyam/services/api/auth_service.dart';
import 'package:nariudyam/components/payment_selection_bottom_sheet.dart';

final analyticsServiceProvider = Provider((ref) => AnalyticsService(ref));

class ProductRevenueData {
  final String productName;
  final double revenue;
  final double profit;
  final int salesCount;

  ProductRevenueData({
    required this.productName,
    required this.revenue,
    required this.profit,
    required this.salesCount,
  });
}

class PaymentModeData {
  final PaymentMethod method;
  final double revenue;
  final int transactionCount;

  PaymentModeData({
    required this.method,
    required this.revenue,
    required this.transactionCount,
  });
}

class InventoryReorderData {
  final String productName;
  final int currentStock;
  final int reorderThreshold;
  final int timesReached;

  InventoryReorderData({
    required this.productName,
    required this.currentStock,
    required this.reorderThreshold,
    required this.timesReached,
  });
}

class AnalyticsService {
  final Ref _ref;

  AnalyticsService(this._ref);

  bool _isServiceBusiness() {
    final user = _ref.read(userProvider);
    final raw = user?.businessDomain ?? '';
    return raw.trim().toLowerCase() == 'beauty parlor';
  }

  Stream<List<ProductRevenueData>> getProductRevenueStream() {
    final isService = _isServiceBusiness();

    if (isService) {
      // For service-based businesses, get data from services collection
      return _ref
          .read(servicesServiceProvider)
          .streamServiceItems()
          .asyncMap((services) async {
        // Get all transactions to calculate revenue per service
        final transactions = await _ref
            .read(transactionServiceProvider)
            .streamTransactions()
            .first;

        final sales = transactions
            .where((t) => t.transactionType == TransactionType.sale)
            .toList();

        // Create a map of service names from the services collection
        final serviceNames = services.map((s) => s.name).toSet();

        // Group by service name, only include services from the services collection
        final Map<String, ProductRevenueData> productMap = {};

        for (final transaction in sales) {
          final name = transaction.itemName ?? 'Unknown';
          // Only include if it's in the services collection
          if (!serviceNames.contains(name)) continue;

          if (productMap.containsKey(name)) {
            final existing = productMap[name]!;
            productMap[name] = ProductRevenueData(
              productName: name,
              revenue: existing.revenue + transaction.price,
              profit: existing.profit + (transaction.price - transaction.cost),
              salesCount: existing.salesCount + transaction.quantity,
            );
          } else {
            productMap[name] = ProductRevenueData(
              productName: name,
              revenue: transaction.price,
              profit: transaction.price - transaction.cost,
              salesCount: transaction.quantity,
            );
          }
        }

        return productMap.values.toList()
          ..sort((a, b) => b.revenue.compareTo(a.revenue));
      });
    } else {
      // For item-based businesses, get data from inventory collection
      return _ref
          .read(transactionServiceProvider)
          .streamTransactions()
          .asyncMap((transactions) async {
        // Get all inventory items
        final inventoryItems = await _ref
            .read(inventoryServiceProvider)
            .streamInventoryProductItems()
            .first;

        final sales = transactions
            .where((t) => t.transactionType == TransactionType.sale)
            .toList();

        // Create a map of inventory item names
        final inventoryNames = inventoryItems.map((i) => i.name).toSet();

        // Group by product name, only include items from inventory collection
        final Map<String, ProductRevenueData> productMap = {};

        for (final transaction in sales) {
          final name = transaction.itemName ?? 'Unknown';
          // Only include if it's in the inventory collection
          if (!inventoryNames.contains(name)) continue;

          if (productMap.containsKey(name)) {
            final existing = productMap[name]!;
            productMap[name] = ProductRevenueData(
              productName: name,
              revenue: existing.revenue + transaction.price,
              profit: existing.profit + (transaction.price - transaction.cost),
              salesCount: existing.salesCount + transaction.quantity,
            );
          } else {
            productMap[name] = ProductRevenueData(
              productName: name,
              revenue: transaction.price,
              profit: transaction.price - transaction.cost,
              salesCount: transaction.quantity,
            );
          }
        }

        return productMap.values.toList()
          ..sort((a, b) => b.revenue.compareTo(a.revenue));
      });
    }
  }

  Stream<List<PaymentModeData>> getPaymentModeStream() {
    return _ref
        .read(transactionServiceProvider)
        .streamTransactions()
        .map((transactions) {
      // Filter only sales
      final sales = transactions
          .where((t) => t.transactionType == TransactionType.sale)
          .toList();

      // Group by payment method
      final Map<PaymentMethod, PaymentModeData> paymentMap = {};

      for (final transaction in sales) {
        final method = transaction.paymentMethod;
        if (paymentMap.containsKey(method)) {
          final existing = paymentMap[method]!;
          paymentMap[method] = PaymentModeData(
            method: method,
            revenue: existing.revenue + transaction.price,
            transactionCount: existing.transactionCount + 1,
          );
        } else {
          paymentMap[method] = PaymentModeData(
            method: method,
            revenue: transaction.price,
            transactionCount: 1,
          );
        }
      }

      return paymentMap.values.toList()
        ..sort((a, b) => b.revenue.compareTo(a.revenue));
    });
  }

  Stream<List<InventoryReorderData>> getInventoryReorderStream() {
    return _ref
        .read(inventoryServiceProvider)
        .streamInventoryProductItems()
        .map((products) {
      final List<InventoryReorderData> reorderData = [];

      for (final product in products) {
        if (product.stockQuantity <= product.reorderThreshold) {
          // Calculate how many times threshold was reached (simplified: 1 if currently at/below threshold)
          reorderData.add(InventoryReorderData(
            productName: product.name,
            currentStock: product.stockQuantity,
            reorderThreshold: product.reorderThreshold,
            timesReached:
                1, // simplified - could track history for better accuracy
          ));
        }
      }

      return reorderData
        ..sort((a, b) => a.currentStock.compareTo(b.currentStock));
    });
  }

  Stream<Map<String, double>> getOverallMetrics() {
    return _ref
        .read(transactionServiceProvider)
        .streamTransactions()
        .map((transactions) {
      final sales = transactions
          .where((t) => t.transactionType == TransactionType.sale)
          .toList();

      double totalRevenue = 0;
      double totalProfit = 0;
      double totalCost = 0;

      for (final transaction in sales) {
        totalRevenue += transaction.price;
        totalCost += transaction.cost;
        totalProfit += (transaction.price - transaction.cost);
      }

      final profitMargin =
          totalRevenue > 0 ? (totalProfit / totalRevenue) * 100 : 0.0;

      return {
        'totalRevenue': totalRevenue,
        'totalProfit': totalProfit,
        'totalCost': totalCost,
        'profitMargin': profitMargin,
        'totalTransactions': sales.length.toDouble(),
      };
    });
  }
}
