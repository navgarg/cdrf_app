import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final settingsProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

class SettingsService {
  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // String settings
  Future<bool> setString(String key, String value) async {
    await _ensureInitialized();
    return await _prefs.setString(key, value);
  }

  String? getString(String key) {
    if (!_initialized) return null;
    return _prefs.getString(key);
  }

  // Bool settings
  Future<bool> setBool(String key, bool value) async {
    await _ensureInitialized();
    return await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    if (!_initialized) return null;
    return _prefs.getBool(key);
  }

  // Int settings
  Future<bool> setInt(String key, int value) async {
    await _ensureInitialized();
    return await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    if (!_initialized) return null;
    return _prefs.getInt(key);
  }

  // Double settings
  Future<bool> setDouble(String key, double value) async {
    await _ensureInitialized();
    return await _prefs.setDouble(key, value);
  }

  double? getDouble(String key) {
    if (!_initialized) return null;
    return _prefs.getDouble(key);
  }

  // Remove setting
  Future<bool> remove(String key) async {
    await _ensureInitialized();
    return await _prefs.remove(key);
  }

  // Check if key exists
  bool containsKey(String key) {
    if (!_initialized) return false;
    return _prefs.containsKey(key);
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await init();
    }
  }
}
