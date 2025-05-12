// No-op function to handle back navigation more reliably
import 'package:flutter/material.dart';

/// Helper class to manage navigation safely in cases where we've had issues
/// with unintended route changes (like logging out when deleting a task).
class SafeNavigation {
  /// Navigate back safely without triggering unwanted side effects
  static void popScreen(BuildContext context) {
    // Use a short delay to ensure we're not in the middle of a state update
    Future.delayed(const Duration(milliseconds: 50), () {
      if (context.mounted) {
        // Make sure we're using the navigator that won't clear the entire stack
        // Use a simple pop without complex logic
        final navigator = Navigator.of(context, rootNavigator: false);
        navigator.pop();
      }
    });
  }

  /// Safer alternative to pushNamedAndRemoveUntil when navigating with complex flows
  static void navigateAndClearStack(BuildContext context, String routeName) {
    // Use a short delay to ensure we're not in the middle of a state update
    Future.delayed(const Duration(milliseconds: 50), () {
      if (context.mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(routeName, (route) => false);
      }
    });
  }
}
