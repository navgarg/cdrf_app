import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nariudyam/components/generic_list_tile.dart';
import 'package:nariudyam/models/product_item.dart';
import 'package:nariudyam/services/api/inventory_service.dart';
import '../app_shell_layout.dart';
import 'add_inventory_item_form.dart';
import 'inventory_item_detail_screen.dart';
import 'package:nariudyam/l10n/app_localizations.dart';

final inventoryItemsProvider =
    StreamProvider.autoDispose<List<ProductItem>>((ref) {
  return ref.watch(inventoryServiceProvider).streamInventoryProductItems();
});

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  void _showAddInventoryItemDialog() {
    final appLocalizations = AppLocalizations.of(context);
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withAlpha((0.5 * 255).round()),
      barrierDismissible: true,
      barrierLabel: appLocalizations?.addInventoryItem ?? "",
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
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(animation),
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
    return Consumer(
      builder: (context, watch, child) {
        final inventoryItemsAsyncValue = watch.watch(inventoryItemsProvider);

        return inventoryItemsAsyncValue.when(
          data: (items) {
            if (items.isEmpty) {
              return Center(
                child: Text(AppLocalizations.of(context)!.noInventoryItemsFound),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return GenericListTile(
                  leading: const Icon(Icons.inventory_2,
                      color: Colors.black, size: 28),
                  titleWidget: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${item.stockQuantity} ${item.unit}',
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '₹${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.grey),
                    ],
                  ),
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    barrierColor: Colors.black.withAlpha((0.5 * 255).round()),
                    builder: (context) =>
                        InventoryItemDetailScreen(itemId: item.id),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text(AppLocalizations.of(context)!.errorFetchingInventoryItems(error.toString()))),
        );
      },
    );
  }
}
