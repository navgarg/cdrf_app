import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../services/translation_service.dart';

/// Dynamic AppLocalizations that translates text on-the-fly using Google Translate
class DynamicAppLocalizations {
  final Locale locale;
  final TranslationService _translationService = TranslationService();

  DynamicAppLocalizations(this.locale);

  /// Helper method to get the current instance from context
  static DynamicAppLocalizations of(BuildContext context) {
    return Localizations.of<DynamicAppLocalizations>(
        context, DynamicAppLocalizations)!;
  }

  /// Translate any text to the current locale
  Future<String> translate(String text) async {
    return await _translationService.translate(text, locale.languageCode);
  }

  /// Synchronous translation - returns cached value or original text
  /// Use this for widget builds to avoid async issues
  String tr(String text) {
    final targetLang = locale.languageCode;

    // Return original for English
    if (targetLang == 'en') return text;

    // Check cache
    if (_translationService.cache[targetLang]?.containsKey(text) ?? false) {
      return _translationService.cache[targetLang]![text]!;
    }

    // Schedule async translation for next time
    _translationService.translate(text, targetLang);

    // Return original text temporarily
    return text;
  }

  static const LocalizationsDelegate<DynamicAppLocalizations> delegate =
      _DynamicAppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('hi'), // Hindi
    Locale('te'), // Telugu
    Locale('ta'), // Tamil
    Locale('kn'), // Kannada
    Locale('ml'), // Malayalam
    Locale('bn'), // Bengali
    Locale('gu'), // Gujarati
    Locale('mr'), // Marathi
    Locale('pa'), // Punjabi
    Locale('ur'), // Urdu
    Locale('es'), // Spanish
    Locale('fr'), // French
    Locale('de'), // German
    Locale('zh'), // Chinese
    Locale('ja'), // Japanese
    Locale('ko'), // Korean
    Locale('ar'), // Arabic
    Locale('ru'), // Russian
    Locale('pt'), // Portuguese
  ];
}

class _DynamicAppLocalizationsDelegate
    extends LocalizationsDelegate<DynamicAppLocalizations> {
  const _DynamicAppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Support all locales - Google Translate supports 100+ languages
    return true;
  }

  @override
  Future<DynamicAppLocalizations> load(Locale locale) async {
    final localizations = DynamicAppLocalizations(locale);
    // Initialize translation service
    await localizations._translationService.initialize();
    return localizations;
  }

  @override
  bool shouldReload(_DynamicAppLocalizationsDelegate old) => true;
}

/// Extension on BuildContext for easy access to translations
extension LocalizationExtension on BuildContext {
  DynamicAppLocalizations get loc => DynamicAppLocalizations.of(this);

  /// Shorthand for translation
  String tr(String text) => DynamicAppLocalizations.of(this).tr(text);
}
