import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/task_provider.dart';
import '../services/notification_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';
import '../utils/notification_extensions.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Remove automatic notification generation that causes notifications to reappear
    // Notifications should only be generated when tasks are created/updated, not when viewing them
  }

  void _generateTaskNotifications() {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    // Generate notifications based on current tasks using TaskProvider method
    taskProvider.generateTaskNotifications();
  }

  void _createSampleNotifications() {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    // Create sample notifications for testing
    taskProvider.createSampleNotifications();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sample notifications created for testing')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppTheme.darkBackgroundColor
              : AppTheme.lightBackgroundColor,
      appBar: CustomAppBar(
        title: 'Notifications',
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, _) {
              if (notificationProvider.hasUnreadNotifications) {
                return TextButton(
                  onPressed: () => notificationProvider.markAllAsRead(),
                  child: Text(
                    'Mark all read',
                    style: TextStyle(color: AppTheme.primaryColor),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, _) {
          final notifications = notificationProvider.notifications;

          if (notifications.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationItem(
                context,
                notification,
                notificationProvider,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.darkDisabledTextColor
                    : AppTheme.lightDisabledTextColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.darkSecondaryTextColor
                      : AppTheme.lightSecondaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll be notified about upcoming tasks and important updates',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.darkDisabledTextColor
                      : AppTheme.lightDisabledTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    NotificationItem notification,
    NotificationProvider notificationProvider,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key(notification.id),
      background: Container(
        decoration: BoxDecoration(
          color: AppTheme.accentRed,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        notificationProvider.removeNotification(notification.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Notification dismissed')));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.darkCardColor : AppTheme.lightCardColor,
          borderRadius: BorderRadius.circular(12),
          border:
              notification.isUnread
                  ? Border.all(color: AppTheme.primaryColor, width: 1.5)
                  : null,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: notification.getIconBackgroundColor(isDarkMode),
              shape: BoxShape.circle,
            ),
            child: Icon(
              notification.getNotificationIcon(),
              color: Colors.white,
              size: 24,
            ),
          ),
          title: Text(
            notification.title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight:
                  notification.isUnread ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification.message,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat(
                  'MMMM dd, yyyy - HH:mm',
                ).format(notification.timestamp),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      isDarkMode
                          ? AppTheme.darkSecondaryTextColor
                          : AppTheme.lightSecondaryTextColor,
                ),
              ),
            ],
          ),
          trailing:
              notification.isUnread
                  ? Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  )
                  : null,
          onTap: () {
            // Mark as read if unread
            if (notification.isUnread) {
              notificationProvider.markAsRead(notification.id);
            }

            // Navigate to related content if available
            if (notification.relatedTaskId != null) {
              Navigator.pushNamed(
                context,
                '/task_detail',
                arguments: {'taskId': notification.relatedTaskId},
              );
            }
          },
        ),
      ),
    );
  }
}
