class OnboardingStep {
  final String title;
  final String? firestoreField;
  final List<String>? options;
  final bool? isTitle;
  final String? titleText;
  final bool? isTextInput;

  OnboardingStep({
    required this.title,
    this.firestoreField,
    this.options,
    this.titleText,
    this.isTitle = false,
    this.isTextInput = false,
  });
}
