import 'package:flutter/material.dart';
import 'app_localizations_delegate.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  // Helper method to keep the code in the widgets concise
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // Static member to have a simple access to the delegate from the MaterialApp
  static const LocalizationsDelegate<AppLocalizations> delegate =
      AppLocalizationsDelegate();

  // Map of localized strings
  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // General
      'app_name': 'TASKORO',
      'ok': 'OK',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',

      // Navigation
      'home': 'Home',
      'calendar': 'Calendar',
      'analytics': 'Analytics',
      'settings': 'Settings',

      // Home Screen
      'hello': 'Hello,',
      'search_tasks': 'Search tasks...',
      'all': 'All',
      'today': 'Today',
      'upcoming': 'Upcoming',
      'completed': 'Completed',
      'tasks': 'Tasks',
      'no_tasks_found': 'No tasks found',
      'no_completed_tasks': 'You haven\'t completed any tasks yet',
      'no_search_results': 'No tasks match your search',
      'add_task_hint': 'Tap + to add a new task',
      'my_priority_tasks': 'My Priority Tasks',
      'view_all': 'View All',
      'day': 'day',
      'days': 'days',
      'progress': 'Progress',
      'due_date': 'Due Date',

      // Task Details
      'task_details': 'Task Details',
      'start_date': 'Start Date',
      'end_date': 'End Date',
      'status': 'Status',
      'in_progress': 'In Progress',
      'completed_status': 'Completed',
      'description': 'Description',
      'no_description': 'No description provided',
      'created_on': 'Created on',
      'mark_completed': 'Mark as Completed',
      'reopen_task': 'Reopen Task',
      'confirm_delete': 'Are you sure you want to delete this task?',
      'task_deleted': 'Task deleted',
      'task_deleted_error': 'Could not delete task',
      'task_not_found': 'Task not found or was already deleted',

      // Add/Edit Task
      'add_new_task': 'Add New Task',
      'edit_task': 'Edit Task',
      'title': 'Title',
      'task_title': 'Task title',
      'task_description': 'Task description',
      'task_date_range': 'Task Date Range',
      'please_enter_title': 'Please enter a title',
      'priority': 'Priority',
      'high': 'High',
      'medium': 'Medium',
      'low': 'Low',
      'category': 'Category',
      'personal': 'Personal',
      'work': 'Work',
      'shopping': 'Shopping',
      'health': 'Health',
      'study': 'Study',
      'other': 'Other',
      'update_task': 'Update Task',
      'add_task': 'Add Task',

      // Notifications
      'notifications': 'Notifications',
      'no_notifications': 'No notifications yet',
      'notification_hint':
          'You\'ll be notified about upcoming tasks and important updates',
      'notification_dismissed': 'Notification dismissed',
      'notification_read': 'Notification marked as read',

      // Settings
      'app_settings': 'App Settings',
      'language': 'Language',
      'dark_mode': 'Dark Mode',
      'about': 'About',
      'app_version': 'App Version',
      'rate_app': 'Rate App',
      'help_support': 'Help & Support',
      'privacy_policy': 'Privacy Policy',
      'logout': 'Logout',
      'logout_confirm': 'Are you sure you want to logout?',
      'profile': 'Profile',
      'edit_profile': 'Edit Profile',
      'change_language': 'Change Language',
      'select_language': 'Select Language',
      'english': 'English',
      'bangla': 'Bangla',

      // Calendar
      'no_date_selected': 'No date selected',
      'no_tasks_for_this_day': 'No tasks for this day',

      // Analytics
      'task_summary': 'Task Summary',
      'total': 'Total',
      'pending': 'Pending',
      'tasks_by_category': 'Tasks by Category',
      'tasks_by_priority': 'Tasks by Priority',
      'productivity_tip': 'Productivity Tip',
      'productivity_tip_text':
          'Try focusing on high-priority tasks first thing in the morning when your energy levels are highest.',
    },
    'bn': {
      // General
      'app_name': 'টাস্করো',
      'ok': 'ঠিক আছে',
      'cancel': 'বাতিল',
      'save': 'সংরক্ষণ',
      'delete': 'মুছুন',
      'edit': 'সম্পাদনা',

      // Navigation
      'home': 'হোম',
      'calendar': 'ক্যালেন্ডার',
      'analytics': 'বিশ্লেষণ',
      'settings': 'সেটিংস',

      // Home Screen
      'hello': 'হ্যালো,',
      'search_tasks': 'টাস্ক খুঁজুন...',
      'all': 'সব',
      'today': 'আজ',
      'upcoming': 'আসন্ন',
      'completed': 'সম্পন্ন',
      'tasks': 'টাস্ক',
      'no_tasks_found': 'কোন টাস্ক পাওয়া যায়নি',
      'no_completed_tasks': 'আপনি এখনও কোন টাস্ক সম্পন্ন করেননি',
      'my_priority_tasks': 'আমার অগ্রাধিকার টাস্ক',
      'day': 'দিন',
      'days': 'দিন',
      'progress': 'অগ্রগতি',
      'due_date': 'শেষ তারিখ',
      'view_all': 'সব দেখুন',
      'no_search_results': 'আপনার অনুসন্ধানের সাথে কোন টাস্ক মেলেনি',
      'add_task_hint': 'নতুন টাস্ক যোগ করতে + ট্যাপ করুন',

      // Task Details
      'task_details': 'টাস্ক বিবরণ',
      'start_date': 'শুরুর তারিখ',
      'end_date': 'শেষ তারিখ',
      'status': 'অবস্থা',
      'in_progress': 'চলমান',
      'completed_status': 'সম্পন্ন',
      'description': 'বিবরণ',
      'no_description': 'কোন বিবরণ দেওয়া হয়নি',
      'created_on': 'তৈরি হয়েছে',
      'mark_completed': 'সম্পন্ন হিসাবে চিহ্নিত করুন',
      'reopen_task': 'টাস্ক পুনরায় খুলুন',
      'confirm_delete': 'আপনি কি নিশ্চিত যে আপনি এই টাস্ক মুছতে চান?',
      'task_deleted': 'টাস্ক মুছে ফেলা হয়েছে',
      'task_deleted_error': 'টাস্ক মুছতে পারেনি',
      'task_not_found': 'টাস্ক পাওয়া যায়নি বা ইতিমধ্যে মুছে ফেলা হয়েছে',

      // Add/Edit Task
      'add_new_task': 'নতুন টাস্ক যোগ করুন',
      'edit_task': 'টাস্ক সম্পাদনা করুন',
      'title': 'শিরোনাম',
      'task_title': 'টাস্কের শিরোনাম',
      'task_description': 'টাস্কের বিবরণ',
      'task_date_range': 'টাস্কের তারিখের পরিসীমা',
      'please_enter_title': 'অনুগ্রহ করে একটি শিরোনাম লিখুন',
      'priority': 'অগ্রাধিকার',
      'high': 'উচ্চ',
      'medium': 'মধ্যম',
      'low': 'নিম্ন',
      'category': 'ক্যাটাগরি',
      'personal': 'ব্যক্তিগত',
      'work': 'কাজ',
      'shopping': 'কেনাকাটা',
      'health': 'স্বাস্থ্য',
      'study': 'পড়াশোনা',
      'other': 'অন্যান্য',
      'update_task': 'টাস্ক হালনাগাদ করুন',
      'add_task': 'টাস্ক যোগ করুন',

      // Notifications
      'notifications': 'বিজ্ঞপ্তি',
      'no_notifications': 'কোন বিজ্ঞপ্তি নেই',
      'notification_hint':
          'আপনি আসন্ন টাস্ক এবং গুরুত্বপূর্ণ আপডেট সম্পর্কে বিজ্ঞপ্তি পাবেন',
      'notification_dismissed': 'বিজ্ঞপ্তি বাতিল করা হয়েছে',
      'notification_read': 'বিজ্ঞপ্তি পঠিত হিসাবে চিহ্নিত করা হয়েছে',

      // Settings
      'app_settings': 'অ্যাপ সেটিংস',
      'language': 'ভাষা',
      'dark_mode': 'ডার্ক মোড',
      'about': 'সম্পর্কে',
      'app_version': 'অ্যাপ সংস্করণ',
      'rate_app': 'অ্যাপ রেট করুন',
      'help_support': 'সাহায্য ও সমর্থন',
      'privacy_policy': 'গোপনীয়তা নীতি',
      'logout': 'লগআউট',
      'logout_confirm': 'আপনি কি নিশ্চিত যে আপনি লগআউট করতে চান?',
      'profile': 'প্রোফাইল',
      'edit_profile': 'প্রোফাইল সম্পাদনা করুন',
      'change_language': 'ভাষা পরিবর্তন করুন',
      'select_language': 'ভাষা নির্বাচন করুন',
      'english': 'ইংরেজি',
      'bangla': 'বাংলা',

      // Calendar
      'no_date_selected': 'কোন তারিখ নির্বাচিত নেই',
      'no_tasks_for_this_day': 'এই দিনের জন্য কোন টাস্ক নেই',

      // Analytics
      'task_summary': 'টাস্ক সারাংশ',
      'total': 'মোট',
      'pending': 'বাকি আছে',
      'tasks_by_category': 'ক্যাটাগরি অনুসারে টাস্ক',
      'tasks_by_priority': 'অগ্রাধিকার অনুসারে টাস্ক',
      'productivity_tip': 'উৎপাদনশীলতার টিপস',
      'productivity_tip_text':
          'সকালে যখন আপনার শক্তির স্তর সর্বোচ্চ থাকে তখন উচ্চ-অগ্রাধিকার টাস্কগুলিতে মনোনিবেশ করার চেষ্টা করুন।',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}
