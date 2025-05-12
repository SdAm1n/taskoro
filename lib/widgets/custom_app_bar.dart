import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../localization/translation_helper.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final double height;
  final bool translate;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.height = 60.0,
    this.translate = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final displayTitle = translate ? context.tr(title) : title;

    return AppBar(
      backgroundColor:
          isDarkMode
              ? AppTheme.darkBackgroundColor
              : AppTheme.lightBackgroundColor,
      elevation: 0,
      centerTitle: true,
      title: Text(
        displayTitle,
        style: Theme.of(context).textTheme.displaySmall,
      ),
      leading: leading,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
