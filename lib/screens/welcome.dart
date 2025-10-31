import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nariudyam/components/regular_button.dart';
import '../services/api/auth_service.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Login',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),

        // Phone login button
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: RegularButton(
              onPressed: () => context.replace('/auth/phone'),
              text: "Sign in with Phone",
              icon: Icons.phone_android,
            )),
        const SizedBox(height: 16),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: RegularButton(
                onPressed: () {
                  ref.read(authServiceProvider).signInWithGoogle();
                },
                text: "Sign in with Google",
                icon: Icons.email_outlined)),
      ],
    );
  }
}
