import 'package:flutter/material.dart';

// This class creates a widget that blocks the back button
// Perfect for screens where you don't want the user to go back with the device back button
class NoBackWidget extends StatelessWidget {
  final Widget child;

  const NoBackWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // This disables the back button
      child: child,
    );
  }
}
