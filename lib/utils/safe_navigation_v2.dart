import 'package:flutter/material.dart';

/// Enhanced safe navigation utility with more control
class SafeNavigationV2 {
  /// Navigate to the previous screen without risking accidental stack clearance
  static void popToMainScreen(BuildContext context) {
    // Use rootNavigator: false to ensure we don't pop beyond what's expected
    Navigator.of(context, rootNavigator: false).pop();
  }

  /// Navigate back to the specified route with control
  static void popBack(BuildContext context) {
    // Add a delay to ensure the UI is ready for navigation
    Future.delayed(const Duration(milliseconds: 50), () {
      if (context.mounted) {
        // Use the non-root navigator to avoid unwanted pops
        Navigator.of(context, rootNavigator: false).pop();
      }
    });
  }

  /// Navigate to a named route with control
  static void navigateTo(BuildContext context, String routeName) {
    // Add a delay to ensure the UI is ready for navigation
    Future.delayed(const Duration(milliseconds: 50), () {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: false).pushNamed(routeName);
      }
    });
  }
}
