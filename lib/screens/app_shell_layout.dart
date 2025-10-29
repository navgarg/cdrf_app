import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nariudyam/screens/profile/fav_customers_screen.dart';
import 'package:nariudyam/screens/schedule/schedule.dart';
import '../components/cart_bottom_sheet.dart';
import 'package:nariudyam/services/api/auth_service.dart';
import '../components/customer_order_service_fab.dart';
import '../services/admin/admin_provider.dart';
import 'package:nariudyam/l10n/app_localizations.dart';

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
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    final Map<String, String> routeTitles = {
      '/dashboard': appLocalizations.dashboard,
      '/inventory': appLocalizations.inventory,
      '/schedule': appLocalizations.schedule,
      '/customer_order': appLocalizations.customerOrder,
      '/profile': appLocalizations.profile,
    };
    final String pageTitle = routeTitles[currentPath ?? ''] ?? appLocalizations.appName;
    final bool isTopLevelRoute = routeTitles.keys.contains(currentPath);
    final bool showBackButton =
        GoRouter.of(context).canPop() && !isTopLevelRoute;
    final isAdmin = ref.watch(isAdminProvider);

    void _showCartSheet() {
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
            ? const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'Users',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.analytics),
                  label: 'Analytics',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.folder),
                  label: 'Resources',
                ),
              ]
            : [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home),
                  label: appLocalizations.home,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.inventory),
                  label: appLocalizations.inventory,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.calendar_today),
                  label: appLocalizations.schedule,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.shopping_cart),
                  label: appLocalizations.order,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person),
                  label: appLocalizations.profile,
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

  Widget? _buildFab(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final isService = user?.businessDomain == 'Beauty Parlor';
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
