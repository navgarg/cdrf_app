import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:nariudyam/providers/inventory_providers.dart';
import '../app_shell_layout.dart';
import 'add_inventory_item_form.dart';
import 'inventory_item_detail_screen.dart';
import 'package:nariudyam/l10n/dynamic_localizations.dart';
import 'package:nariudyam/services/translation_service.dart';

// firebase (previous implementation)
// import 'package:nariudyam/services/api/inventory_service.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  StreamSubscription? _translationSubscription;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    // Listen for translation updates and trigger rebuild
    _translationSubscription =
        TranslationService().onTranslationUpdated.listen((_) {
      if (_refreshTimer?.isActive ?? false) return;

      _refreshTimer = Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {});
        }
      });
    });
  }

  @override
  void dispose() {
    _translationSubscription?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _showAddInventoryItemDialog() {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withAlpha((0.5 * 255).round()),
      barrierDismissible: true,
      barrierLabel: context.tr('Add Inventory Item'),
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
                child: Text(context.tr('No inventory items found. Add some!')),
              );
            }
            final theme = Theme.of(context);
            final onSurface = theme.colorScheme.onSurface;
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                ...items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: index == items.length - 1 ? 0 : 12),
                    child: Material(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      elevation: 1,
                      shadowColor: Colors.black.withAlpha(25),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          isDismissible: true,
                          enableDrag: true,
                          backgroundColor: Colors.transparent,
                          barrierColor:
                              Colors.black.withAlpha((0.5 * 255).round()),
                          builder: (context) =>
                              InventoryItemDetailScreen(itemId: item.id),
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
                                  color: Colors.white.withAlpha(102),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.inventory_2,
                                    size: 28,
                                    color: onSurface.withAlpha(153),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.tr(item.name),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${item.stockQuantity} ${context.tr(item.unit)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: onSurface.withAlpha(153),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '₹${item.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: onSurface.withAlpha(130),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              Center(child: Text(context.tr('Error: ${error.toString()}'))),
        );
      },
    );
  }
}
