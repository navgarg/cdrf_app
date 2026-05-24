// App-wide constants
// App Info
class AppInfo {
  static const String name = 'Nari Udyam';
}

// Firebase collection names
class FirebaseCollections {
  static const String users = 'users';
}

// Shared Preferences keys
class PreferenceKeys {
  static const String darkModeEnabled = 'dark_mode_enabled';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String userLanguage = 'user_language';
  static const String lastLoginTime = 'last_login_time';
}

// Route names for easy reference
class RouteNames {
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
}

// Messaging constants
class MessageConstants {
  static const Duration defaultSnackbarDuration = Duration(seconds: 3);
  static const Duration longSnackbarDuration = Duration(seconds: 5);
}
