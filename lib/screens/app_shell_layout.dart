import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShellLayout extends StatelessWidget {
  final Widget child;
  final String currentPath;

  const AppShellLayout({
    super.key,
    required this.child,
    required this.currentPath,
  });

  // Map of routes to page titles
  static const Map<String, String> routeTitles = {
    '/dashboard': 'Dashboard',
    '/inventory': 'Inventory',
    '/schedule': 'Schedule',
    '/profile': 'Profile',
  };

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String pageTitle = routeTitles[currentPath] ?? 'Nari Udyam';
    final bool canPop = GoRouter.of(context).canPop();

    return Scaffold(
      body: Column(
        children: [
          // Custom App Bar with rounded bottom corners
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
                    // Back button if there's a page to go back to
                    if (canPop)
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white),
                        onPressed: () => context.pop(),
                        padding: EdgeInsets.zero,
                        iconSize: 22,
                      )
                    else
                      const SizedBox(
                          width: 48), // Space equivalent to the button

                    // Page title and app subtitle
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
                          Text(
                            'Nari Udyam',
                            style: TextStyle(
                              fontFamily: 'Rochester',
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Right-side spacing to balance the UI
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),

          // Main content
          Expanded(
            child: child,
          ),
        ],
      ),

      // Bottom Navigation Bar
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
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Helper method to get the selected index for the bottom navigation
  int _getSelectedIndex(String path) {
    if (path.startsWith('/dashboard')) return 0;
    if (path.startsWith('/inventory')) return 1;
    if (path.startsWith('/schedule')) return 2;
    if (path.startsWith('/profile')) return 3;
    return 0; // Default to home
  }

  // Navigation handler for bottom navigation bar
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
        destination = '/profile';
        break;
      default:
        destination = '/dashboard';
    }

    if (currentPath != destination) {
      context.go(destination);
    }
  }
}
