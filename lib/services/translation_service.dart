import 'package:translator/translator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

class _TranslationRequest {
  final String text;
  final String targetLanguage;
  final Completer<String> completer;

  _TranslationRequest(this.text, this.targetLanguage, this.completer);
}

/// Service for dynamic translation using Google Translate (using this instead of the old static translations now)
class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  final GoogleTranslator _translator = GoogleTranslator();
  final Map<String, Map<String, String>> _cache = {};
  static const String _cacheKey = 'translation_cache';
  bool _isInitialized = false;

  final List<_TranslationRequest> _queue = [];
  bool _isProcessingQueue = false;

  final _updateController = StreamController<void>.broadcast();
  Stream<void> get onTranslationUpdated => _updateController.stream;

  Map<String, Map<String, String>> get cache => _cache;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString(_cacheKey);

      if (cachedData != null) {
        final Map<String, dynamic> decoded = json.decode(cachedData);
        decoded.forEach((key, value) {
          _cache[key] = Map<String, String>.from(value);
        });
      }
      _isInitialized = true;
    } catch (e) {
      print('Error loading translation cache: $e');
      _isInitialized = true;
    }
  }

  // Translate text to target language
  Future<String> translate(String text, String targetLanguage) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (targetLanguage == 'en' || text.isEmpty) {
      return text;
    }

    if (_cache[targetLanguage]?.containsKey(text) ?? false) {
      return _cache[targetLanguage]![text]!;
    }

    final completer = Completer<String>();
    _queue.add(_TranslationRequest(text, targetLanguage, completer));

    if (!_isProcessingQueue) {
      _processQueue();
    }

    return completer.future;
  }

  Future<void> _processQueue() async {
    if (_isProcessingQueue) return;
    _isProcessingQueue = true;

    while (_queue.isNotEmpty) {
      final request = _queue.removeAt(0);

      if (_cache[request.targetLanguage]?.containsKey(request.text) ?? false) {
        request.completer
            .complete(_cache[request.targetLanguage]![request.text]);
        continue;
      }

      try {
        // Translate using Google Translate
        final translation = await _translator.translate(
          request.text,
          from: 'en',
          to: request.targetLanguage,
        );

        _cache[request.targetLanguage] ??= {};
        _cache[request.targetLanguage]![request.text] = translation.text;

        _saveCacheToStorage();

        request.completer.complete(translation.text);

        _updateController.add(null);

        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        print(
            'Translation error for "${request.text}" to ${request.targetLanguage}: $e');
        request.completer.complete(request.text);
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    _isProcessingQueue = false;
  }

  /// Batch translate multiple texts
  Future<Map<String, String>> translateBatch(
    List<String> texts,
    String targetLanguage,
  ) async {
    final Map<String, String> results = {};

    for (final text in texts) {
      results[text] = await translate(text, targetLanguage);
    }

    return results;
  }

  Future<void> _saveCacheToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(_cache);
      await prefs.setString(_cacheKey, encoded);
    } catch (e) {
      print('Error saving translation cache: $e');
    }
  }

  Future<void> clearCache() async {
    _cache.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
    } catch (e) {
      print('Error clearing translation cache: $e');
    }
  }

  Map<String, int> getCacheStats() {
    final Map<String, int> stats = {};
    _cache.forEach((language, translations) {
      stats[language] = translations.length;
    });
    return stats;
  }
}
