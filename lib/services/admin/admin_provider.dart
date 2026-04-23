import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nariudyam/providers/auth_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/backend_config.dart';
import '../../config/admin_config.dart';

// firebase (previous implementation)
// import '../../services/api/auth_service.dart';

/// Provider to check if current user is an admin
final isAdminProvider = Provider<bool>((ref) {
  final backend = ref.watch(backendProvider);
  final user = ref.watch(userProvider);

  // Firebase rollback/reference behavior: hardcoded list.
  if (backend == BackendType.firebase) {
    if (user == null) return false;
    return AdminConfig.isAdmin(user.phoneNumber);
  }

  // Supabase behavior: use DB flag `public.users.is_admin` (aligns with RLS).
  final adminAsync = ref.watch(_isAdminDbStreamProvider);
  return adminAsync.valueOrNull ?? false;
});

final _isAdminDbStreamProvider = StreamProvider<bool>((ref) {
  final backend = ref.watch(backendProvider);
  if (backend != BackendType.supabase) return Stream.value(false);

  final uid = ref.watch(authServiceProvider).currentUserId;
  if (uid == null) return Stream.value(false);

  final supabase = Supabase.instance.client;
  return supabase
      .from('users')
      .stream(primaryKey: ['uid'])
      .eq('uid', uid)
      .map((rows) {
        if (rows.isEmpty) return false;
        final row = rows.first;
        return (row['is_admin'] as bool?) ?? false;
      });
});
