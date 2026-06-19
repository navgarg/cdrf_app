import '../../models/user.dart';

abstract class IAdminUsersService {
  Stream<List<UserModel>> streamUsers();
}
