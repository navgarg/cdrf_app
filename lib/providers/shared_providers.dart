import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';

/// Shared user provider used by both Firebase and Supabase implementations
/// This provider stores the current authenticated user's data
final userProvider = StateProvider<UserModel?>((ref) => null);

/// Provider that returns the current user's business id.
///
/// Current assumption: 1 user = 1 business, so businessId == uid.
final userBusinessIdProvider = Provider<String?>((ref) {
  final user = ref.watch(userProvider);
  return user?.uid;
});
