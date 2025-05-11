import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import 'task_card.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final Function(String) onTaskTap;
  final Function(String) onTaskDelete;
  final Function(String) onTaskToggle;
  final bool showEmptyState;
  final String emptyStateText;

  const TaskList({
    Key? key,
    required this.tasks,
    required this.onTaskTap,
    required this.onTaskDelete,
    required this.onTaskToggle,
    this.showEmptyState = true,
    this.emptyStateText = 'No tasks found',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty && showEmptyState) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          task: task,
          onTap: () => onTaskTap(task.id),
          onDelete: () => onTaskDelete(task.id),
          onToggleCompleted: () => onTaskToggle(task.id),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: (isDarkMode 
                ? AppTheme.darkSecondaryTextColor 
                : AppTheme.lightSecondaryTextColor).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: (isDarkMode 
                  ? AppTheme.darkSecondaryTextColor 
                  : AppTheme.lightSecondaryTextColor).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            emptyStateText,
            style: TextStyle(
              fontSize: 14,
              color: (isDarkMode 
                  ? AppTheme.darkSecondaryTextColor 
                  : AppTheme.lightSecondaryTextColor).withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
