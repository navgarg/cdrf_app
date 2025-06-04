import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/general/settings.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  final settingsService = ref.watch(settingsProvider);
  final isDarkMode = settingsService.getBool('dark_mode_enabled') ?? false;
  return ThemeNotifier(isDarkMode);
});

class ThemeNotifier extends StateNotifier<ThemeData> {
  final bool _isDarkMode;

  ThemeNotifier(this._isDarkMode)
      : super(
          _isDarkMode ? _darkTheme : _lightTheme,
        );
  // Custom colors for orange theme
  static const Color _primaryColor =
      Color(0xFFF77D3F); // Primary color for buttons
  static const Color _cardColor = Color(0xFFFFC897); // Card color
  static const Color _backgroundColor =
      Color(0xFFFFE8CD); // Background surface color
  static const Color _appBarColor =
      Color(0xFFFFAF69); // App bar/bottom bar color

  static final _lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.light,
      primary: _primaryColor,
      surface: _backgroundColor,
      onSurface: Colors.black87,
      secondary: _appBarColor,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: _backgroundColor,
    cardColor: _cardColor,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: _appBarColor,
      foregroundColor: Colors.white,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _appBarColor,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
  static final _darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.dark,
      primary: _primaryColor.withValues(alpha: 0.8),
      secondary: _appBarColor.withValues(alpha: 0.7),
      surface: const Color(0xFF1F1F1F),
      onSurface: Colors.white,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF1F1F1F),
    cardColor: _cardColor.withValues(alpha: 0.15),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: _appBarColor.withValues(alpha: 0.7),
      foregroundColor: Colors.white,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _appBarColor.withValues(alpha: 0.7),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: _primaryColor.withValues(alpha: 0.8),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: Colors.grey.shade900,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
}
