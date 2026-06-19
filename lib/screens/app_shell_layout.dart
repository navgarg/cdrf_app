import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nariudyam/models/business_domain.dart';
import 'package:nariudyam/screens/profile/fav_customers_screen.dart';
import 'package:nariudyam/screens/schedule/schedule.dart';
import 'package:nariudyam/screens/customer_order.dart';
import 'package:nariudyam/models/business_domain.dart';
import '../components/cart_bottom_sheet.dart';
import 'package:nariudyam/providers/auth_providers.dart';
import '../components/customer_order_service_fab.dart';
import '../services/admin/admin_provider.dart';
import '../l10n/dynamic_localizations.dart';

// firebase (previous implementation)
// import 'package:nariudyam/services/api/auth_service.dart';

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
    '/resource_centre': 'Resource Centre',
    '/admin': 'Admin Portal',
    '/admin/users': 'Manage Users',
    '/admin/analytics': 'Analytics',
    '/admin/resources': 'Resources',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final Map<String, String> routeTitles = {
      '/dashboard': context.tr('Dashboard'),
      '/inventory': context.tr('Inventory'),
      '/schedule': context.tr('Schedule'),
      '/customer_order': context.tr('Customer Order'),
      '/profile': context.tr('Profile'),
      '/advanced_analytics': context.tr('Advanced Analytics'),
      '/resource_centre': context.tr('Resource Centre'),
      '/admin': context.tr('Admin Portal'),
      '/admin/users': context.tr('Manage Users'),
      '/admin/analytics': context.tr('Analytics'),
      '/admin/resources': context.tr('Resources'),
    };
    final String pageTitle =
        routeTitles[currentPath ?? ''] ?? context.tr('Nari Udyam');
    final isAdmin = ref.watch(isAdminProvider);
    final bool showBackButton = !_isDirectNavigationRoute(currentPath, isAdmin);
    final cartCountLabel = _cartCountLabel(ref);

    void showCartSheet() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const CartBottomSheet(),
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
                    if (currentPath == '/dashboard')
                      const SizedBox(width: 48)
                    else
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white),
                        onPressed: () {
                          if (GoRouter.of(context).canPop()) {
                            context.pop();
                          } else {
                            context.go(_fallbackRoute(isAdmin));
                          }
                        },
                        padding: EdgeInsets.zero,
                        iconSize: 22,
                      ),
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
                        icon: _CartIconBadge(countLabel: cartCountLabel),
                        onPressed: showCartSheet,
                        iconSize: 28,
                      )
                    else if (currentPath == '/dashboard')
                      IconButton(
                        icon:
                            const Icon(Icons.help_outline, color: Colors.white),
                        onPressed: () => context.push('/faqs'),
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
        currentIndex: _getSelectedIndex(currentPath, isAdmin),
        onTap: (index) => _onItemTapped(context, index, isAdmin),
        items: isAdmin
            ? [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home),
                  activeIcon: const Icon(Icons.home_filled),
                  label: context.tr('Home'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.people),
                  activeIcon: const Icon(Icons.people_alt),
                  label: context.tr('Users'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.analytics),
                  activeIcon: const Icon(Icons.analytics),
                  label: context.tr('Analytics'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.folder),
                  activeIcon: const Icon(Icons.folder),
                  label: context.tr('Resources'),
                ),
              ]
            : [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home),
                  activeIcon: const Icon(Icons.home_filled),
                  label: context.tr('Home'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.inventory_2_outlined),
                  activeIcon: const Icon(Icons.inventory_2),
                  label: context.tr('Inventory'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.event_available_outlined),
                  activeIcon: const Icon(Icons.event_available),
                  label: context.tr('Schedule'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.shopping_basket_outlined),
                  activeIcon: const Icon(Icons.shopping_basket),
                  label: context.tr('Order'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_outline),
                  activeIcon: const Icon(Icons.person),
                  label: context.tr('Profile'),
                ),
              ],
      ),
      floatingActionButton: _buildFab(context, ref),
    );
  }

  int _getSelectedIndex(String? path, bool isAdmin) {
    if (isAdmin) {
      if (path!.startsWith('/admin/users')) return 1;
      if (path.startsWith('/admin/analytics')) return 2;
      if (path.startsWith('/admin/resources')) return 3;
      if (path.startsWith('/admin')) return 0;
      return 0;
    } else {
      if (path!.startsWith('/dashboard')) return 0;
      if (path.startsWith('/inventory')) return 1;
      if (path.startsWith('/schedule')) return 2;
      if (path.startsWith('/customer_order')) return 3;
      if (path.startsWith('/profile')) return 4;
      return 0; // Default to home
    }
  }

  bool _isDirectNavigationRoute(String? path, bool isAdmin) {
    if (path == null) return true;
    if (isAdmin) {
      return path == '/admin' ||
          path == '/admin/users' ||
          path == '/admin/analytics' ||
          path == '/admin/resources';
    }

    return path == '/dashboard' ||
        path == '/inventory' ||
        path == '/schedule' ||
        path == '/customer_order' ||
        path == '/profile';
  }

  String _fallbackRoute(bool isAdmin) {
    return isAdmin ? '/admin' : '/dashboard';
  }

  String? _cartCountLabel(WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final totalQuantity =
        cart.values.fold<double>(0, (total, quantity) => total + quantity);
    if (totalQuantity <= 0) return null;
    if (totalQuantity > 99) return '99+';
    if (totalQuantity % 1 == 0) return totalQuantity.toStringAsFixed(0);
    return totalQuantity.toStringAsFixed(1);
  }

  Widget? _buildFab(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final isService = BusinessDomainUtils.isServiceDomain(user?.businessDomain);
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
      case String path when path.startsWith('/customer_order') && isService:
        return const CustomerOrderServiceFab();
      default:
        return null;
    }
  }

  void _onItemTapped(BuildContext context, int index, bool isAdmin) {
    final String destination;
    if (isAdmin) {
      switch (index) {
        case 0:
          destination = '/admin';
          break;
        case 1:
          destination = '/admin/users';
          break;
        case 2:
          destination = '/admin/analytics';
          break;
        case 3:
          destination = '/admin/resources';
          break;
        default:
          destination = '/admin';
      }
    } else {
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
    }
    if ((currentPath ?? '') != destination) {
      context.go(destination);
    }
  }
}

class _CartIconBadge extends StatelessWidget {
  final String? countLabel;

  const _CartIconBadge({required this.countLabel});

  @override
  Widget build(BuildContext context) {
    final hasItems = countLabel != null;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          hasItems ? Icons.shopping_cart : Icons.shopping_cart_outlined,
          color: Colors.white,
        ),
        if (hasItems)
          Positioned(
            right: -8,
            top: -8,
            child: Container(
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border:
                    Border.all(color: Theme.of(context).colorScheme.primary),
              ),
              child: Text(
                countLabel!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
