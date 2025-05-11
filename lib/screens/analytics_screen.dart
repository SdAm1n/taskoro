import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/task_provider.dart';
import '../services/theme_provider.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    // Get all tasks
    final allTasks = taskProvider.tasks;
    final completedTasks = taskProvider.completedTasks;
    final pendingTasks = taskProvider.pendingTasks;

    // Calculate completion rate
    final completionRate =
        allTasks.isEmpty ? 0.0 : completedTasks.length / allTasks.length;

    // Count tasks by category
    final categoryTaskCounts = _countTasksByCategory(allTasks);

    // Count tasks by priority
    final priorityTaskCounts = _countTasksByPriority(allTasks);

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppTheme.darkBackgroundColor
              : AppTheme.lightBackgroundColor,
      appBar: CustomAppBar(title: 'Analytics'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Task Summary',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem(
                        context,
                        icon: Icons.assignment_outlined,
                        value: allTasks.length.toString(),
                        label: 'Total',
                      ),
                      _buildSummaryItem(
                        context,
                        icon: Icons.check_circle_outline,
                        value: completedTasks.length.toString(),
                        label: 'Completed',
                      ),
                      _buildSummaryItem(
                        context,
                        icon: Icons.pending_actions_outlined,
                        value: pendingTasks.length.toString(),
                        label: 'Pending',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Progress indicator
                  LinearProgressIndicator(
                    value: completionRate,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(completionRate * 100).toStringAsFixed(0)}% completed',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tasks by Category
            Text(
              'Tasks by Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color:
                    isDarkMode
                        ? AppTheme.darkPrimaryTextColor
                        : AppTheme.lightPrimaryTextColor,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    isDarkMode
                        ? AppTheme.darkCardColor
                        : AppTheme.lightCardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children:
                    categoryTaskCounts.entries.map((entry) {
                      return _buildCategoryProgressBar(
                        context,
                        category: entry.key,
                        count: entry.value,
                        total: allTasks.length,
                        isDarkMode: isDarkMode,
                      );
                    }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Tasks by Priority
            Text(
              'Tasks by Priority',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color:
                    isDarkMode
                        ? AppTheme.darkPrimaryTextColor
                        : AppTheme.lightPrimaryTextColor,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    isDarkMode
                        ? AppTheme.darkCardColor
                        : AppTheme.lightCardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildPrioritySection(
                    context,
                    priority: 'High',
                    count: priorityTaskCounts[TaskPriority.high] ?? 0,
                    color: AppTheme.accentRed,
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 16),
                  _buildPrioritySection(
                    context,
                    priority: 'Medium',
                    count: priorityTaskCounts[TaskPriority.medium] ?? 0,
                    color: AppTheme.accentYellow,
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 16),
                  _buildPrioritySection(
                    context,
                    priority: 'Low',
                    count: priorityTaskCounts[TaskPriority.low] ?? 0,
                    color: AppTheme.accentGreen,
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Productivity Tip
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:
                    isDarkMode
                        ? AppTheme.darkCardColor
                        : AppTheme.accentBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.accentBlue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: AppTheme.accentBlue),
                      const SizedBox(width: 8),
                      Text(
                        'Productivity Tip',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Try focusing on high-priority tasks first thing in the morning when your energy levels are highest.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color:
                          isDarkMode
                              ? AppTheme.darkPrimaryTextColor
                              : AppTheme.lightPrimaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildCategoryProgressBar(
    BuildContext context, {
    required TaskCategory category,
    required int count,
    required int total,
    required bool isDarkMode,
  }) {
    final progress = total > 0 ? count / total : 0.0;
    final categoryName = category.toString().split('.').last;
    final categoryTitle =
        categoryName[0].toUpperCase() + categoryName.substring(1);

    Color categoryColor;
    switch (category) {
      case TaskCategory.work:
        categoryColor = Colors.blue;
        break;
      case TaskCategory.personal:
        categoryColor = Colors.purple;
        break;
      case TaskCategory.shopping:
        categoryColor = Colors.teal;
        break;
      case TaskCategory.health:
        categoryColor = Colors.green;
        break;
      case TaskCategory.other:
        categoryColor = Colors.orange;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                categoryTitle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color:
                      isDarkMode
                          ? AppTheme.darkPrimaryTextColor
                          : AppTheme.lightPrimaryTextColor,
                ),
              ),
              Text(
                '$count tasks',
                style: TextStyle(
                  fontSize: 14,
                  color:
                      isDarkMode
                          ? AppTheme.darkSecondaryTextColor
                          : AppTheme.lightSecondaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: categoryColor.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildPrioritySection(
    BuildContext context, {
    required String priority,
    required int count,
    required Color color,
    required bool isDarkMode,
  }) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Text(
          priority,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color:
                isDarkMode
                    ? AppTheme.darkPrimaryTextColor
                    : AppTheme.lightPrimaryTextColor,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Map<TaskCategory, int> _countTasksByCategory(List<Task> tasks) {
    final Map<TaskCategory, int> categoryCount = {};

    for (var task in tasks) {
      categoryCount[task.category] = (categoryCount[task.category] ?? 0) + 1;
    }

    return categoryCount;
  }

  Map<TaskPriority, int> _countTasksByPriority(List<Task> tasks) {
    final Map<TaskPriority, int> priorityCount = {};

    for (var task in tasks) {
      priorityCount[task.priority] = (priorityCount[task.priority] ?? 0) + 1;
    }

    return priorityCount;
  }
}
