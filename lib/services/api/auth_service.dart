import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user.dart';
import '../general/messenger.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final userProvider = StateProvider<UserModel?>((ref) => null);

class AuthService {
  final Ref _ref;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthService(this._ref);

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String, int?) onCodeSent,
    required Function(String) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed (rare on most devices)
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId, resendToken);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      _ref
          .read(messengerProvider)
          .showError('Failed to verify phone number: ${e.toString()}');
      rethrow;
    }
  }

  Future<bool> verifyOtpAndSignIn(String verificationId, String smsCode) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      return await _signInWithCredential(credential);
    } catch (e) {
      _ref
          .read(messengerProvider)
          .showError('Failed to verify OTP: ${e.toString()}');
      return false;
    }
  }

  Future<bool> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      // Sign in with the credential
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        await _handleUserLogin(user);
        return true;
      }
      return false;
    } catch (e) {
      _ref.read(messengerProvider).showError('Sign-in failed: ${e.toString()}');
      return false;
    }
  }

  Future<void> _handleUserLogin(User user) async {
    final now = DateTime.now();

    // Get FCM token for notifications
    final fcmToken = await FirebaseMessaging.instance.getToken();

    // Reference to the user document
    final userRef = _firestore.collection('users').doc(user.uid);

    // Check if the user already exists
    final userDoc = await userRef.get();

    if (userDoc.exists) {
      // Update existing user
      await userRef.update({
        'lastLoginAt': now,
        'deviceToken': fcmToken,
      });

      // Fetch the updated user data
      final updatedDoc = await userRef.get();
      final userModel = UserModel.fromFirestore(updatedDoc);
      _ref.read(userProvider.notifier).state = userModel;
    } else {
      // Create new user
      final newUser = UserModel(
        uid: user.uid,
        phoneNumber: user.phoneNumber ?? '',
        createdAt: now,
        lastLoginAt: now,
        deviceToken: fcmToken,
      );

      await userRef.set(newUser.toMap());
      _ref.read(userProvider.notifier).state = newUser;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _ref.read(userProvider.notifier).state = null;
    } catch (e) {
      _ref
          .read(messengerProvider)
          .showError('Sign out failed: ${e.toString()}');
    }
  }

  User? get currentUser => _auth.currentUser;
}
