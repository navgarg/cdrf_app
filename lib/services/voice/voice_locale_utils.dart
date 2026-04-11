String resolveVoiceLocale(String languageCode) {
  switch (languageCode) {
    case 'hi':
      return 'hi-IN';
    case 'te':
      return 'te-IN';
    case 'ta':
      return 'ta-IN';
    case 'kn':
      return 'kn-IN';
    case 'ml':
      return 'ml-IN';
    case 'bn':
      return 'bn-IN';
    case 'gu':
      return 'gu-IN';
    case 'mr':
      return 'mr-IN';
    case 'pa':
      return 'pa-IN';
    case 'ur':
      return 'ur-IN';
    case 'es':
      return 'es-ES';
    case 'fr':
      return 'fr-FR';
    case 'de':
      return 'de-DE';
    case 'zh':
      return 'zh-CN';
    case 'ja':
      return 'ja-JP';
    case 'ko':
      return 'ko-KR';
    case 'ar':
      return 'ar-SA';
    case 'ru':
      return 'ru-RU';
    case 'pt':
      return 'pt-BR';
    case 'en':
    default:
      return 'en-US';
  }
}
