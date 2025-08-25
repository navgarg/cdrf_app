import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nariudyam/screens/profile/fav_customers_screen.dart';
import 'package:nariudyam/screens/schedule/schedule.dart';

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
