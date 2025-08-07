import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nariudyam/services/api/inventory_service.dart';
import 'package:nariudyam/services/api/transaction_service.dart';
import 'package:nariudyam/models/transaction.dart';
import '../../models/inventory_item.dart';

class InventoryItemDetailScreen extends ConsumerWidget {
  // final InventoryItem item;
  final String itemId;

  const InventoryItemDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(inventoryItemProvider(itemId));

    return itemAsync.when(
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                    _buildActionButton(context, Icons.shopping_cart, 'Order', item, ref),
                    // _buildActionButton(context, Icons.swap_horiz, 'Transfer'),
                    _buildActionButton(
                        context, Icons.attach_money_outlined, 'Sell', item, ref),
                  ],
                ),
                const SizedBox(height: 24.0),
                _buildDetailRow(context, 'Amount',
                    '${item.stockQuantity} ${item.unit}'),
                _buildDetailRow(context, 'Reorder Threshold',
                    '${item.reorderThreshold} ${item.unit}'),
                _buildDetailRow(context, 'Locations', item.location ?? 'N/A'),
                _buildDetailRow(
                    context, 'Description', item.description ?? 'N/A'),
                _buildDetailRow(context, 'Stock value',
                    '₹${(item.price * item.stockQuantity).toStringAsFixed(2)}'),
                _buildDetailRow(
                    context, 'Last purchased',
                    item.lastPurchasedDate
                            ?.toLocal()
                            .toString()
                            .split(' ')[0] ??
                        'N/A'),
                _buildDetailRow(
                    context, 'Last used',
                    item.lastUsedDate
                            ?.toLocal()
                            .toString()
                            .split(' ')[0] ??
                        'N/A'),
                _buildDetailRow(context, 'Last price',
                    '₹${item.price.toStringAsFixed(2)} per ${item.unit}'),
                _buildDetailRow(context, 'Average price',
                    '₹${item.cost.toStringAsFixed(2)} per ${item.unit}'),
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

  Widget _buildActionButton(BuildContext context, IconData icon, String label, InventoryItem item, WidgetRef ref) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: () {
            if (label == 'Sell') {
              _showSellDialog(context, item, ref);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('$label action for ${item.name}')),
              );
            }
          },
        ),
        Text(label),
      ],
    );
  }


  void _showSellDialog(BuildContext context, InventoryItem item, WidgetRef ref) {
    // These are created here and will be garbage collected when the dialog closes.
    final quantityController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Sell Item'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity to sell'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a quantity';
                }
                final quantity = int.tryParse(value);
                if (quantity == null || quantity <= 0) {
                  return 'Please enter a valid positive number';
                }
                if (quantity > item.stockQuantity) {
                  return 'Not enough stock. Available: ${item.stockQuantity}';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Sell'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final quantityToSell = int.parse(quantityController.text);
                  final newStockQuantity =
                      item.stockQuantity - quantityToSell;

                  final success = await ref
                      .read(inventoryServiceProvider)
                      .updateInventoryItem(
                    item.id,
                    stockQuantity: newStockQuantity,
                  );

                  if (success) {
                    await ref.read(transactionServiceProvider).addTransaction(
                      productId: item.id,
                      quantity: quantityToSell,
                      price: item.price,
                      transactionType: TransactionType.sale,
                    );
                    Navigator.of(dialogContext).pop();
                  } else {
                    // if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Failed to update inventory or record transaction.')),
                      );
                    // }
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
