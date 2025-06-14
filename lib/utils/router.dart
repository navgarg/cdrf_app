import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nariudyam/screens/onboarding/business_domain.dart';
import 'package:nariudyam/screens/onboarding/multi_step_onboarding.dart';
import '../screens/login.dart';
import '../screens/dashboard.dart';
import '../screens/welcome.dart';
import '../screens/shell_layout.dart';
import '../screens/app_shell_layout.dart';
import '../screens/inventory.dart';
import '../screens/schedule.dart';
import '../screens/profile.dart';
import '../services/api/auth_service.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = ref.watch(userProvider);

  return GoRouter(
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
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const WelcomeScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                final isPopDirection =
                    secondaryAnimation.status == AnimationStatus.forward;

                return SlideTransition(
                  position: Tween<Offset>(
                    begin: isPopDirection
                        ? const Offset(-1.0, 0.0)
                        : const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
            ),
          ),
          GoRoute(
            path: '/auth/phone',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const LoginScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                final isPopDirection =
                    secondaryAnimation.status == AnimationStatus.forward;

                return SlideTransition(
                  position: Tween<Offset>(
                    begin: isPopDirection
                        ? const Offset(-1.0, 0.0)
                        : const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
            ),
          ),
          GoRoute(
            path: '/onboarding/multi_step',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const MultiStepOnboardingScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                final isPopDirection =
                    secondaryAnimation.status == AnimationStatus.forward;

                return SlideTransition(
                  position: Tween<Offset>(
                    begin: isPopDirection
                        ? const Offset(-1.0, 0.0)
                        : const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
            ),
          ),
          GoRoute(
            path: '/onboarding/business_domain',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const BusinessDomainScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                final isPopDirection =
                    secondaryAnimation.status == AnimationStatus.forward;

                return SlideTransition(
                  position: Tween<Offset>(
                    begin: isPopDirection
                        ? const Offset(-1.0, 0.0)
                        : const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
            ),
          ),
        ],
      ),

      // Main App Shell Route
      ShellRoute(
        builder: (context, state, child) {
          return AppShellLayout(
            child: child,
            currentPath: state.matchedLocation,
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
          ),
        ],
      ),
    ],
  );
});
