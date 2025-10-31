import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nariudyam/services/api/inventory_service.dart';
import 'package:nariudyam/services/api/transaction_service.dart';
import 'package:nariudyam/models/transaction.dart';
import 'package:nariudyam/components/payment_selection_bottom_sheet.dart';
import '../../models/product_item.dart';
import 'package:nariudyam/l10n/app_localizations.dart';

class InventoryItemDetailScreen extends ConsumerWidget {
  // final InventoryItem item;
  final String itemId;

  const InventoryItemDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(productItemProvider(itemId));
    final appLocalizations = AppLocalizations.of(context);

    return itemAsync.when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, stack) => Scaffold(
            body: Center(
                child:
                    Text(appLocalizations!.errorFetchingItem(err.toString())))),
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
                        item.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildActionButton(context, Icons.shopping_cart,
                              appLocalizations!.order, item, ref),
                          // _buildActionButton(context, Icons.swap_horiz, 'Transfer'),
                          _buildActionButton(
                              context,
                              Icons.attach_money_outlined,
                              appLocalizations.sell,
                              item,
                              ref),
                        ],
                      ),
                      const SizedBox(height: 24.0),
                      _buildDetailRow(context, appLocalizations.amount,
                          '${item.stockQuantity} ${item.unit}'),
                      _buildDetailRow(
                          context,
                          appLocalizations.reorderThreshold,
                          '${item.reorderThreshold} ${item.unit}'),
                      _buildDetailRow(context, appLocalizations.locations,
                          item.location ?? appLocalizations.notAvailable),
                      _buildDetailRow(context, appLocalizations.description,
                          item.description ?? appLocalizations.notAvailable),
                      _buildDetailRow(context, appLocalizations.stockValue,
                          '₹${(item.price * item.stockQuantity).toStringAsFixed(2)}'),
                      _buildDetailRow(
                          context,
                          appLocalizations.lastPurchased,
                          item.lastPurchasedDate
                                  ?.toLocal()
                                  .toString()
                                  .split(' ')[0] ??
                              appLocalizations.notAvailable),
                      _buildDetailRow(
                          context,
                          appLocalizations.lastSold,
                          item.lastSoldDate
                                  ?.toLocal()
                                  .toString()
                                  .split(' ')[0] ??
                              appLocalizations.notAvailable),
                      _buildDetailRow(context, appLocalizations.lastPrice,
                          '₹${item.price.toStringAsFixed(2)} ${appLocalizations.per} ${item.unit}'),
                      _buildDetailRow(context, appLocalizations.averagePrice,
                          '₹${item.cost.toStringAsFixed(2)} ${appLocalizations.per} ${item.unit}'),
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
    final appLocalizations = AppLocalizations.of(context);
    return Column(
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: () {
            if (label == appLocalizations!.sell) {
              _showSellDialog(context, item, ref);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label action for ${item.name}')),
              );
            }
          },
        ),
        Text(label),
      ],
    );
  }

  void _showSellDialog(BuildContext context, ProductItem item, WidgetRef ref) {
    // These are created here and will be garbage collected when the dialog closes.
    final quantityController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final appLocalizations = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(appLocalizations!.sellItem),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration:
                  InputDecoration(labelText: appLocalizations.quantityToSell),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return appLocalizations.pleaseEnterQuantity;
                }
                final quantity = int.tryParse(value);
                if (quantity == null || quantity <= 0) {
                  return appLocalizations.pleaseEnterValidPositiveNumber;
                }
                if (quantity > item.stockQuantity) {
                  return appLocalizations.notEnoughStock(item.stockQuantity);
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(appLocalizations.cancel),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: Text(appLocalizations.sell),
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
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Sale completed successfully')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text(appLocalizations.failedToUpdateInventory)),
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
