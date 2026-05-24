import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Firebase/legacy-style Google flow (rollback reference):
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../../models/user.dart';
import '../general/messenger.dart';
import '../interfaces/i_auth_service.dart';
import '../../providers/shared_providers.dart';

/// Supabase implementation of authentication service
class AuthServiceSupabase implements IAuthService {
  final Ref _ref;
  final SupabaseClient _supabase = Supabase.instance.client;

  // Rollback (previous approach): native GoogleSignIn instance.
  /*
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '', // Your Google OAuth client ID
  );
  */

  static const String _oauthRedirectUrl =
      'io.supabase.flutter://login-callback/';

  static const Set<String> _onboardingSnakeCaseFields = {
    'language',
    'education',
    'age_range',
    'respondent_name',
    'age',
    'education_level',
    'years_running_business',
    'num_employees',
    'ownership_type',
    'digital_payments',
    'social_media_promotion',
    'record_income_expenses',
    'financial_records_method',
    'monthly_profit',
    'separate_business_household_money',
    'save_reinvest_for_growth',
    'access_to_credit_loans',
    'product_availability_knowledge',
    'stock_check_frequency',
    'run_out_of_products',
    'check_expiry_dates',
    'purchase_supplies_in_bulk',
    'track_product_sales',
    'maintain_customer_list',
    'remember_customer_preferences',
    'inform_customers_about_offers',
    'ask_for_feedback',
    'give_discounts_to_repeat_customers',
    'handle_customer_complaints',
    'onboarding_completed',
  };

  AuthServiceSupabase(this._ref);

  @override
  Stream<User?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.map((data) => data.session?.user);
  }

  @override
  User? get currentUser => _supabase.auth.currentUser;

  @override
  String? get currentUserId => _supabase.auth.currentUser?.id;

  @override
  Future<UserModel?> loadUserModel() async {
    final user = currentUser;
    if (user == null) {
      _ref.read(userProvider.notifier).state = null;
      return null;
    }

    await _handleUserLogin(user);
    return _ref.read(userProvider);
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String, int?) onCodeSent,
    required Function(String) onError,
  }) async {
    try {
      // Supabase sends OTP directly, no verification ID needed
      await _supabase.auth.signInWithOtp(
        phone: phoneNumber,
      );

      // For Supabase, we use the phone number itself as the "verification ID"
      onCodeSent(phoneNumber, null);
    } catch (e) {
      _ref
          .read(messengerProvider)
          .showError('Failed to verify phone number: ${e.toString()}');
      onError(e.toString());
      rethrow;
    }
  }

  @override
  Future<bool> verifyOtpAndSignIn(String verificationId, String smsCode) async {
    try {
      // In Supabase, verificationId is actually the phone number
      final response = await _supabase.auth.verifyOTP(
        type: OtpType.sms,
        phone: verificationId,
        token: smsCode,
      );

      if (response.session != null && response.user != null) {
        await _handleUserLogin(response.user!);
        return true;
      }
      return false;
    } catch (e) {
      _ref
          .read(messengerProvider)
          .showError('Failed to verify OTP: ${e.toString()}');
      return false;
    }
  }

  Future<void> _handleUserLogin(User user) async {
    final now = DateTime.now();

    try {
      // Check if user exists in the users table
      final response = await _supabase
          .from('users')
          .select()
          .eq('uid', user.id)
          .maybeSingle();

      if (response != null) {
        // Update existing user
        await _supabase.from('users').update({
          'last_login_at': now.toIso8601String(),
        }).eq('uid', user.id);

        // Fetch updated user + onboarding data
        final updatedUserData =
            await _supabase.from('users').select().eq('uid', user.id).single();
        final onboardingData = await _supabase
            .from('user_onboarding')
            .select()
            .eq('user_id', user.id)
            .maybeSingle();

        final mergedData = _mergeUserAndOnboardingData(
          userData: updatedUserData,
          onboardingData: onboardingData,
        );

        final userModel = UserModel.fromMap(mergedData);
        _ref.read(userProvider.notifier).state = userModel;
      } else {
        // Create new user
        final newUser = UserModel(
          uid: user.id,
          phoneNumber: user.phone ?? '',
          createdAt: now,
          lastLoginAt: now,
          onboardingCompleted: false,
        );

        await _supabase.from('users').insert({
          'uid': newUser.uid,
          'phone_number': newUser.phoneNumber,
          'name': newUser.name,
          'profile_pic_url': newUser.profilePicUrl,
          'device_token': newUser.deviceToken,
          'created_at': newUser.createdAt.toIso8601String(),
          'last_login_at': newUser.lastLoginAt.toIso8601String(),
          'business_domain': newUser.businessDomain,
          'favourite_customer_ids': newUser.favouriteCustomerIds,
          'financial_transactions_enabled':
              newUser.financialTransactionsEnabled,
          'is_admin': false,
        });

        // ONBOARDING is stored separately (normalized).
        await _supabase.from('user_onboarding').upsert(
          {
            'user_id': newUser.uid,
            'onboarding_completed': newUser.onboardingCompleted,
          },
          onConflict: 'user_id',
        );

        // Rollback (previous approach): store onboarding answers directly on `users`.
        /*
        await _supabase.from('users').update({
          'language': newUser.language,
          'education': newUser.education,
          'age_range': newUser.ageRange,
          'respondent_name': newUser.respondentName,
          'age': newUser.age,
          'education_level': newUser.educationLevel,
          'years_running_business': newUser.yearsRunningBusiness,
          'num_employees': newUser.numEmployees,
          'ownership_type': newUser.ownershipType,
          'digital_payments': newUser.digitalPayments,
          'social_media_promotion': newUser.socialMediaPromotion,
          'record_income_expenses': newUser.recordIncomeExpenses,
          'financial_records_method': newUser.financialRecordsMethod,
          'monthly_profit': newUser.monthlyProfit,
          'separate_business_household_money':
              newUser.separateBusinessHouseholdMoney,
          'save_reinvest_for_growth': newUser.saveReinvestForGrowth,
          'access_to_credit_loans': newUser.accessToCreditLoans,
          'product_availability_knowledge': newUser.productAvailabilityKnowledge,
          'stock_check_frequency': newUser.stockCheckFrequency,
          'run_out_of_products': newUser.runOutOfProducts,
          'check_expiry_dates': newUser.checkExpiryDates,
          'purchase_supplies_in_bulk': newUser.purchaseSuppliesInBulk,
          'track_product_sales': newUser.trackProductSales,
          'maintain_customer_list': newUser.maintainCustomerList,
          'remember_customer_preferences': newUser.rememberCustomerPreferences,
          'inform_customers_about_offers': newUser.informCustomersAboutOffers,
          'ask_for_feedback': newUser.askForFeedback,
          'give_discounts_to_repeat_customers':
              newUser.giveDiscountsToRepeatCustomers,
          'handle_customer_complaints': newUser.handleCustomerComplaints,
          'onboarding_completed': newUser.onboardingCompleted,
        }).eq('uid', user.id);
        */

        _ref.read(userProvider.notifier).state = newUser;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling user login: $e');
      }
      rethrow;
    }
  }

  @override
  Future<bool> signInWithGoogle() async {
    try {
      // Preferred Supabase flow: open browser and redirect back into the app.
      // This avoids per-platform native GoogleSignIn configuration.
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : _oauthRedirectUrl,
      );
      return true;

      // Rollback (previous approach): native GoogleSignIn + signInWithIdToken.
      /*
      final googleUser = await GoogleSignIn(
        serverClientId: '',
      ).signIn();
      if (googleUser == null) return false;

      final googleAuth = await googleUser.authentication;
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );
      if (response.session != null && response.user != null) {
        await _handleUserLogin(response.user!);
        return true;
      }
      return false;
      */
    } catch (e) {
      _ref
          .read(messengerProvider)
          .showError('Google Sign-In failed: ${e.toString()}');
      if (kDebugMode) {
        debugPrint('[AuthServiceSupabase] Google Sign-In error: $e');
      }
      return false;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      // Rollback (previous approach):
      // await _googleSignIn.signOut();
      _ref.read(userProvider.notifier).state = null;
    } catch (e) {
      _ref
          .read(messengerProvider)
          .showError('Sign out failed: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final user = currentUser;
    if (user == null) return;

    try {
      // Convert keys to snake_case for PostgreSQL convention
      final userUpdates = <String, dynamic>{};
      final onboardingUpdates = <String, dynamic>{};

      data.forEach((key, value) {
        final snakeKey = _toSnakeCase(key);
        if (snakeKey == 'uid' || snakeKey == 'user_id') return;

        if (_onboardingSnakeCaseFields.contains(snakeKey)) {
          onboardingUpdates[snakeKey] = value;
        } else {
          userUpdates[snakeKey] = value;
        }
      });

      if (userUpdates.isNotEmpty) {
        await _supabase.from('users').update(userUpdates).eq('uid', user.id);
      }

      if (onboardingUpdates.isNotEmpty) {
        await _supabase.from('user_onboarding').upsert(
          {
            'user_id': user.id,
            ...onboardingUpdates,
          },
          onConflict: 'user_id',
        );
      }

      // Rollback (previous approach): update onboarding fields directly on `users`.
      /*
      final snakeCaseData = <String, dynamic>{};
      data.forEach((key, value) {
        snakeCaseData[_toSnakeCase(key)] = value;
      });
      await _supabase.from('users').update(snakeCaseData).eq('uid', user.id);
      */

      // Refresh user provider (merge users + user_onboarding)
      final updatedUserData =
          await _supabase.from('users').select().eq('uid', user.id).single();
      final updatedOnboardingData = await _supabase
          .from('user_onboarding')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      final mergedData = _mergeUserAndOnboardingData(
        userData: updatedUserData,
        onboardingData: updatedOnboardingData,
      );

      final userModel = UserModel.fromMap(mergedData);
      _ref.read(userProvider.notifier).state = userModel;
    } catch (e) {
      _ref
          .read(messengerProvider)
          .showError('Failed to update profile: ${e.toString()}');
    }
  }

  Map<String, dynamic> _mergeUserAndOnboardingData({
    required Map<String, dynamic> userData,
    required Map<String, dynamic>? onboardingData,
  }) {
    if (onboardingData == null) return userData;

    // Prefer `users` table identity fields.
    final merged = <String, dynamic>{
      ...onboardingData,
      ...userData,
    };

    // Avoid confusing `user_id` with `uid`.
    merged.remove('user_id');
    return merged;
  }

  String _toSnakeCase(String text) {
    return text.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    );
  }
}
