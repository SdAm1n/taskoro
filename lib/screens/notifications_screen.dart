import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/task_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationItem> _notifications = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNotifications();
    });
  }

  void _initializeNotifications() {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    setState(() {
      _notifications = _getNotifications(taskProvider);
    });
  }

  void _removeNotification(int index) {
    setState(() {
      _notifications.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppTheme.darkBackgroundColor
              : AppTheme.lightBackgroundColor,
      appBar: CustomAppBar(title: 'Notifications'),
      body:
          _notifications.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return _buildNotificationItem(context, notification, index);
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
    int index,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key(
        notification.timestamp.toString() + (notification.relatedTaskId ?? ''),
      ),
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
        _removeNotification(index);
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
            // Handle notification tap (e.g., mark as read, navigate to related content)
            if (notification.isUnread) {
              // In a real app, you would update the notification status
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notification marked as read')),
              );
            }

            // Navigate to the related task or screen based on notification type
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

  // Sample notifications for demo purposes
  // In a real app, these would come from a notification service
  List<NotificationItem> _getNotifications(TaskProvider taskProvider) {
    final tasks = taskProvider.tasks;
    final now = DateTime.now();
    final notifications = <NotificationItem>[];

    // Create sample notifications based on existing tasks
    if (tasks.isNotEmpty) {
      // Upcoming task notifications
      final upcomingTasks =
          tasks
              .where(
                (task) =>
                    !task.isCompleted &&
                    task.endDate.isAfter(now) &&
                    task.endDate.difference(now).inDays <= 2,
              )
              .toList();

      for (final task in upcomingTasks) {
        notifications.add(
          NotificationItem(
            title: 'Upcoming Task',
            message:
                '${task.title} is due ${DateFormat('MMM dd').format(task.endDate)}',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            type: NotificationType.taskReminder,
            isUnread: true,
            relatedTaskId: task.id,
          ),
        );
      }

      // Overdue task notifications
      final overdueTasks =
          tasks
              .where((task) => !task.isCompleted && task.endDate.isBefore(now))
              .toList();

      for (final task in overdueTasks) {
        notifications.add(
          NotificationItem(
            title: 'Overdue Task',
            message:
                '${task.title} was due ${DateFormat('MMM dd').format(task.endDate)}',
            timestamp: DateTime.now().subtract(const Duration(hours: 5)),
            type: NotificationType.taskOverdue,
            isUnread: true,
            relatedTaskId: task.id,
          ),
        );
      }

      // Recently completed tasks (as examples of read notifications)
      final completedTasks =
          tasks.where((task) => task.isCompleted).take(2).toList();

      for (final task in completedTasks) {
        notifications.add(
          NotificationItem(
            title: 'Task Completed',
            message: 'You completed "${task.title}"',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            type: NotificationType.taskCompleted,
            isUnread: false,
            relatedTaskId: task.id,
          ),
        );
      }
    }

    // Sort notifications by timestamp (newest first)
    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return notifications;
  }
}

enum NotificationType {
  taskReminder,
  taskOverdue,
  taskCompleted,
  appUpdate,
  systemMessage,
}

class NotificationItem {
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isUnread;
  final String? relatedTaskId;

  NotificationItem({
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isUnread = false,
    this.relatedTaskId,
  });

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
