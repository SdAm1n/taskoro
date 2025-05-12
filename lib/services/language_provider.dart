import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  // Define supported languages
  static const String english = 'en';
  static const String bangla = 'bn';

  // Default language
  String _currentLanguage = english;

  String get currentLanguage => _currentLanguage;

  bool get isEnglish => _currentLanguage == english;
  bool get isBangla => _currentLanguage == bangla;

  // Initialize provider and load saved language preference
  Future<void> initLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('language') ?? english;
    notifyListeners();
  }

  // Change language
  Future<void> setLanguage(String languageCode) async {
    if (_currentLanguage != languageCode) {
      _currentLanguage = languageCode;

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', languageCode);

      notifyListeners();
    }
  }

  // Get language name for display
  String getLanguageName() {
    switch (_currentLanguage) {
      case bangla:
        return 'বাংলা';
      case english:
      default:
        return 'English';
    }
  }
}
