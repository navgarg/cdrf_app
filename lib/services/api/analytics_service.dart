import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nariudyam/models/transaction.dart';
import 'package:nariudyam/providers/transaction_providers.dart';
import 'package:nariudyam/providers/inventory_providers.dart';
import 'package:nariudyam/providers/services_providers.dart';
import 'package:nariudyam/providers/auth_providers.dart';
import 'package:nariudyam/components/payment_selection_bottom_sheet.dart';

// Firebase (previous implementation)
// import 'package:nariudyam/services/api/transaction_service.dart';
// import 'package:nariudyam/services/api/inventory_service.dart';
// import 'package:nariudyam/services/api/services_service.dart';
// import 'package:nariudyam/services/api/auth_service.dart';

final analyticsServiceProvider = Provider((ref) => AnalyticsService(ref));

final overallMetricsProvider = Provider<Map<String, double>>((ref) {
  final transactionsAsync = ref.watch(allTransactionsStreamProvider);
  if (!transactionsAsync.hasValue) return {};

  final sales = transactionsAsync.value!
      .where((t) => t.transactionType == TransactionType.sale)
      .toList();

  double totalRevenue = 0;
  double totalProfit = 0;
  double totalCost = 0;

  for (final transaction in sales) {
    totalRevenue += (transaction.price * transaction.quantity);
    totalCost += (transaction.cost * transaction.quantity);
    totalProfit +=
        ((transaction.price - transaction.cost) * transaction.quantity);
  }

  // Count "transactions" as orders/checkouts when transaction_id exists.
  // Rows without a transaction_id are treated as their own order.
  final orderKeys = <String>{};
  for (final t in sales) {
    final key = (t.transactionId != null && t.transactionId!.trim().isNotEmpty)
        ? t.transactionId!
        : t.id;
    orderKeys.add(key);
  }

  final profitMargin =
      totalRevenue > 0 ? (totalProfit / totalRevenue) * 100 : 0.0;

  return {
    'totalRevenue': totalRevenue,
    'totalProfit': totalProfit,
    'totalCost': totalCost,
    'profitMargin': profitMargin,
    'totalTransactions': orderKeys.length.toDouble(),
  };
});

final paymentModeDataProvider = Provider<List<PaymentModeData>>((ref) {
  final transactionsAsync = ref.watch(allTransactionsStreamProvider);
  if (!transactionsAsync.hasValue) return [];

  final sales = transactionsAsync.value!
      .where((t) => t.transactionType == TransactionType.sale)
      .toList();

  final Map<PaymentMethod, double> revenueByMethod = {};
  final Map<PaymentMethod, Set<String>> orderKeysByMethod = {};

  for (final transaction in sales) {
    final method = transaction.paymentMethod;

    revenueByMethod[method] = (revenueByMethod[method] ?? 0) +
        (transaction.price * transaction.quantity);

    final orderKey = (transaction.transactionId != null &&
            transaction.transactionId!.trim().isNotEmpty)
        ? transaction.transactionId!
        : transaction.id;
    (orderKeysByMethod[method] ??= <String>{}).add(orderKey);
  }

  final result = revenueByMethod.entries.map((entry) {
    final method = entry.key;
    return PaymentModeData(
      method: method,
      revenue: entry.value,
      transactionCount: (orderKeysByMethod[method]?.length ?? 0),
    );
  }).toList();

  return result..sort((a, b) => b.revenue.compareTo(a.revenue));
});

final inventoryReorderDataProvider =
    Provider<List<InventoryReorderData>>((ref) {
  final itemsAsync = ref.watch(inventoryItemsProvider);
  if (!itemsAsync.hasValue) return [];

  final products = itemsAsync.value!;
  final List<InventoryReorderData> reorderData = [];

  for (final product in products) {
    if (product.stockQuantity <= product.reorderThreshold) {
      reorderData.add(InventoryReorderData(
        productName: product.name,
        currentStock: product.stockQuantity,
        reorderThreshold: product.reorderThreshold,
        timesReached: 1,
      ));
    }
  }

  return reorderData..sort((a, b) => a.currentStock.compareTo(b.currentStock));
});

final productRevenueDataProvider = Provider<List<ProductRevenueData>>((ref) {
  final transactionsAsync = ref.watch(allTransactionsStreamProvider);
  if (!transactionsAsync.hasValue) return [];

  final sales = transactionsAsync.value!
      .where((t) => t.transactionType == TransactionType.sale)
      .toList();

  final user = ref.watch(userProvider);
  final isService =
      user?.businessDomain?.trim().toLowerCase() == 'beauty parlor';

  Set<String> itemNames = {};

  if (isService) {
    final servicesAsync = ref.watch(serviceItemsProvider);
    if (!servicesAsync.hasValue) return [];
    itemNames = servicesAsync.value!.map((s) => s.name).toSet();
  } else {
    final inventoryAsync = ref.watch(inventoryItemsProvider);
    if (!inventoryAsync.hasValue) return [];
    itemNames = inventoryAsync.value!.map((i) => i.name).toSet();
  }

  final Map<String, ProductRevenueData> productMap = {};

  for (final transaction in sales) {
    final name = transaction.itemName ?? 'Unknown';
    if (!itemNames.contains(name)) continue;

    if (productMap.containsKey(name)) {
      final existing = productMap[name]!;
      productMap[name] = ProductRevenueData(
        productName: name,
        revenue: existing.revenue + (transaction.price * transaction.quantity),
        profit: existing.profit +
            ((transaction.price - transaction.cost) * transaction.quantity),
        salesCount: existing.salesCount + transaction.quantity.toInt(),
      );
    } else {
      productMap[name] = ProductRevenueData(
        productName: name,
        revenue: transaction.price * transaction.quantity,
        profit: (transaction.price - transaction.cost) * transaction.quantity,
        salesCount: transaction.quantity.toInt(),
      );
    }
  }

  return productMap.values.toList()
    ..sort((a, b) => b.revenue.compareTo(a.revenue));
});

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
          final revenue = transaction.price * transaction.quantity;
          final profit =
              (transaction.price - transaction.cost) * transaction.quantity;

          if (productMap.containsKey(name)) {
            final existing = productMap[name]!;
            productMap[name] = ProductRevenueData(
              productName: name,
              revenue: existing.revenue + revenue,
              profit: existing.profit + profit,
              salesCount: existing.salesCount + transaction.quantity,
            );
          } else {
            productMap[name] = ProductRevenueData(
              productName: name,
              revenue: revenue,
              profit: profit,
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
          final revenue = transaction.price * transaction.quantity;
          final profit =
              (transaction.price - transaction.cost) * transaction.quantity;

          if (productMap.containsKey(name)) {
            final existing = productMap[name]!;
            productMap[name] = ProductRevenueData(
              productName: name,
              revenue: existing.revenue + revenue,
              profit: existing.profit + profit,
              salesCount: existing.salesCount + transaction.quantity,
            );
          } else {
            productMap[name] = ProductRevenueData(
              productName: name,
              revenue: revenue,
              profit: profit,
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

      // Group by payment method, counting distinct orders via transactionId.
      final Map<PaymentMethod, double> revenueByMethod = {};
      final Map<PaymentMethod, Set<String>> orderKeysByMethod = {};

      for (final transaction in sales) {
        final method = transaction.paymentMethod;

        revenueByMethod[method] = (revenueByMethod[method] ?? 0) +
            (transaction.price * transaction.quantity);

        final orderKey = (transaction.transactionId != null &&
                transaction.transactionId!.trim().isNotEmpty)
            ? transaction.transactionId!
            : transaction.id;
        (orderKeysByMethod[method] ??= <String>{}).add(orderKey);
      }

      final result = revenueByMethod.entries.map((entry) {
        final method = entry.key;
        return PaymentModeData(
          method: method,
          revenue: entry.value,
          transactionCount: (orderKeysByMethod[method]?.length ?? 0),
        );
      }).toList();

      return result..sort((a, b) => b.revenue.compareTo(a.revenue));
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

      final orderKeys = <String>{};

      for (final transaction in sales) {
        totalRevenue += transaction.price * transaction.quantity;
        totalCost += transaction.cost * transaction.quantity;
        totalProfit +=
            (transaction.price - transaction.cost) * transaction.quantity;

        final orderKey = (transaction.transactionId != null &&
                transaction.transactionId!.trim().isNotEmpty)
            ? transaction.transactionId!
            : transaction.id;
        orderKeys.add(orderKey);
      }

      final profitMargin =
          totalRevenue > 0 ? (totalProfit / totalRevenue) * 100 : 0.0;

      return {
        'totalRevenue': totalRevenue,
        'totalProfit': totalProfit,
        'totalCost': totalCost,
        'profitMargin': profitMargin,
        'totalTransactions': orderKeys.length.toDouble(),
      };
    });
  }
}
