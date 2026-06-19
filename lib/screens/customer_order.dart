import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nariudyam/components/app_error_state.dart';
import 'package:nariudyam/models/business_domain.dart';
import 'package:nariudyam/models/product_item.dart';
import 'package:nariudyam/models/service_item.dart';
import 'package:nariudyam/components/item_visual.dart';
import 'package:nariudyam/components/loading_cards.dart';
import 'package:nariudyam/components/voice_search_field.dart';
import 'package:nariudyam/models/business_domain.dart';
import 'package:nariudyam/providers/inventory_providers.dart';
import 'package:nariudyam/providers/services_providers.dart';
import 'package:nariudyam/providers/auth_providers.dart';
import 'package:nariudyam/providers/locale_provider.dart';
import 'package:nariudyam/l10n/dynamic_localizations.dart';
import 'package:nariudyam/screens/add_service_item_form.dart';
import 'package:nariudyam/screens/inventory/bulk_voice_sales_form.dart';
import 'package:nariudyam/services/voice/voice_output_service.dart';
import 'package:nariudyam/utils/app_visuals.dart';
import 'package:go_router/go_router.dart';

// firebase (previous implementation)
// import 'package:nariudyam/services/api/inventory_service.dart';
// import 'package:nariudyam/services/api/services_service.dart';
// import 'package:nariudyam/services/api/auth_service.dart';

// Cart stores quantity as double to support fractional (e.g. 0.5 kg) quantities.
final cartProvider = StateNotifierProvider<CartNotifier, Map<String, double>>(
    (ref) => CartNotifier());

class CartNotifier extends StateNotifier<Map<String, double>> {
  CartNotifier() : super({});

  void addToCart(String itemId, {double quantityDelta = 1}) {
    final updatedState = Map<String, double>.from(state);
    updatedState[itemId] = (updatedState[itemId] ?? 0) + quantityDelta;
    state = updatedState;
  }

  void removeFromCart(String itemId, {double quantityDelta = 1}) {
    final current = state[itemId];
    if (current != null) {
      final newQty = current - quantityDelta;
      final updatedState = Map<String, double>.from(state);
      if (newQty > 0) {
        updatedState[itemId] = double.parse(newQty.toStringAsFixed(2));
      } else {
        updatedState.remove(itemId);
      }
      state = updatedState;
    }
  }

  void clearCart() => state = {};
}

class CustomerOrderScreen extends ConsumerStatefulWidget {
  const CustomerOrderScreen({super.key});

  @override
  ConsumerState<CustomerOrderScreen> createState() =>
      _CustomerOrderScreenState();
}

class _CustomerOrderScreenState extends ConsumerState<CustomerOrderScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showBulkVoiceSalesDialog(
    BuildContext context,
    List<BulkVoiceSalesItem> items,
  ) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withAlpha((0.5 * 255).round()),
      barrierDismissible: true,
      barrierLabel: context.tr('Log Today\'s Sales'),
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
              child: BulkVoiceSalesForm(items: items),
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

  void _showAddServiceItemDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withAlpha((0.5 * 255).round()),
      barrierDismissible: true,
      barrierLabel: context.tr('Add Service Item'),
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
              child: AddServiceItemForm(),
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

  void _showAddServiceItemDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withAlpha((0.5 * 255).round()),
      barrierDismissible: true,
      barrierLabel: context.tr('Add Service Item'),
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
              child: AddServiceItemForm(),
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
    final user = ref.watch(userProvider);
    final isService = BusinessDomainUtils.isServiceDomain(user?.businessDomain);

    final itemsAsyncValue = isService
        ? ref.watch(serviceItemsProvider)
        : ref.watch(inventoryItemsProvider);

    // Colors sourced from theme (no hard-coded hex values here)
    final theme = Theme.of(context);
    final itemBlockColor = theme.cardColor;

    return itemsAsyncValue.when(
      data: (items) {
        if (items.isEmpty) {
          return _EmptyOrderState(
            isService: isService,
            onAddServicePressed: () => _showAddServiceItemDialog(context),
            onOpenInventoryPressed: () => context.go('/inventory'),
          );
        }
        final onSurface = theme.colorScheme.onSurface;
        final query = _searchController.text.trim().toLowerCase();
        final filteredItems = query.isEmpty
            ? items
            : items.where((item) {
                final dynamic orderItem = item;
                final itemName = context.tr(orderItem.name).toLowerCase();
                return itemName.contains(query) ||
                    orderItem.name.toString().toLowerCase().contains(query);
              }).toList(growable: false);
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            VoiceSearchField(
              controller: _searchController,
              hintText: context.tr('Search order items'),
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FilledButton.icon(
                onPressed: () {
                  final voiceItems = items.map((item) {
                    if (item is ProductItem) {
                      return BulkVoiceSalesItem.fromProduct(item);
                    }
                    return BulkVoiceSalesItem.fromService(
                      item as ServiceItem,
                    );
                  }).toList(growable: false);
                  _showBulkVoiceSalesDialog(context, voiceItems);
                },
                icon: const Icon(Icons.mic),
                label: Text(context.tr('Log Today\'s Sales by Voice')),
              ),
            ),
            if (filteredItems.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 48),
                child: _NoOrderSearchResultsState(
                  onClear: () {
                    _searchController.clear();
                    setState(() {});
                  },
                ),
              )
            else
              ...filteredItems.asMap().entries.map((entry) {
                final index = entry.key;
                final dynamic item = entry.value;
                final String itemName = context.tr(item.name);
                final double itemPrice = item.price;
                var itemUnit = '';
                final String itemId = item.id;

                if (!isService && item is ProductItem) {
                  itemUnit = context.tr(item.unit);
                }

                return Padding(
                  padding: EdgeInsets.only(
                      bottom: index == filteredItems.length - 1 ? 0 : 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: itemBlockColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(13),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
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
                              unit: !isService && item is ProductItem
                                  ? item.unit
                                  : null,
                              displayedUnit: itemUnit,
                              isService: isService,
                            ),
                            iconColor: onSurface.withAlpha(153),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(itemName,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: onSurface)),
                                const SizedBox(height: 2),
                                Text(
                                    '₹${itemPrice.toStringAsFixed(2)}${!isService ? ' per $itemUnit' : ''}',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: onSurface.withAlpha(153))),
                              ],
                            ),
                          ),
                          _AddToCartButton(
                            itemId: itemId,
                            itemName: itemName,
                            isService: isService,
                            productItem:
                                !isService && item is ProductItem ? item : null,
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        );
      },
      loading: () => const LoadingCards(),
      error: (error, stack) => AppErrorState(
        title: context.tr('Could not load order items'),
        message: context.tr('Please check your connection and try again.'),
        onRetry: () {
          if (isService) {
            ref.invalidate(serviceItemsProvider);
          } else {
            ref.invalidate(inventoryItemsProvider);
          }
        },
      ),
    );
  }
}

class _NoOrderSearchResultsState extends StatelessWidget {
  final VoidCallback onClear;

  const _NoOrderSearchResultsState({required this.onClear});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(Icons.search_off, size: 56, color: theme.colorScheme.primary),
        const SizedBox(height: 12),
        Text(
          context.tr('No matching order items found.'),
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: onClear,
          icon: const Icon(Icons.close),
          label: Text(context.tr('Clear search')),
        ),
      ],
    );
  }
}

class _EmptyOrderState extends StatelessWidget {
  final bool isService;
  final VoidCallback onAddServicePressed;
  final VoidCallback onOpenInventoryPressed;

  const _EmptyOrderState({
    required this.isService,
    required this.onAddServicePressed,
    required this.onOpenInventoryPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = isService
        ? context.tr('No services found.')
        : context.tr('No products found.');
    final body = isService
        ? context.tr('Add a service so customers can place orders.')
        : context
            .tr('Add products in Inventory so customers can place orders.');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isService
                  ? Icons.design_services_outlined
                  : Icons.shopping_bag_outlined,
              size: 72,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(165),
              ),
            ),
            const SizedBox(height: 20),
            if (isService)
              FilledButton.icon(
                onPressed: onAddServicePressed,
                icon: const Icon(Icons.add),
                label: Text(context.tr('Add Service')),
              )
            else
              FilledButton.icon(
                onPressed: onOpenInventoryPressed,
                icon: const Icon(Icons.inventory_2_outlined),
                label: Text(context.tr('Open Inventory')),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddToCartButton extends ConsumerWidget {
  final String itemId;
  final String itemName;
  final bool isService; // true when business domain is service based
  final ProductItem? productItem;

  const _AddToCartButton({
    required this.itemId,
    required this.itemName,
    required this.isService,
    this.productItem,
  });

  Future<void> _speak(BuildContext context, WidgetRef ref, String text) async {
    await VoiceOutputService.instance.speak(
      text: text,
      languageCode: ref.read(localeProvider).languageCode,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final qtyMap = ref.watch(cartProvider);
    final qty = qtyMap[itemId];
    final notifier = ref.read(cartProvider.notifier);
    const onPrimary = Colors.white;

    // Determine increment size (0.5 for weight-based products with kg unit)
    final bool isWeightProduct =
        !isService && (productItem?.unit.toLowerCase().contains('kg') ?? false);
    final double step = isWeightProduct ? 0.5 : 1.0;

    if (qty == null) {
      return SizedBox(
        width: 104,
        height: 48,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: onPrimary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            elevation: 0,
          ),
          onPressed: () {
            notifier.addToCart(itemId, quantityDelta: step);
            _speak(context, ref, '$itemName added');
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_shopping_cart, size: 17),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  context.tr('Add'),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    String displayQty() {
      if (isWeightProduct) {
        // show 0.5 precision if needed
        final showDecimal = (qty % 1) != 0;
        return '${qty.toStringAsFixed(showDecimal ? 1 : 0)} ${productItem?.unit ?? ''}';
      }
      return qty.toStringAsFixed(0);
    }

    return SizedBox(
      width: 104,
      height: 48,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          children: [
            Expanded(
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.expand(),
                onPressed: () {
                  notifier.removeFromCart(itemId, quantityDelta: step);
                  _speak(context, ref, '$itemName removed');
                },
                icon: const Icon(Icons.remove, color: onPrimary, size: 18),
              ),
            ),
            Text(
              displayQty(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: onPrimary,
              ),
            ),
            Expanded(
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.expand(),
                onPressed: () {
                  notifier.addToCart(itemId, quantityDelta: step);
                  _speak(context, ref, '$itemName added');
                },
                icon: const Icon(Icons.add, color: onPrimary, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
