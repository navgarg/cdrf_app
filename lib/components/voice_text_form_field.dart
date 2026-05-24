import 'package:flutter/material.dart';

class VoiceTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final InputDecoration decoration;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int? maxLines;
  final VoidCallback onMicTap;
  final bool isListening;

  const VoiceTextFormField({
    super.key,
    required this.controller,
    required this.decoration,
    required this.onMicTap,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.isListening = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      decoration: decoration.copyWith(
        suffixIcon: IconButton(
          tooltip: 'Voice input',
          style: IconButton.styleFrom(
            backgroundColor: isListening
                ? theme.colorScheme.primary
                : theme.colorScheme.primaryContainer,
            foregroundColor: isListening
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.primary,
            minimumSize: const Size(48, 48),
          ),
          icon: Icon(
            isListening ? Icons.mic : Icons.mic_none,
            size: 30,
          ),
          onPressed: onMicTap,
        ),
      ),
      style: theme.textTheme.bodyLarge,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }
}
