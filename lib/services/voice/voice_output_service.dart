import 'package:flutter_tts/flutter_tts.dart';
import '../translation_service.dart';
import 'voice_locale_utils.dart';

class VoiceOutputService {
  VoiceOutputService._();

  static final VoiceOutputService instance = VoiceOutputService._();

  final FlutterTts _tts = FlutterTts();
  bool _configured = false;

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _tts.awaitSpeakCompletion(true);
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _configured = true;
  }

  Future<String> speak({
    required String text,
    required String languageCode,
  }) async {
    await _ensureConfigured();

    final translatedText = await TranslationService().translate(
      text,
      languageCode,
    );

    await _tts.stop();
    await _tts.setLanguage(resolveVoiceLocale(languageCode));
    await _tts.speak(translatedText);
    return translatedText;
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}
