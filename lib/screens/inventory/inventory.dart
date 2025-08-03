import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/inventory_item.dart';
import '../../services/general/inventory_service.dart';
import '../../components/generic_list_tile.dart';
import '../app_shell_layout.dart';
import 'add_inventory_item_form.dart';
import 'inventory_item_detail_screen.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}


class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  void _showAddInventoryItemDialog() {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withAlpha((0.5 * 255).round()),
      barrierDismissible: true,
      barrierLabel: 'Add Inventory Item',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: const Material(
              color: Colors.transparent,
              child: AddInventoryItemForm(),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(animation),
          child: child,
        );
      },
    );
  }
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(inventoryFabPressedProvider, (_, isPressed) {
      if (isPressed) {
        _showAddInventoryItemDialog();
        ref.read(inventoryFabPressedProvider.notifier).state = false;
      }
    });
    final inventoryService = ref.watch(inventoryServiceProvider);

    return FutureBuilder<List<InventoryItem>>(
      future: inventoryService.getInventoryItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No inventory items found.'));
        } else {
          final inventoryItems = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: inventoryItems.length,
            itemBuilder: (context, index) {
              final item = inventoryItems[index];
              return GenericListTile(
                leading: const Icon(Icons.inventory_2, color: Colors.black, size: 28),
                titleWidget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${item.stockQuantity} ${item.unit}',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '₹${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ],
                ),
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  barrierColor: Colors.black.withAlpha((0.5 * 255).round()),
                  builder: (context) => InventoryItemDetailScreen(item: item),
                ),
              );
            },
          );
        }
      },
    );
  }
}
