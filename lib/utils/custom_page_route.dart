import 'package:flutter/material.dart';

class NoBackButtonPageRoute<T> extends MaterialPageRoute<T> {
  NoBackButtonPageRoute({
    required super.builder,
    super.settings,
    super.maintainState,
    super.fullscreenDialog,
  });

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }

  @override
  bool get canPop => false;
}
