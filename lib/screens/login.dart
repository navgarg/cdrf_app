import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nariudyam/components/regular_button.dart';
import '../services/api/auth_service.dart';
import '../services/general/messenger.dart';

final loginStateProvider =
    StateProvider<LoginState>((ref) => LoginState.phoneInput);

enum LoginState {
  phoneInput,
  verificationCode,
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _pageController = PageController();
  final _phoneController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _verificationId = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _phoneController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  void _verifyPhone() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final phoneNumber = '+${_phoneController.text.trim()}';

    await ref.read(authServiceProvider).verifyPhoneNumber(
          phoneNumber: phoneNumber,
          onCodeSent: (String verificationId, int? resendToken) {
            _verificationId = verificationId;
            ref.read(loginStateProvider.notifier).state =
                LoginState.verificationCode;
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            setState(() => _isLoading = false);
            ref.read(messengerProvider).showSuccess('Verification code sent!');
          },
          onError: (String message) {
            setState(() => _isLoading = false);
            ref.read(messengerProvider).showError(message);
          },
        );
  }

  void _verifyCode() async {
    if (_verificationCodeController.text.isEmpty) return;

    setState(() => _isLoading = true);

    final verified = await ref.read(authServiceProvider).verifyOtpAndSignIn(
          _verificationId,
          _verificationCodeController.text.trim(),
        );

    setState(() => _isLoading = false);

    if (verified) {
      ref.read(messengerProvider).showSuccess('Successfully logged in!');
    }
  }

  void _resetToPhoneInput() {
    ref.read(loginStateProvider.notifier).state = LoginState.phoneInput;
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goBack() {
    context.replace('/auth');
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginStateProvider);

    return Column(
      children: [
        // Back button header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: loginState == LoginState.verificationCode
                    ? _resetToPhoneInput
                    : _goBack,
              ),
              const Text(
                'Phone Login',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Login form
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildPhoneInputPage(),
              _buildVerificationCodePage(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneInputPage() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter your phone number',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: '+1234567890',
                prefixText: '+',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                if (value.length < 10) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            RegularButton(
                onPressed: _isLoading ? null : _verifyPhone,
                text: _isLoading ? "Loading..." : "Continue"),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationCodePage() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Enter verification code',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Code sent to +${_phoneController.text}',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _verificationCodeController,
            decoration: const InputDecoration(
              labelText: 'Verification Code',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _verifyCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Verify', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
