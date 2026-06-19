import '../../models/user.dart';

/// Abstract interface for authentication services
/// Both Firebase and Supabase implementations must follow this contract
abstract class IAuthService {
  /// Stream of authentication state changes
  Stream<dynamic> get authStateChanges;

  /// Get the currently signed-in user (can be Firebase User or Supabase User)
  dynamic get currentUser;

  /// Convenience accessor for the current user's ID (uid/id)
  String? get currentUserId;

  /// Ensure the app-level `userProvider` is populated (if signed in)
  Future<UserModel?> loadUserModel();

  /// Verify phone number and send OTP
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String, int?) onCodeSent,
    required Function(String) onError,
  });

  /// Verify OTP code and sign in
  Future<bool> verifyOtpAndSignIn(String verificationId, String smsCode);

  /// Sign in with Google
  Future<bool> signInWithGoogle();

  /// Sign out the current user
  Future<void> signOut();

  /// Update user profile data
  Future<void> updateUserProfile(Map<String, dynamic> data);
}
