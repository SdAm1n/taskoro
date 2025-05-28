import 'package:flutter/material.dart';
import '../services/notification_provider.dart';
import '../theme/app_theme.dart';

extension NotificationItemExtensions on NotificationItem {
  IconData getNotificationIcon() {
    switch (type) {
      case NotificationType.taskReminder:
        return Icons.access_time;
      case NotificationType.taskOverdue:
        return Icons.warning_amber_rounded;
      case NotificationType.taskCompleted:
        return Icons.check_circle;
      case NotificationType.appUpdate:
        return Icons.system_update;
      case NotificationType.systemMessage:
        return Icons.notifications;
    }
  }

  Color getIconBackgroundColor(bool isDarkMode) {
    switch (type) {
      case NotificationType.taskReminder:
        return AppTheme.primaryColor;
      case NotificationType.taskOverdue:
        return AppTheme.accentRed;
      case NotificationType.taskCompleted:
        return AppTheme.accentGreen;
      case NotificationType.appUpdate:
        return AppTheme.accentBlue;
      case NotificationType.systemMessage:
        return isDarkMode
            ? AppTheme.darkSecondaryTextColor
            : AppTheme.lightSecondaryTextColor;
    }
  }
}
