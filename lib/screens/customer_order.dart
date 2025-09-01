import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nariudyam/models/product_item.dart';
import 'package:nariudyam/models/service_item.dart';
import 'package:nariudyam/services/api/inventory_service.dart';
import 'package:nariudyam/services/api/services_service.dart';
import 'package:nariudyam/services/api/auth_service.dart';

final productsProvider = StreamProvider.autoDispose<List<ProductItem>>((ref) {
  return ref.watch(inventoryServiceProvider).streamInventoryProductItems();
});

final servicesProvider = StreamProvider.autoDispose<List<ServiceItem>>((ref) {
  return ref.watch(servicesServiceProvider).streamServiceItems();
});

// Cart stores quantity as double to support fractional (e.g. 0.5 kg) quantities.
final cartProvider = StateNotifierProvider<CartNotifier, Map<String, double>>(
    (ref) => CartNotifier());

class CartNotifier extends StateNotifier<Map<String, double>> {
  CartNotifier() : super({});

  void addToCart(String itemId, {double quantityDelta = 1}) {
    final updatedState = Map<String, double>.from(state);
    updatedState[itemId] = (updatedState[itemId] ?? 0) + quantityDelta;
    state = updatedState;
  }

  void removeFromCart(String itemId, {double quantityDelta = 1}) {
    final current = state[itemId];
    if (current != null) {
      final newQty = current - quantityDelta;
      final updatedState = Map<String, double>.from(state);
      if (newQty > 0) {
        updatedState[itemId] = double.parse(newQty.toStringAsFixed(2));
      } else {
        updatedState.remove(itemId);
      }
      state = updatedState;
    }
  }

  void clearCart() => state = {};
}

class CustomerOrderScreen extends ConsumerWidget {
  const CustomerOrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final isService = user?.businessDomain == 'Beauty Parlor';

    final itemsAsyncValue = isService
        // Beauty Parlor => show services on order page
        ? ref.watch(servicesProvider)
        : ref.watch(productsProvider);

    // Colors sourced from theme (no hard-coded hex values here)
    final theme = Theme.of(context);
    final itemBlockColor = theme.cardColor;

    return itemsAsyncValue.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(
              child: Text('No ${isService ? 'services' : 'products'} found.'));
        }
        final onSurface = theme.colorScheme.onSurface;
        return ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            dynamic item = items[index];
            String itemName = item.name;
            double itemPrice = item.price;
            String itemUnit = '';
            String itemId = item.id;

            if (!isService && item is ProductItem) {
              itemUnit = item.unit;
            }

            return Container(
              decoration: BoxDecoration(
                color: itemBlockColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Icon(
                          !isService ? Icons.inventory_2 : Icons.content_cut,
                          size: 28,
                          color: onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(itemName,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: onSurface)),
                          const SizedBox(height: 2),
                          Text(
                              '₹${itemPrice.toStringAsFixed(2)}' +
                                  (!isService ? ' per $itemUnit' : ''),
                              style: TextStyle(
                                  fontSize: 14,
                                  color: onSurface.withOpacity(0.6))),
                        ],
                      ),
                    ),
                    _AddToCartButton(
                      itemId: itemId,
                      isService: isService,
                      productItem:
                          !isService && item is ProductItem ? item : null,
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Error loading data: $error')),
    );
  }
}

class _AddToCartButton extends ConsumerWidget {
  final String itemId;
  final bool isService; // true when business domain is service based
  final ProductItem? productItem;

  const _AddToCartButton({
    required this.itemId,
    required this.isService,
    this.productItem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final qtyMap = ref.watch(cartProvider);
    final qty = qtyMap[itemId];
    final notifier = ref.read(cartProvider.notifier);
    final onPrimary = theme.colorScheme.onPrimary;

    // Determine increment size (0.5 for weight-based products with kg unit)
    final bool isWeightProduct =
        !isService && (productItem?.unit.toLowerCase().contains('kg') ?? false);
    final double step = isWeightProduct ? 0.5 : 1.0;

    if (qty == null) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: onPrimary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          elevation: 0,
        ),
        onPressed: () => notifier.addToCart(itemId, quantityDelta: step),
        child: Text('Add',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: onPrimary)),
      );
    }

    String displayQty() {
      if (isWeightProduct) {
        // show 0.5 precision if needed
        final showDecimal = (qty % 1) != 0;
        return '${qty.toStringAsFixed(showDecimal ? 1 : 0)} ${productItem?.unit ?? ''}';
      }
      return '${qty.toStringAsFixed(0)}';
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => notifier.removeFromCart(itemId, quantityDelta: step),
            child: Icon(Icons.remove, color: onPrimary, size: 16),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              displayQty(),
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, color: onPrimary),
            ),
          ),
          GestureDetector(
            onTap: () => notifier.addToCart(itemId, quantityDelta: step),
            child: Icon(Icons.add, color: onPrimary, size: 16),
          ),
        ],
      ),
    );
  }
}
