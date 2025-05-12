import 'package:flutter/material.dart';

/// A utility class specifically for navigating in the TaskDetailScreen to avoid logout issues
class TaskDetailNavigation {
  /// Navigate back from task detail screen to the main screen safely
  static void navigateBackToMain(BuildContext context) {
    // Direct navigation with specific settings to stay in the app
    // The rootNavigator: false is crucial to stay within the MainScreen's navigator scope
    Navigator.of(context, rootNavigator: false).pop();
  }
}
