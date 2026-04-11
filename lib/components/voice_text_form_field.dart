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
    return TextFormField(
      controller: controller,
      decoration: decoration.copyWith(
        suffixIcon: IconButton(
          tooltip: 'Voice input',
          icon: Icon(
            isListening ? Icons.mic : Icons.mic_none,
            color: isListening ? Theme.of(context).colorScheme.primary : null,
          ),
          onPressed: onMicTap,
        ),
      ),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }
}
