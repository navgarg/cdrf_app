import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nariudyam/screens/customer_order.dart';
import 'package:nariudyam/services/api/auth_service.dart';

class CartBottomSheet extends ConsumerWidget {
  const CartBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final user = ref.watch(userProvider);
    final isService = user?.businessDomain == 'Beauty Parlor';

    final products = ref.watch(productsProvider).asData?.value ?? [];
    final services = ref.watch(servicesProvider).asData?.value ?? [];

    double total = 0;
    final cartItems = <Map<String, dynamic>>[];

    // Build cart items and calculate total
    for (final entry in cart.entries) {
      dynamic item;
      if (!isService) {
        try {
          item = products.firstWhere((p) => p.id == entry.key);
        } catch (e) {
          continue; // Skip items not found
        }
      } else {
        try {
          item = services.firstWhere((s) => s.id == entry.key);
        } catch (e) {
          continue; // Skip items not found
        }
      }

      total += item.price * entry.value;
      cartItems.add({'item': item, 'quantity': entry.value});
    }
    final theme = Theme.of(context);
    final itemBlockColor = theme.cardColor;
    final addButtonColor = theme.colorScheme.primary;

    final onSurface = theme.colorScheme.onSurface;
    final onPrimary = theme.colorScheme.onPrimary;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: addButtonColor,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new, color: onPrimary),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                      ),
                      Expanded(
                        child: Text(
                          'Cart',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: onPrimary),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'My Cart:',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: onSurface),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, bottom: 100.0),
                  child: cartItems.isEmpty
                      ? Center(
                          child: Text('Your cart is empty.',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: onSurface.withOpacity(0.6))),
                        )
                      : ListView.separated(
                          itemCount: cartItems.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, idx) {
                            final cartItem = cartItems[idx];
                            final item = cartItem['item'];
                            final double qty = cartItem['quantity'];
                            final totalPrice = item.price * qty;
                            final bool isWeightProduct = !isService &&
                                (item.unit != null &&
                                    item.unit
                                        .toString()
                                        .toLowerCase()
                                        .contains('kg'));

                            return Container(
                              decoration: BoxDecoration(
                                color: itemBlockColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                      color: onSurface.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2)),
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
                                        color: onPrimary.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          !isService
                                              ? Icons.inventory_2
                                              : Icons.content_cut,
                                          size: 28,
                                          color: onSurface.withOpacity(0.6),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(item.name,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: onSurface)),
                                          const SizedBox(height: 2),
                                          Text(
                                            '₹${item.price.toStringAsFixed(2)}${!isService && item.unit != null ? ' per ${item.unit}' : ''}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: onSurface.withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: addButtonColor,
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 8),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              ref
                                                  .read(cartProvider.notifier)
                                                  .removeFromCart(
                                                    item.id,
                                                    quantityDelta:
                                                        isWeightProduct
                                                            ? 0.5
                                                            : 1,
                                                  );
                                            },
                                            child: Icon(Icons.remove,
                                                color: onPrimary, size: 16),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                            child: Text(
                                              isWeightProduct
                                                  ? (qty % 1 == 0
                                                      ? qty.toStringAsFixed(0)
                                                      : qty.toStringAsFixed(1))
                                                  : qty.toStringAsFixed(0),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: onPrimary,
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              ref
                                                  .read(cartProvider.notifier)
                                                  .addToCart(
                                                    item.id,
                                                    quantityDelta:
                                                        isWeightProduct
                                                            ? 0.5
                                                            : 1,
                                                  );
                                            },
                                            child: Icon(Icons.add,
                                                color: onPrimary, size: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text('₹${totalPrice.toStringAsFixed(2)}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: onSurface)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
          if (cartItems.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: itemBlockColor,
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                        color: onSurface.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, -2)),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('To Pay',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: onSurface)),
                          Text('₹${total.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  color: onSurface)),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: addButtonColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.all(16),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Add order completion logic here
                        },
                        child: Icon(Icons.check, color: onPrimary, size: 28),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
