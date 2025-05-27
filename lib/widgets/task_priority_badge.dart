import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TaskPriorityBadge extends StatelessWidget {
  final String priority;
  final bool isSmall;

  const TaskPriorityBadge({
    super.key,
    required this.priority,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    String label = priority.toUpperCase();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    switch (priority.toLowerCase()) {
      case 'high':
        badgeColor = AppTheme.accentRed;
        break;
      case 'medium':
        badgeColor = AppTheme.accentYellow;
        break;
      case 'low':
        badgeColor = AppTheme.accentGreen;
        break;
      default:
        badgeColor =
            isDarkMode
                ? AppTheme.darkSecondaryTextColor
                : AppTheme.lightSecondaryTextColor;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(isSmall ? 4 : 6),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: badgeColor,
          fontSize: isSmall ? 10 : 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
