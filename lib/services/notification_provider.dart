import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../models/task.dart';

enum NotificationType {
  taskReminder,
  taskOverdue,
  taskCompleted,
  appUpdate,
  systemMessage,
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isUnread;
  final String? relatedTaskId;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isUnread = true,
    this.relatedTaskId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'type': type.index,
      'isUnread': isUnread,
      'relatedTaskId': relatedTaskId,
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      type: NotificationType.values[json['type']],
      isUnread: json['isUnread'] ?? true,
      relatedTaskId: json['relatedTaskId'],
    );
  }

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    bool? isUnread,
    String? relatedTaskId,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isUnread: isUnread ?? this.isUnread,
      relatedTaskId: relatedTaskId ?? this.relatedTaskId,
    );
  }
}

class NotificationProvider with ChangeNotifier {
  List<NotificationItem> _notifications = [];
  static const String _notificationsKey = 'user_notifications';
  static const String _lastGenerationKey = 'last_notification_generation';
  DateTime? _lastNotificationGeneration;

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => n.isUnread).length;

  bool get hasUnreadNotifications => unreadCount > 0;

  NotificationProvider() {
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getStringList(_notificationsKey) ?? [];

      // Load last generation timestamp
      final lastGenTimestamp = prefs.getInt(_lastGenerationKey);
      if (lastGenTimestamp != null) {
        _lastNotificationGeneration = DateTime.fromMillisecondsSinceEpoch(
          lastGenTimestamp,
        );
      }

      _notifications =
          notificationsJson
              .map((jsonStr) => NotificationItem.fromJson(json.decode(jsonStr)))
              .toList();

      // Sort by timestamp (newest first)
      _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson =
          _notifications
              .map((notification) => json.encode(notification.toJson()))
              .toList();

      await prefs.setStringList(_notificationsKey, notificationsJson);
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }

  Future<void> addNotification(NotificationItem notification) async {
    // Check if a similar notification already exists to avoid duplicates
    final existingIndex = _notifications.indexWhere(
      (n) =>
          n.type == notification.type &&
          n.relatedTaskId == notification.relatedTaskId &&
          n.title == notification.title,
    );

    if (existingIndex == -1) {
      _notifications.insert(0, notification);
      await _saveNotifications();
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && _notifications[index].isUnread) {
      _notifications[index] = _notifications[index].copyWith(isUnread: false);
      await _saveNotifications();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    bool hasChanges = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].isUnread) {
        _notifications[i] = _notifications[i].copyWith(isUnread: false);
        hasChanges = true;
      }
    }

    if (hasChanges) {
      await _saveNotifications();
      notifyListeners();
    }
  }

  Future<void> removeNotification(String notificationId) async {
    final initialLength = _notifications.length;
    _notifications.removeWhere((n) => n.id == notificationId);

    if (_notifications.length != initialLength) {
      await _saveNotifications();
      notifyListeners();
    }
  }

  Future<void> clearAllNotifications() async {
    if (_notifications.isNotEmpty) {
      _notifications.clear();
      // Reset last generation timestamp when manually clearing all notifications
      _lastNotificationGeneration = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastGenerationKey);
      await _saveNotifications();
      notifyListeners();
    }
  }

  // Generate notifications based on tasks
  Future<void> generateTaskNotifications(List<Task> tasks) async {
    final now = DateTime.now();

    // Only generate notifications if it's been more than 1 hour since last generation
    // or if it's the first time
    if (_lastNotificationGeneration != null) {
      final timeSinceLastGeneration = now.difference(
        _lastNotificationGeneration!,
      );
      if (timeSinceLastGeneration.inHours < 1) {
        debugPrint(
          'Skipping notification generation - too recent (${timeSinceLastGeneration.inMinutes} minutes ago)',
        );
        return;
      }
    }

    debugPrint('Generating task notifications...');

    // Clear old task-related notifications first
    await _clearTaskNotifications();

    // Generate upcoming task notifications (tasks due within 2 days)
    for (final task in tasks) {
      if (!task.isCompleted && task.endDate.isAfter(now)) {
        final daysUntilDue = task.endDate.difference(now).inDays;

        if (daysUntilDue <= 2) {
          await addNotification(
            NotificationItem(
              id: 'task_reminder_${task.id}',
              title: 'Upcoming Task',
              message:
                  '${task.title} is due ${DateFormat('MMM dd').format(task.endDate)}',
              timestamp: now,
              type: NotificationType.taskReminder,
              relatedTaskId: task.id,
            ),
          );
        }
      }
    }

    // Generate overdue task notifications
    for (final task in tasks) {
      if (!task.isCompleted && task.endDate.isBefore(now)) {
        await addNotification(
          NotificationItem(
            id: 'task_overdue_${task.id}',
            title: 'Overdue Task',
            message:
                '${task.title} was due ${DateFormat('MMM dd').format(task.endDate)}',
            timestamp: now,
            type: NotificationType.taskOverdue,
            relatedTaskId: task.id,
          ),
        );
      }
    }

    // Update last generation timestamp
    _lastNotificationGeneration = now;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastGenerationKey, now.millisecondsSinceEpoch);

    debugPrint('Task notifications generated successfully');
  }

  Future<void> _clearTaskNotifications() async {
    final initialLength = _notifications.length;
    _notifications.removeWhere(
      (n) =>
          n.type == NotificationType.taskReminder ||
          n.type == NotificationType.taskOverdue,
    );

    if (_notifications.length != initialLength) {
      await _saveNotifications();
    }
  }

  // Add notification for completed task
  Future<void> addTaskCompletedNotification(Task task) async {
    await addNotification(
      NotificationItem(
        id: 'task_completed_${task.id}_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Task Completed',
        message: 'You completed "${task.title}"',
        timestamp: DateTime.now(),
        type: NotificationType.taskCompleted,
        relatedTaskId: task.id,
        isUnread: false, // Mark as read since it's a positive notification
      ),
    );
  }

  // Add custom notification
  Future<void> addCustomNotification({
    required String title,
    required String message,
    NotificationType type = NotificationType.systemMessage,
    String? relatedTaskId,
    bool isUnread = true,
  }) async {
    await addNotification(
      NotificationItem(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        message: message,
        timestamp: DateTime.now(),
        type: type,
        relatedTaskId: relatedTaskId,
        isUnread: isUnread,
      ),
    );
  }

  // Generate notification for a newly created task (bypasses cooldown)
  Future<void> generateNotificationForNewTask(Task task) async {
    final now = DateTime.now();

    debugPrint('Generating notification for new task: ${task.title}');

    // Only generate notification if task is not completed
    if (!task.isCompleted) {
      final daysUntilDue = task.endDate.difference(now).inDays;

      // Generate notification for tasks due within 7 days
      if (task.endDate.isAfter(now) && daysUntilDue <= 7) {
        await addNotification(
          NotificationItem(
            id: 'task_reminder_${task.id}',
            title: 'New Task Created',
            message:
                '${task.title} is due ${DateFormat('MMM dd').format(task.endDate)}',
            timestamp: now,
            type: NotificationType.taskReminder,
            relatedTaskId: task.id,
          ),
        );
        debugPrint('Notification created for new task: ${task.title}');
      }
      // Generate notification for overdue tasks (if someone creates a task with past due date)
      else if (task.endDate.isBefore(now)) {
        await addNotification(
          NotificationItem(
            id: 'task_overdue_${task.id}',
            title: 'New Overdue Task',
            message:
                '${task.title} was due ${DateFormat('MMM dd').format(task.endDate)}',
            timestamp: now,
            type: NotificationType.taskOverdue,
            relatedTaskId: task.id,
          ),
        );
        debugPrint('Overdue notification created for new task: ${task.title}');
      }
    }
  }

  // Force regenerate notifications (ignoring time limits)
  Future<void> forceGenerateTaskNotifications(List<Task> tasks) async {
    debugPrint('Force generating task notifications...');
    _lastNotificationGeneration = null; // Reset timestamp to force regeneration
    await generateTaskNotifications(tasks);
  }
}
