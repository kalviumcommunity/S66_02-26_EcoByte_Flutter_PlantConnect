import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Module 3.46 — Theme State Management
///
/// Persists the user's theme choice via SharedPreferences so it
/// survives app restarts.
class ThemeProvider extends ChangeNotifier {
  static const _prefKey = 'theme_mode';

  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  bool get isDark => _mode == ThemeMode.dark;

  /// Load saved preference (called once at startup)
  Future<void> loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    _mode = switch (saved) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
    notifyListeners();
  }

  /// Toggle dark / light
  Future<void> toggleTheme(bool isDark) async {
    _mode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, isDark ? 'dark' : 'light');
  }

  /// Set a specific ThemeMode (system / light / dark)
  Future<void> setThemeMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, mode.name);
  }
}
