import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Enum to specify which backend to use
enum BackendType {
  firebase,
  supabase,
}

/// Provider that controls which backend is active
/// Change this one line to switch between Firebase and Supabase
final backendProvider = StateProvider<BackendType>((ref) {
  return BackendType.supabase; // Default to Supabase (current target)
});

/// Helper to check if we're using Firebase
final isFirebaseProvider = Provider<bool>((ref) {
  return ref.watch(backendProvider) == BackendType.firebase;
});

/// Helper to check if we're using Supabase
final isSupabaseProvider = Provider<bool>((ref) {
  return ref.watch(backendProvider) == BackendType.supabase;
});
