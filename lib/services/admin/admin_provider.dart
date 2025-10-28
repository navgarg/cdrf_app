import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api/auth_service.dart';
import '../../config/admin_config.dart';

/// Provider to check if current user is an admin
final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(userProvider);
  if (user == null) return false;
  return AdminConfig.isAdmin(user.phoneNumber);
});
