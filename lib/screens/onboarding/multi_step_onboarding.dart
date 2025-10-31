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
      title: 'What age range do you fall into?',
      firestoreField: 'ageRange',
      options: ['18 - 22', '23 - 29', '30-60', '61 and above'],
    ),
    // OnboardingStep(
    //   title: 'Section A. Basic Profile',
    //   isTitle: true,
    // ),
    OnboardingStep(
      title: 'Name of respondent:',
      firestoreField: 'respondentName',
      isTextInput: true,
    ),
    OnboardingStep(
      title: 'Age:',
      firestoreField: 'age',
      isTextInput: true,
    ),
    OnboardingStep(
      title: 'Education level:',
      firestoreField: 'educationLevel',
      options: [
        'No formal schooling',
        'Primary',
        'Secondary',
        'Higher secondary',
        'Graduate'
      ],
    ),
    OnboardingStep(
      title: 'Years running business:',
      firestoreField: 'yearsRunningBusiness',
      isTextInput: true,
    ),
    OnboardingStep(
      title: 'Number of full time employees/helper:',
      firestoreField: 'numEmployees',
      isTextInput: true,
    ),
    OnboardingStep(
      title: 'Ownership type:',
      firestoreField: 'ownershipType',
      options: ['Self-owned', 'Rented space', 'From home'],
    ),
    OnboardingStep(
      title: 'Do you use digital payments (UPI, Paytm, PhonePe, etc.)?',
      firestoreField: 'digitalPayments',
      options: [
        'Yes, openly with all customers',
        'Yes, but only if asked',
        'No'
      ],
    ),
    OnboardingStep(
      title:
          'Do you use social media (Instagram, Facebook, WhatsApp) to promote your product / services ?',
      firestoreField: 'socialMediaPromotion',
      options: ['Regularly', 'Sometimes', 'Never'],
    ),
    // OnboardingStep(
    //   title: 'Section B. Budget Management',
    //   isTitle: true,
    // ),
    OnboardingStep(
      title: 'Do you record your daily income and expenses?',
      firestoreField: 'recordIncomeExpenses',
      options: ['Always', 'Sometimes', 'Never'],
    ),
    OnboardingStep(
      title: 'How do you keep financial records?',
      firestoreField: 'financialRecordsMethod',
      options: ['Notebook', 'Mobile/Excel', 'Memory only', 'Other'],
      isTextInput: true, // For 'Other' option
    ),
    OnboardingStep(
      title:
          'Can you roughly state your monthly profit after deducting expenses?',
      firestoreField: 'monthlyProfit',
      options: ['Yes, accurately', 'Yes, but approximate', 'No idea'],
    ),
    OnboardingStep(
      title: 'Do you separate business money from household money?',
      firestoreField: 'separateBusinessHouseholdMoney',
      options: ['Always', 'Sometimes', 'Never'],
    ),
    OnboardingStep(
      title:
          'Do you save or reinvest part of your earnings for business growth (e.g., new chair, training, décor)?',
      firestoreField: 'saveReinvestForGrowth',
      options: ['Regularly', 'Occasionally', 'Never'],
    ),
    OnboardingStep(
      title: 'Do you use or have access to credit/loans?',
      firestoreField: 'accessToCreditLoans',
      options: [
        'Yes, from SHG',
        'Yes, from bank/MFI',
        'Informal sources',
        'No'
      ],
    ),
    // OnboardingStep(
    //   title: 'Section C. Stock / Inventory Management',
    //   isTitle: true,
    // ),
    OnboardingStep(
      title:
          'How do you know what products (cosmetics, creams, dyes) are available?',
      firestoreField: 'productAvailabilityKnowledge',
      options: ['Written list/register', 'Mobile app', 'Memory only'],
    ),
    OnboardingStep(
      title: 'How often do you check stock levels?',
      firestoreField: 'stockCheckFrequency',
      options: [
        'Daily',
        'Weekly',
        'Only when product finishes',
        'Rarely/Never'
      ],
    ),
    OnboardingStep(
      title: 'Do you ever run out of products when a customer asks?',
      firestoreField: 'runOutOfProducts',
      options: ['Frequently', 'Sometimes', 'Rarely', 'Never'],
    ),
    OnboardingStep(
      title: 'Do you check expiry dates before using products?',
      firestoreField: 'checkExpiryDates',
      options: ['Always', 'Sometimes', 'Never'],
    ),
    OnboardingStep(
      title: 'Do you purchase supplies in bulk to save cost?',
      firestoreField: 'purchaseSuppliesInBulk',
      options: ['Yes, regularly', 'Sometimes', 'No'],
    ),
    OnboardingStep(
      title: 'Do you track which products sell more or less?',
      firestoreField: 'trackProductSales',
      options: ['Yes', 'No'],
    ),
    // OnboardingStep(
    //   title: 'Section D. Customer Engagement',
    //   isTitle: true,
    // ),
    OnboardingStep(
      title: 'Do you maintain a list of your regular customers?',
      firestoreField: 'maintainCustomerList',
      options: [
        'Written register',
        'Mobile/WhatsApp',
        'Only in memory',
        'None'
      ],
    ),
    OnboardingStep(
      title:
          'Do you remember customer preferences (type of cream, hairstyle, etc.)?',
      firestoreField: 'rememberCustomerPreferences',
      options: ['Always', 'Sometimes', 'Rarely'],
    ),
    OnboardingStep(
      title:
          'Do you inform customers about new services/offers/festival packages?',
      firestoreField: 'informCustomersAboutOffers',
      options: [
        'Yes, via WhatsApp/calls',
        'Only when they visit',
        'Not at all'
      ],
    ),
    OnboardingStep(
      title: 'Do you ask customers for feedback or suggestions?',
      firestoreField: 'askForFeedback',
      options: ['Regularly', 'Sometimes', 'Never'],
    ),
    OnboardingStep(
      title: 'Do you give discounts or offers for repeat customers?',
      firestoreField: 'giveDiscountsToRepeatCustomers',
      options: ['Yes, often', 'Sometimes', 'Never'],
    ),
    OnboardingStep(
      title: 'How do you handle customer complaints?',
      firestoreField: 'handleCustomerComplaints',
      options: ['Listen & resolve', 'Ignore', 'No complaints so far'],
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
      if (step.firestoreField != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({step.firestoreField!: value});
      }

      if (isLastStep) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'onboardingCompleted': true});

        context.go('/onboarding/business_domain');
      } else {
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
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _steps.length,
      itemBuilder: (context, index) {
        final step = _steps[index];
        return _buildStepPage(step, index);
      },
    );
  }

  Widget _buildStepPage(OnboardingStep step, int index) {
    if (step.isTextInput == true) {
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
            step.isTitle == true
                ? Text(
                    step.titleText ?? " ",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontFamily: 'PatrickHand',
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : const SizedBox.shrink(),
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
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Enter ${step.title.toLowerCase()}',
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (value) => _onOptionSelected(index, value),
              ),
            ),
          ],
        ),
      );
    } else {
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
            if (step.options != null && step.options!.isNotEmpty)
              ...step.options!.map(
                (option) => Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 24.0),
                  child: RegularButton(
                    text: option,
                    onPressed: () => _onOptionSelected(index, option),
                  ),
                ),
              )
            else
              const SizedBox(height: 16),
          ],
        ),
      );
    }
  }
}
