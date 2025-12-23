import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nariudyam/screens/onboarding/business_domain.dart';
import 'package:nariudyam/screens/onboarding/multi_step_onboarding.dart';
import '../screens/onboarding/login.dart';
import '../screens/shell_layout.dart';
import '../screens/dashboard.dart';

import '../screens/welcome.dart';
import '../screens/app_shell_layout.dart';
import '../screens/inventory/inventory.dart';
import '../screens/schedule/schedule.dart';
import '../screens/profile/profile.dart';
import '../screens/resource_center/resource_center.dart';
import '../screens/analytics/advanced_analytics_screen.dart';
import '../services/api/auth_service.dart';
import '../services/admin/admin_provider.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/admin_users.dart';
import '../screens/admin/admin_analytics.dart';
import 'package:nariudyam/screens/profile/fav_customers_screen.dart';
import '../screens/customer_order.dart';
import '../screens/faqs/faqs_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = ref.watch(userProvider);
  final isAdmin = ref.watch(isAdminProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/auth',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // final isLoading = authState.isLoading;
      // if (isLoading) return null;
      final isLoading = authState.isLoading || authState.isReloading;
      if (isLoading || authState.hasError) return null;

      final isAuthenticated = authState.valueOrNull != null;

      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isAdminRoute = state.matchedLocation.startsWith('/admin');

      if (!isAuthenticated && !isAuthRoute) {
        return '/auth';
      }

      // if (isAuthenticated && isAuthRoute) {
      //   return '/dashboard';
      // }

      if (isAuthenticated) {
        if (user == null) return null; // Waiting for user data to load

        if (isAuthRoute) {
          // Check if user is admin
          if (isAdmin) {
            return '/admin';
          }

          // If first-time onboarding is not done, send to multi-step screen.
          if (!user.onboardingCompleted) {
            return '/onboarding/multi_step';
          }
          // If onboarding is done, send to dashboard
          else {
            return '/dashboard';
          }
        }

        // Redirect non-admin users away from admin routes
        if (isAdminRoute && !isAdmin) {
          return '/dashboard';
        }

        // Redirect admin users to admin portal if they try to access regular app
        if (!isAdminRoute &&
            isAdmin &&
            state.matchedLocation.startsWith('/dashboard')) {
          return '/admin';
        }

        // If user is on a valid route (dashboard, inventory, schedule, profile, etc.),
        // don't redirect even if user data updates (e.g., language change)
        // This prevents unwanted redirects when updating profile settings
      }

      return null;
    },
    routes: [
      // Authentication Shell Route (Onboarding)
      ShellRoute(
        builder: (context, state, child) {
          return OnboardingLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/auth',
            pageBuilder: (context, state) => _buildPageWithSlideTransition(
              path: state.matchedLocation,
              child: const WelcomeScreen(),
            ),
          ),
          GoRoute(
            path: '/auth/phone',
            pageBuilder: (context, state) => _buildPageWithSlideTransition(
              path: state.matchedLocation,
              child: const LoginScreen(),
            ),
          ),
          GoRoute(
            path: '/onboarding/multi_step',
            pageBuilder: (context, state) => _buildPageWithSlideTransition(
              path: state.matchedLocation,
              child: const MultiStepOnboardingScreen(),
            ),
          ),
          GoRoute(
            path: '/onboarding/business_domain',
            pageBuilder: (context, state) => _buildPageWithSlideTransition(
              path: state.matchedLocation,
              child: const BusinessDomainScreen(),
            ),
          ),
        ],
      ),

      // Main App Shell Route
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          String? currentSubtitle;
          if (state.matchedLocation.startsWith('/inventory')) {
            currentSubtitle = 'Stock Overview';
          } else {
            currentSubtitle = 'Nari Udyam'; // Default subtitle
          }
          return AppShellLayout(
            currentPath: state.fullPath ?? '',
            subtitle: currentSubtitle,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/inventory',
            builder: (context, state) => const InventoryScreen(),
          ),
          GoRoute(
            path: '/schedule',
            builder: (context, state) => const ScheduleScreen(),
          ),
          GoRoute(
            path: '/customer_order',
            builder: (context, state) => const CustomerOrderScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'favourite_customers',
                builder: (context, state) => const FavouriteCustomersScreen(),
                parentNavigatorKey: _shellNavigatorKey,
              ),
            ],
          ),
          GoRoute(
            path: '/advanced_analytics',
            builder: (context, state) => const AdvancedAnalyticsScreen(),
          ),
          GoRoute(
            path: '/resource_centre',
            builder: (context, state) => const ResourceCenterScreen(),
          ),
        ],
      ),

      // FAQs route outside the shell for full-screen presentation
      GoRoute(
        path: '/faqs',
        builder: (context, state) => const FaqsScreen(),
      ),

      // Admin Shell Route (reuses AppShellLayout with bottom navigation)
      ShellRoute(
        builder: (context, state, child) {
          return AppShellLayout(
            currentPath: state.fullPath ?? '',
            subtitle: 'Nari Udyam',
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: '/admin/users',
            builder: (context, state) => const AdminUsersScreen(),
          ),
          GoRoute(
            path: '/admin/analytics',
            builder: (context, state) => const AdminAnalyticsScreen(),
          ),
          GoRoute(
            path: '/admin/resources',
            builder: (context, state) => const ResourceCenterScreen(),
          ),
        ],
      ),
    ],
  );
});

CustomTransitionPage<void> _buildPageWithSlideTransition({
  required String path,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: ValueKey(path),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final isPopDirection =
          secondaryAnimation.status == AnimationStatus.forward;

      return SlideTransition(
        position: Tween<Offset>(
          begin:
              isPopDirection ? const Offset(-1.0, 0.0) : const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
    },
  );
}

/*
//barcode scanning for info

//todo:
//feedback in excel
//graphs for individual inv item

//which gives max revenue
//which service gave max customer satisfaction
//which item had max demand
//cost vs revenue
//for items - reorder threshold
//focus on beauty parlor + stationary

- chatbot for users?


resource centre
unique logo for app
admin portal to download analytics

english, hindi and telugu language support
customer satisfaction trends
% of online/offline transactions - using payment mode used
different colors for diff categories

card payment method
faqs page for owners
montHly reports for inv
one button for all items - purchased date, quantity, price


testing?
diff mobile phones
put on playstore?

*/
