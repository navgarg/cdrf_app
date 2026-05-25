import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nariudyam/l10n/dynamic_localizations.dart';
import 'package:nariudyam/providers/locale_provider.dart';
import 'package:nariudyam/services/general/messenger.dart';
import 'package:nariudyam/services/voice/voice_input_service.dart';

class VoiceSearchField extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;
  final String hintText;

  const VoiceSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.hintText,
  });

  @override
  ConsumerState<VoiceSearchField> createState() => _VoiceSearchFieldState();
}

class _VoiceSearchFieldState extends ConsumerState<VoiceSearchField> {
  bool _isListening = false;

  @override
  void dispose() {
    if (_isListening) {
      VoiceInputService.instance.stopListening();
    }
    super.dispose();
  }

  Future<void> _listen() async {
    final languageCode = ref.read(localeProvider).languageCode;
    final microphoneError = context.tr('Microphone permission is required.');
    if (_isListening && VoiceInputService.instance.isListening) {
      await VoiceInputService.instance.stopListening();
      if (mounted) setState(() => _isListening = false);
      return;
    }

    final started = await VoiceInputService.instance.startListening(
      languageCode: languageCode,
      onResult: (text, isFinal) {
        if (!mounted) return;
        setState(() {
          widget.controller.text = text.trim();
          widget.controller.selection = TextSelection.fromPosition(
            TextPosition(offset: widget.controller.text.length),
          );
          if (isFinal) _isListening = false;
        });
        widget.onChanged();
      },
    );

    if (!started) {
      ref.read(messengerProvider).showError(microphoneError);
      return;
    }
    if (mounted) setState(() => _isListening = true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: widget.controller,
      onChanged: (_) => widget.onChanged(),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.controller.text.isNotEmpty)
              IconButton(
                tooltip: context.tr('Clear'),
                onPressed: () {
                  widget.controller.clear();
                  widget.onChanged();
                  setState(() {});
                },
                icon: const Icon(Icons.close),
              ),
            IconButton(
              tooltip: context.tr('Search by voice'),
              onPressed: _listen,
              icon: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
