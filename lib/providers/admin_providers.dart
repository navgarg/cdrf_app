import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/backend_config.dart';
import '../services/interfaces/i_admin_analytics_service.dart';
import '../services/interfaces/i_admin_users_service.dart';
import '../services/adapters/firebase_admin_analytics_service_adapter.dart';
import '../services/admin/admin_analytics_service_supabase.dart';
import '../services/adapters/firebase_admin_users_service_adapter.dart';
import '../services/admin/admin_users_service_supabase.dart';
import '../models/user.dart';

final adminAnalyticsServiceSwitchProvider =
    Provider<IAdminAnalyticsService>((ref) {
  final backend = ref.watch(backendProvider);
  if (backend == BackendType.firebase) {
    return FirebaseAdminAnalyticsServiceAdapter();
  }
  return AdminAnalyticsServiceSupabase();
});

final adminAnalyticsServiceProvider = Provider<IAdminAnalyticsService>((ref) {
  return ref.watch(adminAnalyticsServiceSwitchProvider);
});

final adminUsersServiceSwitchProvider = Provider<IAdminUsersService>((ref) {
  final backend = ref.watch(backendProvider);
  if (backend == BackendType.firebase) {
    return FirebaseAdminUsersServiceAdapter();
  }
  return AdminUsersServiceSupabase();
});

final adminUsersServiceProvider = Provider<IAdminUsersService>((ref) {
  return ref.watch(adminUsersServiceSwitchProvider);
});

final adminUsersStreamProvider = StreamProvider<List<UserModel>>((ref) {
  return ref.watch(adminUsersServiceProvider).streamUsers();
});
