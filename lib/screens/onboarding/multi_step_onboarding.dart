import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../components/regular_button.dart';
import '../../models/onboarding_step.dart';
import '../../services/api/auth_service.dart';
import '../../services/general/messenger.dart';

class MultiStepOnboardingScreen extends ConsumerStatefulWidget {
  const MultiStepOnboardingScreen({super.key});

  @override
  ConsumerState<MultiStepOnboardingScreen> createState() =>
      _MultiStepOnboardingScreenState();
}

class _MultiStepOnboardingScreenState
    extends ConsumerState<MultiStepOnboardingScreen> {
  final _pageController = PageController();

  // all the onboarding steps
  final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: 'Please select a language',
      firestoreField: 'language',
      options: ['English', 'हिन्दी', 'తెలుగు', 'മലയാളം', 'ಕನ್ನಡ', 'தமிழ்'],
    ),
    OnboardingStep(
      title: "What's your highest education?",
      firestoreField: 'education',
      options: [
        'Below Highschool',
        'Highschool',
        "Bachelor's Degree",
        'Not Educated'
      ],
    ),
    OnboardingStep(
      title: 'What age range do you fall into?',
      firestoreField: 'ageRange',
      options: ['18 - 22', '23 - 29', '30-60', '61 and above'],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onOptionSelected(int stepIndex, String value) async {
    final user = ref.read(userProvider);
    if (user == null) return;

    final step = _steps[stepIndex];
    final isLastStep = stepIndex == _steps.length - 1;

    try {
      // Update the specific field in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({step.firestoreField: value});

      if (isLastStep) {
        // If this was the last step, mark onboarding as complete
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'onboardingCompleted': true});

        context.go('/onboarding/business_domain');
      } else {
        // Animate to the next page
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      ref.read(messengerProvider).showError('Failed to save progress: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      // Prevent the user from swiping manually
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _steps.length,
      itemBuilder: (context, index) {
        final step = _steps[index];
        return _buildStepPage(step, index);
      },
    );
  }

  Widget _buildStepPage(OnboardingStep step, int index) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Hello!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 36,
              fontFamily: 'PatrickHand',
              fontWeight: FontWeight.w800,

            ),
          ),
          const Text(
            "Please answer the following:",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w200,

            ),
          ),
          const SizedBox(height: 8),
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontFamily: 'PatrickHand',
              fontWeight: FontWeight.w500,

            ),
          ),
          ...step.options.map(
            (option) => Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
              child: RegularButton(
                text: option,
                onPressed: () => _onOptionSelected(index, option),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
