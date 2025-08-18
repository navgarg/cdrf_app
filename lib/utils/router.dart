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
import '../services/api/auth_service.dart';
import 'package:nariudyam/screens/profile/fav_customers_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = ref.watch(userProvider);

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

      if (!isAuthenticated && !isAuthRoute) {
        return '/auth';
      }

      // if (isAuthenticated && isAuthRoute) {
      //   return '/dashboard';
      // }

      if (isAuthenticated) {
        if (user == null) return null; // Waiting for user data to load

        if (isAuthRoute) {
          // If first-time onboarding is not done, send to multi-step screen.
          if (!user.onboardingCompleted) {
            return '/onboarding/multi_step';
          }
          // If onboarding is done, send to business domain selection.
          else {
            return '/onboarding/business_domain';
          }
        }
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

//add financial info to onboarding
//barcode scanning for info
