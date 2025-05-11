import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  static const String _themePreferenceKey = 'isDarkMode';

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  // Load saved theme preference
  Future<void> _loadThemeFromPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool savedIsDarkMode = prefs.getBool(_themePreferenceKey) ?? true;
    _isDarkMode = savedIsDarkMode;
    notifyListeners();
  }

  // Toggle theme between light and dark
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;

    // Save preference
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themePreferenceKey, _isDarkMode);

    notifyListeners();
  }
}
