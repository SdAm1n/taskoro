import 'package:flutter/material.dart';
import 'app_localizations.dart';

// Extension to provide easy access to the localization
extension LocalizationExtension on BuildContext {
  AppLocalizations get translate => AppLocalizations.of(this)!;

  String tr(String key) {
    return AppLocalizations.of(this)?.translate(key) ?? key;
  }
}
