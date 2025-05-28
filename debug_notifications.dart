import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('=== NOTIFICATION DEBUG TOOL ===');
  
  try {
    final prefs = await SharedPreferences.getInstance();
    
    // Check stored notifications
    final notificationsJson = prefs.getStringList('user_notifications') ?? [];
    print('📱 Stored notifications count: ${notificationsJson.length}');
    
    if (notificationsJson.isNotEmpty) {
      print('📝 Stored notifications:');
      for (int i = 0; i < notificationsJson.length; i++) {
        try {
          final notificationData = json.decode(notificationsJson[i]);
          print('  ${i + 1}. Title: ${notificationData['title']}');
          print('     Message: ${notificationData['message']}');
          print('     Type: ${notificationData['type']}');
          print('     Unread: ${notificationData['isUnread']}');
          print('     Timestamp: ${DateTime.fromMillisecondsSinceEpoch(notificationData['timestamp'])}');
          print('');
        } catch (e) {
          print('  ${i + 1}. ERROR parsing notification: $e');
        }
      }
    } else {
      print('📭 No notifications found in storage');
    }
    
    // Check last generation timestamp
    final lastGenTimestamp = prefs.getInt('last_notification_generation');
    if (lastGenTimestamp != null) {
      final lastGenDate = DateTime.fromMillisecondsSinceEpoch(lastGenTimestamp);
      final timeSince = DateTime.now().difference(lastGenDate);
      print('⏰ Last notification generation: $lastGenDate');
      print('⏳ Time since last generation: ${timeSince.inMinutes} minutes ago');
      print('🔄 Cooldown active: ${timeSince.inHours < 1 ? 'YES' : 'NO'}');
    } else {
      print('⏰ No last generation timestamp found');
    }
    
    // Create a test notification
    print('\n🧪 Creating test notification...');
    final testNotification = {
      'id': 'debug_test_${DateTime.now().millisecondsSinceEpoch}',
      'title': 'Debug Test Notification',
      'message': 'This is a test notification created for debugging',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'type': 0, // taskReminder
      'isUnread': true,
      'relatedTaskId': null,
    };
    
    final updatedNotifications = [...notificationsJson, json.encode(testNotification)];
    await prefs.setStringList('user_notifications', updatedNotifications);
    
    print('✅ Test notification created successfully');
    print('📱 Total notifications now: ${updatedNotifications.length}');
    
  } catch (e) {
    print('❌ Error during debug: $e');
  }
  
  print('\n=== DEBUG COMPLETE ===');
}
