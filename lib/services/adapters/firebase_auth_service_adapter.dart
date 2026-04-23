import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user.dart';
import '../api/auth_service.dart' as firebase;
import '../interfaces/i_auth_service.dart';
import '../../providers/shared_providers.dart';

/// Adapter that lets us use the existing Firebase `AuthService` implementation
/// without modifying it, while exposing the shared `IAuthService` contract.
class FirebaseAuthServiceAdapter implements IAuthService {
  final Ref _ref;
  final firebase.AuthService _service;

  FirebaseAuthServiceAdapter(this._ref) : _service = firebase.AuthService(_ref);

  @override
  Stream<dynamic> get authStateChanges => _service.authStateChanges;

  @override
  dynamic get currentUser => _service.currentUser;

  @override
  String? get currentUserId => _service.currentUser?.uid;

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String, int?) onCodeSent,
    required Function(String) onError,
  }) {
    return _service.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onError: onError,
    );
  }

  @override
  Future<bool> verifyOtpAndSignIn(String verificationId, String smsCode) {
    return _service.verifyOtpAndSignIn(verificationId, smsCode);
  }

  @override
  Future<bool> signInWithGoogle() => _service.signInWithGoogle();

  @override
  Future<void> signOut() => _service.signOut();

  @override
  Future<void> updateUserProfile(Map<String, dynamic> data) {
    return _service.updateUserProfile(data);
  }

  @override
  Future<UserModel?> loadUserModel() async {
    final fb.User? user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) {
      _ref.read(userProvider.notifier).state = null;
      return null;
    }

    final firestore = FirebaseFirestore.instance;
    final now = DateTime.now();
    final fcmToken = await FirebaseMessaging.instance.getToken();

    final userRef = firestore.collection('users').doc(user.uid);
    final userDoc = await userRef.get();

    if (userDoc.exists) {
      // Keep this lightweight; don't change fields except ones the original service also updates.
      await userRef.update({
        'lastLoginAt': now,
        'deviceToken': fcmToken,
      });
      final updatedDoc = await userRef.get();
      final model = UserModel.fromFirestore(updatedDoc);
      _ref.read(userProvider.notifier).state = model;
      return model;
    }

    final newUser = UserModel(
      uid: user.uid,
      phoneNumber: user.phoneNumber ?? '',
      createdAt: now,
      lastLoginAt: now,
      deviceToken: fcmToken,
      onboardingCompleted: false,
    );
    await userRef.set(newUser.toMap());
    _ref.read(userProvider.notifier).state = newUser;
    return newUser;
  }
}
