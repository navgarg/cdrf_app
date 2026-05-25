import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nariudyam/screens/customer_order.dart';
import 'package:nariudyam/providers/inventory_providers.dart';
import 'package:nariudyam/providers/services_providers.dart';
import 'package:nariudyam/providers/auth_providers.dart';
import 'package:nariudyam/components/rating_bottom_sheet.dart';
import 'package:nariudyam/components/payment_selection_bottom_sheet.dart';
import 'package:nariudyam/components/qr_payment_bottom_sheet.dart';
import 'package:nariudyam/models/business_domain.dart';
import 'package:nariudyam/providers/transaction_providers.dart';
import 'package:nariudyam/models/transaction.dart';
import 'package:nariudyam/models/product_item.dart';
import 'package:nariudyam/services/general/messenger.dart';
import 'package:nariudyam/l10n/dynamic_localizations.dart';

import 'package:uuid/uuid.dart';

class CartBottomSheet extends ConsumerWidget {
  const CartBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final user = ref.watch(userProvider);
    final isService = BusinessDomainUtils.isServiceDomain(user?.businessDomain);

    final products = ref.watch(inventoryItemsProvider).asData?.value ?? [];
    final services = ref.watch(serviceItemsProvider).asData?.value ?? [];

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
                          context.tr('Cart'),
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
                  context.tr('My Cart:'),
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
                          child: Text(context.tr('Your cart is empty.'),
                              style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      onSurface.withAlpha(153))), // 0.6 opacity
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
                                      color: onSurface
                                          .withAlpha(13), // 0.05 opacity
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
                                        color: onPrimary
                                            .withAlpha(51), // 0.2 opacity
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          !isService
                                              ? Icons.inventory_2
                                              : Icons.content_cut,
                                          size: 28,
                                          color: onSurface
                                              .withAlpha(153), // 0.6 opacity
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              context.tr(item
                                                  .name), // Translate product/service name
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: onSurface)),
                                          const SizedBox(height: 2),
                                          Text(
                                            '₹${item.price.toStringAsFixed(2)}${!isService && item.unit != null ? ' ${context.tr('per')} ${context.tr(item.unit)}' : ''}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: onSurface.withAlpha(
                                                  153), // 0.6 opacity
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
                        color: onSurface.withAlpha(26), // 0.1 opacity
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
                          Text(context.tr('To Pay'),
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
                          // Start new flow (keep cart sheet open so context remains valid):
                          _startOrderFlow(
                              context, ref, cartItems, total, isService);
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

  void _startOrderFlow(
      BuildContext context,
      WidgetRef ref,
      List<Map<String, dynamic>> cartItems,
      double total,
      bool isService) async {
    double? rating;
    PaymentMethod? paymentMethod;

    // 1. Rating bottom sheet
    rating = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) => RatingBottomSheet(
        onSubmit: (r) => Navigator.of(c).pop(r),
      ),
    );
    if (rating == null) return; // user dismissed
    final ratingSkipped = rating == skippedRating;
    if (!context.mounted) return;
    // debug
    // ignore: avoid_print
    print(ratingSkipped
        ? '[OrderFlow] Rating skipped'
        : '[OrderFlow] Got rating: $rating');

    // 2. Payment selection bottom sheet
    paymentMethod = await showModalBottomSheet<PaymentMethod>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) => PaymentSelectionBottomSheet(
        onSelected: (m) => Navigator.of(c).pop(m),
      ),
    );
    if (paymentMethod == null) return;
    if (!context.mounted) return;
    // ignore: avoid_print
    print('[OrderFlow] Payment method selected: $paymentMethod');

    // 3. If QR -> show QR sheet to confirm payment
    if (paymentMethod == PaymentMethod.qr) {
      final confirmed = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (c) => QrPaymentBottomSheet(
          onConfirmPaid: () => Navigator.of(c).pop(true),
        ),
      );
      if (confirmed != true) return; // aborted
      if (!context.mounted) return;
      // ignore: avoid_print
      print('[OrderFlow] QR payment confirmed');
    }

    // 4. Persist each cart line as a transaction (sale). For services there is no stock update here.
    final transactionService = ref.read(transactionServiceProvider);
    final String sharedTransactionId = const Uuid().v4();

    bool allSucceeded = true;
    Object? lastError;

    for (final entry in cartItems) {
      final item = entry['item'];
      final double qtyDouble = entry['quantity'] as double;
      final int quantity = qtyDouble.round(); // Transaction model uses int
      final double price = item
          .price; // Multiply by qty later in UI if needed, but DB ideally stores unit price, wait user said "shows 20rs even if i buy 5 qty"
      // Let's store unit price but wait... wait! Does the prompt mean we should store total price, OR calculate properly on dashboard?
      // "revenue is not being calculated properly qty is not being multiplied white calculating revenue only base price is being added " -> means I need to multiply it in dashboard service.
      final double cost = (item is ProductItem)
          ? (item.cost)
          : 0.0; // service has no cost field
      try {
        await transactionService.addTransaction(
          transactionId: sharedTransactionId,
          productId: item.id,
          // Store canonical name in DB; translate only at render-time.
          itemName: item.name,
          quantity: quantity,
          price: price,
          cost: cost,
          transactionType: TransactionType.sale,
          paymentMethod: paymentMethod,
        );
      } catch (e) {
        allSucceeded = false;
        lastError = e;
        break;
      }
    }

    if (!context.mounted) return;
    if (!allSucceeded) {
      try {
        ref
            .read(messengerProvider)
            .showError('Order failed. Please try again. ${lastError ?? ''}');
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order failed. Please try again.')),
        );
      }
      return;
    }

    // 5. Clear cart
    ref.read(cartProvider.notifier).clearCart();

    // 6. Show success (use messenger if available)
    try {
      ref.read(messengerProvider).showSuccess('Order completed successfully!');
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order completed successfully!')));
    }

    // 7. Now close the original cart sheet (if still open)
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}
