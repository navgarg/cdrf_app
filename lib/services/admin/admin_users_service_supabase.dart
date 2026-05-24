import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/user.dart';
import '../interfaces/i_admin_users_service.dart';

class AdminUsersServiceSupabase implements IAdminUsersService {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Stream<List<UserModel>> streamUsers() {
    return _supabase
        .from('users')
        .stream(primaryKey: ['uid'])
        .order('created_at', ascending: false)
        .map((rows) {
          return rows
              .map((row) => UserModel.fromMap(row))
              .toList(growable: false);
        });
  }
}
