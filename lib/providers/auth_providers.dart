import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/backend_config.dart';
import '../services/interfaces/i_auth_service.dart';
import '../services/api/auth_service_supabase.dart';
import '../services/adapters/firebase_auth_service_adapter.dart';
import 'shared_providers.dart';

export 'shared_providers.dart' show userProvider, userBusinessIdProvider;

/// Provider that switches between Firebase and Supabase auth implementations
/// based on the backend configuration
final authServiceSwitchProvider = Provider<IAuthService>((ref) {
  final backend = ref.watch(backendProvider);

  if (backend == BackendType.firebase) {
    return FirebaseAuthServiceAdapter(
        ref); // Firebase implementation (no edits)
  } else {
    return AuthServiceSupabase(ref); // Supabase implementation
  }
});

/// Auth state stream that works with both backends
final authStateSwitchProvider = StreamProvider<dynamic>((ref) {
  return ref.watch(authServiceSwitchProvider).authStateChanges;
});

/// Compatibility providers: many files expect these names from the Firebase auth file.
final authServiceProvider = Provider<IAuthService>((ref) {
  return ref.watch(authServiceSwitchProvider);
});

final authStateProvider = StreamProvider<dynamic>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// Keeps `userProvider` in sync on session restore/auth changes.
/// Activated by watching it once (we do that in routerProvider).
final authUserSyncProvider = Provider<void>((ref) {
  void load() {
    // Fire and forget; errors flow to logs.
    ref.read(authServiceProvider).loadUserModel();
  }

  ref.listen(authStateProvider, (previous, next) {
    if (next.valueOrNull != null) {
      load();
    } else {
      ref.read(userProvider.notifier).state = null;
    }
  });

  // Attempt immediate load on provider creation.
  if (ref.read(authServiceProvider).currentUserId != null) {
    load();
  }
});

// Note: userProvider and userBusinessIdProvider are in shared_providers.dart
// and used by both Firebase and Supabase implementations
