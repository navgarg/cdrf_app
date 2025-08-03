import 'package:flutter/material.dart';
import '../models/inventory_item.dart';

class InventoryItemDetailScreen extends StatefulWidget {
  final InventoryItem item;

  const InventoryItemDetailScreen({super.key, required this.item});

  @override
  State<InventoryItemDetailScreen> createState() =>
      _InventoryItemDetailScreenState();
}

class _InventoryItemDetailScreenState extends State<InventoryItemDetailScreen> {
  @override
  Widget build(BuildContext context) {
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
                  widget.item.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16.0),
                _buildDetailRow('Amount',
                    '${widget.item.stockQuantity} ${widget.item.unit}'),
                _buildDetailRow('Reorder Threshold',
                    '${widget.item.reorderThreshold} ${widget.item.unit}'),
                _buildDetailRow('Locations', 'N/A'),
                _buildDetailRow(
                    'Description', widget.item.description ?? 'N/A'),
                _buildDetailRow('Next due date', 'N/A'),
                _buildDetailRow('Stock value',
                      '₹${(widget.item.price * widget.item.stockQuantity).toStringAsFixed(2)}'),
                _buildDetailRow('Last purchased', 'N/A'),
                _buildDetailRow('Last used', 'N/A'),
                _buildDetailRow('Last price',
                      '₹${widget.item.price.toStringAsFixed(2)} per ${widget.item.unit}'),
                _buildDetailRow('Average price',
                      '₹${widget.item.cost.toStringAsFixed(2)} per ${widget.item.unit}'),
                const SizedBox(height: 24.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildActionButton(
                        context, Icons.shopping_cart, 'Purchase'),
                    _buildActionButton(context, Icons.swap_horiz, 'Transfer'),
                    _buildActionButton(context, Icons.delete, 'Consume'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
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

  Widget _buildActionButton(BuildContext context, IconData icon, String label) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: () {
            // Handle action
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$label action for ${widget.item.name}')),
            );
          },
        ),
        Text(label),
      ],
    );
  }
}
