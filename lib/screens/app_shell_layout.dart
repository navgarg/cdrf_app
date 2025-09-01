import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nariudyam/screens/profile/fav_customers_screen.dart';
import 'package:nariudyam/screens/schedule/schedule.dart';
import 'package:nariudyam/screens/customer_order.dart';
import '../models/item.dart';

final inventoryFabPressedProvider = StateProvider<bool>((ref) => false);

class AppShellLayout extends ConsumerWidget {
  final Widget child;
  final String? currentPath;
  final String? subtitle;

  const AppShellLayout({
    super.key,
    required this.child,
    this.currentPath,
    this.subtitle,
  });

  static const Map<String, String> routeTitles = {
    '/dashboard': 'Dashboard',
    '/inventory': 'Inventory',
    '/schedule': 'Schedule',
    '/customer_order': 'Customer Order',
    '/profile': 'Profile',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final String pageTitle = routeTitles[currentPath ?? ''] ?? 'Nari Udyam';
    final bool isTopLevelRoute = routeTitles.keys.contains(currentPath);
    final bool showBackButton =
        GoRouter.of(context).canPop() && !isTopLevelRoute;

    void _showCartSheet() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Consumer(
            builder: (context, ref, child) {
              final cart = ref.watch(cartProvider);

              // Use shared items data
              final items = ItemData.items;
              double getItemPrice(String name) {
                return ItemData.getItemPrice(name);
              }

              double total = cart.entries.fold(0,
                  (sum, entry) => sum + getItemPrice(entry.key) * entry.value);

              const itemBlockColor = Color(0xFFFFC897);
              const addButtonColor = Color(0xFFF77D3F);
              return Container(
                height: MediaQuery.of(context).size.height * 0.85,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE3C1),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Stack(
                  children: [
                    // Main content with back button header
                    Column(
                      children: [
                        // Header with back button
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: addButtonColor,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20)),
                          ),
                          child: SafeArea(
                            bottom: false,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back_ios_new,
                                      color: Colors.white),
                                  onPressed: () => Navigator.of(context).pop(),
                                  padding: EdgeInsets.zero,
                                ),
                                const Expanded(
                                  child: Text(
                                    'Cart',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(
                                    width: 48), // Balance the back button
                              ],
                            ),
                          ),
                        ),

                        // My Cart title
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          child: const Text(
                            'My Cart:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                        // Cart items list
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 16.0,
                              right: 16.0,
                              bottom: 100.0, // Space for bottom total bar
                            ),
                            child: cart.isEmpty
                                ? const Center(
                                    child: Text(
                                      'Your cart is empty.',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    itemCount: cart.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (context, idx) {
                                      final name = cart.keys.elementAt(idx);
                                      final qty = cart[name]!;
                                      final item = items
                                          .firstWhere((i) => i.name == name);
                                      final price = getItemPrice(name);
                                      final totalPrice = price * qty;

                                      return Container(
                                        decoration: BoxDecoration(
                                          color: itemBlockColor,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.05),
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
                                              // Emoji icon
                                              Container(
                                                width: 50,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    item.icon,
                                                    style: const TextStyle(
                                                        fontSize: 32),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),

                                              // Name and price
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item.name,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      item.price,
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.black
                                                            .withOpacity(0.6),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // Quantity controls
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: addButtonColor,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 8),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        ref
                                                            .read(cartProvider
                                                                .notifier)
                                                            .removeFromCart(
                                                                name);
                                                      },
                                                      child: const Icon(
                                                        Icons.remove,
                                                        color: Colors.white,
                                                        size: 16,
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 12),
                                                      child: Text(
                                                        '$qty kg',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        ref
                                                            .read(cartProvider
                                                                .notifier)
                                                            .addToCart(name);
                                                      },
                                                      child: const Icon(
                                                        Icons.add,
                                                        color: Colors.white,
                                                        size: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              const SizedBox(width: 12),

                                              // Total price
                                              Text(
                                                '₹ ${totalPrice.toStringAsFixed(0)}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.black87,
                                                ),
                                              ),
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

                    // Bottom total section
                    if (cart.isNotEmpty)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: itemBlockColor,
                            borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(20)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, -2),
                              ),
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
                                    const Text(
                                      'To Pay',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      '₹${total.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),

                                // Checkmark button
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: addButtonColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    // Add order completion logic here
                                  },
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    if (showBackButton)
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white),
                        onPressed: () => context.pop(),
                        padding: EdgeInsets.zero,
                        iconSize: 22,
                      )
                    else
                      const SizedBox(width: 48),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            pageTitle,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle!,
                              style: TextStyle(
                                fontFamily: 'Rochester',
                                fontSize: 16,
                                color:
                                    Colors.white.withAlpha((255 * 0.9).round()),
                              ),
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),
                    if (currentPath == '/customer_order')
                      IconButton(
                        icon: const Icon(Icons.shopping_cart,
                            color: Colors.white),
                        onPressed: _showCartSheet,
                        iconSize: 28,
                      )
                    else
                      const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: child,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: Colors.grey,
        currentIndex: _getSelectedIndex(currentPath),
        onTap: (index) => _onItemTapped(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _buildFab(context, ref),
    );
  }

  int _getSelectedIndex(String? path) {
    if (path!.startsWith('/dashboard')) return 0;
    if (path.startsWith('/inventory')) return 1;
    if (path.startsWith('/schedule')) return 2;
    if (path.startsWith('/customer_order')) return 3;
    if (path.startsWith('/profile')) return 4;
    return 0; // Default to home
  }

  FloatingActionButton? _buildFab(BuildContext context, WidgetRef ref) {
    switch (currentPath ?? '') {
      case String path when path.startsWith('/profile/favourite_customers'):
        return FloatingActionButton(
          onPressed: () {
            ref.read(favouriteCustomerFabPressedProvider.notifier).state = true;
          },
          child: const Icon(Icons.add),
        );
      case String path when path.startsWith('/schedule'):
        return FloatingActionButton(
          onPressed: () {
            ref.read(scheduleFabPressedProvider.notifier).state = true;
          },
          child: const Icon(Icons.add),
        );
      case String path when path.startsWith('/inventory'):
        return FloatingActionButton(
          onPressed: () {
            ref.read(inventoryFabPressedProvider.notifier).state = true;
          },
          child: const Icon(Icons.add),
        );
      default:
        return null;
    }
  }

  void _onItemTapped(BuildContext context, int index) {
    final String destination;
    switch (index) {
      case 0:
        destination = '/dashboard';
        break;
      case 1:
        destination = '/inventory';
        break;
      case 2:
        destination = '/schedule';
        break;
      case 3:
        destination = '/customer_order';
        break;
      case 4:
        destination = '/profile';
        break;
      default:
        destination = '/dashboard';
    }
    if ((currentPath ?? '') != destination) {
      context.go(destination);
    }
  }
}
