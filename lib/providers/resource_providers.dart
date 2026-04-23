import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/backend_config.dart';
import '../services/interfaces/i_resource_service.dart';
import '../services/resource/resource_service_supabase.dart';
import '../services/adapters/firebase_resource_service_adapter.dart';

/// Provider that switches between Firebase Storage and Supabase Storage implementations
/// based on the backend configuration
final resourceServiceSwitchProvider = Provider<IResourceService>((ref) {
  final backend = ref.watch(backendProvider);

  if (backend == BackendType.firebase) {
    return FirebaseResourceServiceAdapter(); // Firebase implementation (no edits)
  } else {
    return ResourceServiceSupabase(); // Supabase implementation
  }
});

/// Compatibility provider for existing call sites.
final resourceServiceProvider = Provider<IResourceService>((ref) {
  return ref.watch(resourceServiceSwitchProvider);
});
