import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:nariudyam/providers/inventory_providers.dart';
import 'package:nariudyam/components/item_visual.dart';
import '../app_shell_layout.dart';
import 'add_inventory_item_form.dart';
import 'bulk_voice_inventory_form.dart';
import 'inventory_item_detail_screen.dart';
import 'package:nariudyam/l10n/dynamic_localizations.dart';
import 'package:nariudyam/services/translation_service.dart';
import 'package:nariudyam/utils/app_visuals.dart';

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

  void _showBulkVoiceInventoryDialog(List items) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withAlpha((0.5 * 255).round()),
      barrierDismissible: true,
      barrierLabel: context.tr('Add Stock by Voice'),
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
            child: Material(
              color: Colors.transparent,
              child: BulkVoiceInventoryForm(
                currentItems: items.cast(),
              ),
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
              return _EmptyInventoryState(
                onAddPressed: _showAddInventoryItemDialog,
              );
            }
            final theme = Theme.of(context);
            final onSurface = theme.colorScheme.onSurface;
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: FilledButton.icon(
                    onPressed: () => _showBulkVoiceInventoryDialog(items),
                    icon: const Icon(Icons.mic),
                    label: Text(context.tr('Add Stock by Voice')),
                  ),
                ),
                ...items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final itemName = context.tr(item.name);
                  final itemUnit = context.tr(item.unit);
                  final isLowStock = item.reorderThreshold > 0 &&
                      item.stockQuantity <= item.reorderThreshold;
                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: index == items.length - 1 ? 0 : 12),
                    child: Material(
                      color: theme.cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: isLowStock
                            ? BorderSide(
                                color: theme.colorScheme.error.withAlpha(170),
                                width: 1.5,
                              )
                            : BorderSide.none,
                      ),
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
                              ItemVisual(
                                imageUrl: item.imageUrl,
                                fallbackIcon: AppVisuals.itemIcon(
                                  item.name,
                                  displayedName: itemName,
                                  unit: item.unit,
                                  displayedUnit: itemUnit,
                                ),
                                iconColor: onSurface.withAlpha(153),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      itemName,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        if (isLowStock) ...[
                                          Icon(
                                            Icons.warning_amber_rounded,
                                            size: 16,
                                            color: theme.colorScheme.error,
                                          ),
                                          const SizedBox(width: 4),
                                        ],
                                        Flexible(
                                          child: Text(
                                            isLowStock
                                                ? '${context.tr('Low stock')}: ${item.stockQuantity} $itemUnit'
                                                : '${item.stockQuantity} $itemUnit',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isLowStock
                                                  ? theme.colorScheme.error
                                                  : onSurface.withAlpha(153),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (isLowStock) ...[
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.error
                                              .withAlpha(25),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          context.tr('Restock soon'),
                                          style: TextStyle(
                                            color: theme.colorScheme.error,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
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

class _EmptyInventoryState extends StatelessWidget {
  final VoidCallback onAddPressed;

  const _EmptyInventoryState({
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 72,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              context.tr('No inventory items found.'),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('Add your first product to start taking orders.'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: onSurface.withAlpha(165),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add),
              label: Text(context.tr('Add Product')),
            ),
          ],
        ),
      ),
    );
  }
}
