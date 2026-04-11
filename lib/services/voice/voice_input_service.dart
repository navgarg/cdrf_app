import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'voice_locale_utils.dart';

class VoiceInputService {
  VoiceInputService._();

  static final VoiceInputService instance = VoiceInputService._();

  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;

  bool get isListening => _speech.isListening;

  Future<bool> initialize() async {
    if (_initialized) return true;
    _initialized = await _speech.initialize();
    return _initialized;
  }

  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> startListening({
    required String languageCode,
    required void Function(String text, bool isFinal) onResult,
  }) async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return false;

    final ready = await initialize();
    if (!ready) return false;

    if (_speech.isListening) {
      await _speech.stop();
    }

    await _speech.listen(
      localeId: resolveVoiceLocale(languageCode),
      listenFor: const Duration(minutes: 1),
      pauseFor: const Duration(seconds: 4),
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        partialResults: true,
        cancelOnError: true,
      ),
      onResult: (result) {
        onResult(result.recognizedWords, result.finalResult);
      },
    );

    return true;
  }

  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }
}
