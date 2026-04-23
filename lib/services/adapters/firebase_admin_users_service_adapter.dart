import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/user.dart';
import '../interfaces/i_admin_users_service.dart';

class FirebaseAdminUsersServiceAdapter implements IAdminUsersService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<UserModel>> streamUsers() {
    return _firestore.collection('users').snapshots().map((snap) {
      return snap.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList(growable: false);
    });
  }
}
