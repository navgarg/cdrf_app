import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nariudyam/services/api/inventory_service.dart';
import 'package:nariudyam/services/api/transaction_service.dart';
import 'package:nariudyam/models/transaction.dart';
import 'package:nariudyam/components/payment_selection_bottom_sheet.dart';
import '../../models/product_item.dart';
import 'package:nariudyam/services/api/fav_customer_service.dart'; // Import FavouriteCustomerService
import '../../services/api/auth_service.dart';
import '../../l10n/dynamic_localizations.dart';

class InventoryItemDetailScreen extends ConsumerWidget {
  // final InventoryItem item;
  final String itemId;

  const InventoryItemDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(productItemProvider(itemId));

    return itemAsync.when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, stack) => Scaffold(
            body: Center(child: Text(context.tr('Error: ${err.toString()}')))),
        data: (item) {
          return DraggableScrollableSheet(
            initialChildSize: 0.4, // Initial height of the bottom sheet
            minChildSize: 0.4, // Minimum height
            maxChildSize: 1.0, // Maximum height (full screen)
            expand: true,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((255 * 0.1).round()),
                      blurRadius: 10,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 16.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                      ),
                      Text(
                        context.tr(item.name), // Translate product name
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildActionButton(context, Icons.shopping_cart,
                              context.tr('Order'), item, ref),
                          // _buildActionButton(context, Icons.swap_horiz, 'Transfer'),
                          _buildActionButton(
                              context,
                              Icons.attach_money_outlined,
                              context.tr('Sell'),
                              item,
                              ref),
                        ],
                      ),
                      const SizedBox(height: 24.0),
                      _buildDetailRow(context, context.tr('Amount'),
                          '${item.stockQuantity} ${context.tr(item.unit)}'),
                      _buildDetailRow(context, context.tr('Reorder Threshold'),
                          '${item.reorderThreshold} ${context.tr(item.unit)}'),
                      _buildDetailRow(context, context.tr('Locations'),
                          item.location ?? context.tr('Not Available')),
                      _buildDetailRow(context, context.tr('Description'),
                          item.description ?? context.tr('Not Available')),
                      _buildDetailRow(context, context.tr('Stock value'),
                          '₹${(item.price * item.stockQuantity).toStringAsFixed(2)}'),
                      _buildDetailRow(
                          context,
                          context.tr('Last Purchased'),
                          item.lastPurchasedDate
                                  ?.toLocal()
                                  .toString()
                                  .split(' ')[0] ??
                              context.tr('Not Available')),
                      _buildDetailRow(
                          context,
                          context.tr('Last Sold'),
                          item.lastSoldDate
                                  ?.toLocal()
                                  .toString()
                                  .split(' ')[0] ??
                              context.tr('Not Available')),
                      _buildDetailRow(context, context.tr('Last Price'),
                          '₹${item.price.toStringAsFixed(2)} ${context.tr('Per')} ${context.tr(item.unit)}'),
                      _buildDetailRow(context, context.tr('Average Price'),
                          '₹${item.cost.toStringAsFixed(2)} ${context.tr('Per')} ${context.tr(item.unit)}'),
                    ],
                  ),
                ),
              );
            },
          );
        });
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    ProductItem item,
    WidgetRef ref,
  ) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: () {
            if (label == context.tr('Sell')) {
              _showCustomerSelectionDialog(context, item, ref);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        '$label ${context.tr('action for')} ${context.tr(item.name)}')),
              );
            }
          },
        ),
        Text(label),
      ],
    );
  }

  void _showCustomerSelectionDialog(
      BuildContext context, ProductItem item, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final userId = user?.uid;
    if (userId == null) {
      throw FlutterError('User not logged in');
    }
    final customersAsyncValue = ref.watch(favouriteCustomersProvider(userId));

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(context.tr('Select Customer')),
          content: customersAsyncValue.when(
            data: (customers) {
              return SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount:
                      customers.length + 1, // +1 for 'No Customer' option
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ListTile(
                        title: Text(context.tr('No Customer')),
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                          _showSellDialog(context, item, ref, customerId: null);
                        },
                      );
                    }
                    final customer = customers[index - 1];
                    return ListTile(
                      title: Text(customer.name),
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                        _showSellDialog(context, item, ref,
                            customerId: customer.id);
                      },
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) =>
                Center(child: Text(context.tr('Error: $err'))),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(context.tr('Cancel')),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSellDialog(BuildContext context, ProductItem item, WidgetRef ref,
      {String? customerId}) {
    // These are created here and will be garbage collected when the dialog closes.
    final quantityController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(context.tr('Sell Item')),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration:
                  InputDecoration(labelText: context.tr('Quantity to sell')),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.tr('Please enter quantity');
                }
                final quantity = int.tryParse(value);
                if (quantity == null || quantity <= 0) {
                  return context.tr('Please enter a valid positive number');
                }
                if (quantity > item.stockQuantity) {
                  return context
                      .tr('Not enough stock. Available: ${item.stockQuantity}');
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(context.tr('Cancel')),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: Text(context.tr('Sell')),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final quantityToSell = int.parse(quantityController.text);
                  final newStockQuantity = item.stockQuantity - quantityToSell;

                  // Close the quantity dialog first
                  Navigator.of(dialogContext).pop();

                  // Show payment method selection
                  final paymentMethod =
                      await showModalBottomSheet<PaymentMethod>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (c) => PaymentSelectionBottomSheet(
                      onSelected: (m) => Navigator.of(c).pop(m),
                    ),
                  );

                  if (paymentMethod == null) return; // User cancelled

                  final success = await ref
                      .read(inventoryServiceProvider)
                      .updateProductItem(
                        item.id,
                        stockQuantity: newStockQuantity,
                      );

                  if (success) {
                    await ref.read(transactionServiceProvider).addTransaction(
                          productId: item.id,
                          itemName: item.name,
                          quantity: quantityToSell,
                          price: item.price,
                          cost: item.cost,
                          transactionType: TransactionType.sale,
                          paymentMethod: paymentMethod,
                          customerId: customerId,
                        );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}
