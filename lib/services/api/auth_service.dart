import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../models/user.dart';
import '../general/messenger.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final userProvider = StateProvider<UserModel?>((ref) => null);

final userBusinessIdProvider = Provider<String?>((ref) {
  final user = ref.watch(userProvider);
  return user?.businessDomain;
});

class AuthService {
  final Ref _ref;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthService(this._ref);

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Future<void> _refreshUserProvider() async {
  //   final user = currentUser;
  //   if (user == null) return;
  //
  //   final userDoc = await _firestore.collection('users').doc(user.uid).get();
  //   if (userDoc.exists) {
  //     final userModel = UserModel.fromFirestore(userDoc);
  //     _ref.read(userProvider.notifier).state = userModel;
  //   }
  // }

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

  Future<bool> _signInWithCredential(AuthCredential credential) async {
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
        onboardingCompleted: false,
      );

      await userRef.set(newUser.toMap());
      _ref.read(userProvider.notifier).state = newUser;
    }

    // await _refreshUserProvider();
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

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final user = currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update(data);
      // After updating, refresh the user provider to reflect changes immediately
      final updatedDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (updatedDoc.exists) {
        final userModel = UserModel.fromFirestore(updatedDoc);
        _ref.read(userProvider.notifier).state = userModel;
      }
    } catch (e) {
      _ref
          .read(messengerProvider)
          .showError('Failed to update profile: ${e.toString()}');
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return false;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      if (kDebugMode &&
          (googleAuth.idToken == null || googleAuth.idToken!.isEmpty)) {
        // Helpful hint during development when idToken is missing.
        debugPrint(
            '[AuthService] Google idToken is null. Ensure google-services.json is up to date and default_web_client_id exists (add SHA-1/256 in Firebase > Android app, then re-download google-services.json).');
      }
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _signInWithCredential(credential);
    } on PlatformException catch (e) {
      // Surface common Google Play Services errors with better context.
      final code = e.code.isNotEmpty ? e.code : 'platform_error';
      final details = e.details?.toString() ?? '';
      final message = e.message ?? '';
      _ref
          .read(messengerProvider)
          .showError('Google Sign-In failed ($code). $message $details'.trim());
      if (kDebugMode) {
        debugPrint(
            '[AuthService] PlatformException during Google Sign-In: code=$code, message=$message, details=$details');
      }
      return false;
    } catch (e) {
      _ref
          .read(messengerProvider)
          .showError('Google Sign-In failed: ${e.toString()}');
      return false;
    }
  }
}
