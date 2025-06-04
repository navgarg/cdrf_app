import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/login.dart';
import '../screens/dashboard.dart';
import '../screens/welcome.dart';
import '../services/api/auth_service.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/welcome',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // Loading auth state
      final isLoading = authState.isLoading;
      if (isLoading) return null;

      // Check if the user is authenticated
      final isAuthenticated = authState.valueOrNull != null;

      // Auth paths that don't require redirection
      final isAuthRoute = state.matchedLocation == '/login';
      final isWelcomeRoute = state.matchedLocation == '/welcome';

      // If not logged in and trying to access protected route, redirect to login
      if (!isAuthenticated && !isAuthRoute && !isWelcomeRoute) {
        return '/welcome';
      }

      // If logged in and on an auth route, redirect to home
      if (isAuthenticated && (isAuthRoute || isWelcomeRoute)) {
        return '/dashboard';
      }

      // No redirection needed
      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
  );
});
