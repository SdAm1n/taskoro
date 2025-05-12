import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/task_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/task_priority_badge.dart';
import '../utils/custom_page_route.dart';
import '../utils/task_deletion_state.dart';
import '../utils/task_detail_navigation.dart';
import 'add_edit_task_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    // Find the task in the task list - safely
    // We use firstWhere with a default value (null) instead of try-catch to avoid exceptions
    final task = taskProvider.tasks.cast<Task?>().firstWhere(
      (task) => task?.id == taskId,
      orElse: () => null,
    );

    // If no task found (it was deleted), show message and go back
    if (task == null) {
      // Use post-frame callback to navigate back after the frame is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Only show the "task not found" message if we aren't in a deletion flow
        if (!TaskDeletionState.isBeingDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task not found or was already deleted'),
            ),
          );
        }

        // Use our task-specific navigation helper to go back safely
        TaskDetailNavigation.navigateBackToMain(context);

        // Reset the deletion state after enough time for the navigation to complete
        Future.delayed(const Duration(milliseconds: 500), () {
          TaskDeletionState.reset();
        });
      });

      // Return a loading scaffold while we redirect
      return Scaffold(
        backgroundColor:
            Theme.of(context).brightness == Brightness.dark
                ? AppTheme.darkBackgroundColor
                : AppTheme.lightBackgroundColor,
        appBar: CustomAppBar(title: 'Task Details'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppTheme.darkBackgroundColor
              : AppTheme.lightBackgroundColor,
      appBar: CustomAppBar(
        title: 'Task Details',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                NoBackButtonPageRoute(
                  builder: (context) => AddEditTaskScreen(task: task),
                  fullscreenDialog: true,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppTheme.accentRed),
            onPressed: () {
              _showDeleteConfirmation(context, task, taskProvider);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and priority
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        decoration:
                            task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                      ),
                    ),
                  ),
                  TaskPriorityBadge(priority: task.getPriorityString()),
                ],
              ),

              const SizedBox(height: 24),

              // Due date and category
              Row(
                children: [
                  _buildInfoCard(
                    context,
                    'Start Date',
                    DateFormat('MMM dd, yyyy').format(task.startDate),
                    Icons.calendar_today,
                    AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 16),
                  _buildInfoCard(
                    context,
                    'End Date',
                    DateFormat('MMM dd, yyyy').format(task.endDate),
                    Icons.event_available,
                    _getDueDateColor(task.endDate, context),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Category
              _buildInfoCard(
                context,
                'Category',
                task.getCategoryString(),
                Icons.category,
                AppTheme.primaryColor,
                fullWidth: true,
              ),

              const SizedBox(height: 24),

              // Task status
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      isDarkMode
                          ? AppTheme.darkCardColor
                          : AppTheme.lightCardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task.isCompleted ? 'Completed' : 'In Progress',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                task.isCompleted
                                    ? AppTheme.accentGreen
                                    : AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: task.isCompleted,
                      onChanged: (value) {
                        taskProvider.toggleTaskCompletion(task.id);
                      },
                      activeColor: AppTheme.accentGreen,
                      activeTrackColor: AppTheme.accentGreen.withOpacity(0.3),
                      inactiveThumbColor:
                          isDarkMode
                              ? AppTheme.darkSecondaryTextColor
                              : AppTheme.lightSecondaryTextColor,
                      inactiveTrackColor:
                          isDarkMode
                              ? AppTheme.darkSurfaceColor
                              : AppTheme.lightSurfaceColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Description
              Text(
                'Description',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      isDarkMode
                          ? AppTheme.darkCardColor
                          : AppTheme.lightCardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  task.description.isEmpty
                      ? 'No description provided'
                      : task.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color:
                        task.description.isEmpty
                            ? isDarkMode
                                ? AppTheme.darkDisabledTextColor
                                : AppTheme.lightDisabledTextColor
                            : isDarkMode
                            ? AppTheme.darkPrimaryTextColor
                            : AppTheme.lightPrimaryTextColor,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Created on
              Text(
                'Created on',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('MMMM dd, yyyy - HH:mm').format(task.createdAt),
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 40),

              // Complete/Reopen button
              CustomButton(
                text: task.isCompleted ? 'Reopen Task' : 'Mark as Completed',
                onPressed: () {
                  taskProvider.toggleTaskCompletion(task.id);
                },
                backgroundColor:
                    task.isCompleted
                        ? isDarkMode
                            ? AppTheme.darkSurfaceColor
                            : AppTheme.lightSurfaceColor
                        : AppTheme.accentGreen,
                textColor:
                    task.isCompleted
                        ? isDarkMode
                            ? AppTheme.darkPrimaryTextColor
                            : AppTheme.lightPrimaryTextColor
                        : Colors.white,
                icon:
                    task.isCompleted
                        ? Icons.refresh_rounded
                        : Icons.check_circle_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color iconColor, {
    bool fullWidth = false,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Widget cardContent = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkCardColor : AppTheme.lightCardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 6),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    return fullWidth ? cardContent : Expanded(child: cardContent);
  }

  Color _getDueDateColor(DateTime dueDate, BuildContext context) {
    final now = DateTime.now();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (dueDate.isBefore(DateTime(now.year, now.month, now.day))) {
      return AppTheme.accentRed; // Overdue
    } else if (dueDate.isAtSameMomentAs(
      DateTime(now.year, now.month, now.day),
    )) {
      return AppTheme.accentYellow; // Due today
    } else {
      return isDarkMode
          ? AppTheme.darkSecondaryTextColor
          : AppTheme.lightSecondaryTextColor; // Upcoming
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    Task task,
    TaskProvider taskProvider,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor:
                isDarkMode
                    ? AppTheme.darkSurfaceColor
                    : AppTheme.lightSurfaceColor,
            title: const Text('Delete Task'),
            content: Text('Are you sure you want to delete "${task.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  try {
                    // Mark that we're in a deletion process to prevent "task not found" message
                    TaskDeletionState.markDeletionInProgress();

                    // Delete the task and close dialog first
                    final result = taskProvider.deleteTask(task.id);
                    Navigator.pop(dialogContext);

                    // After dialog is closed, we handle further actions
                    if (result) {
                      // Show success message immediately, before any navigation
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Task deleted successfully'),
                          duration: Duration(seconds: 2),
                        ),
                      );

                      // Use a longer delay to ensure the snackbar is visible before navigation
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (context.mounted) {
                          // Navigate back safely using our dedicated method
                          _navigateBack(context);
                        }
                      });
                    } else {
                      // Task not found or error, just show error message
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Could not delete task. Please try again.',
                              ),
                            ),
                          );

                          // Reset deletion state since we're not navigating away
                          TaskDeletionState.reset();
                        }
                      });
                    }
                  } catch (e) {
                    // Handle error with feedback to user
                    debugPrint('Error deleting task: $e');
                    Navigator.pop(dialogContext); // Close dialog

                    // Reset deletion state on error
                    TaskDeletionState.reset();

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error deleting task: ${e.toString()}'),
                        ),
                      );
                    }
                  }
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: AppTheme.accentRed),
                ),
              ),
            ],
          ),
    );
  }

  // Helper method to safely navigate back without triggering unexpected routes
  void _navigateBack(BuildContext context) {
    // Use our specialized navigation class to handle going back safely
    TaskDetailNavigation.navigateBackToMain(context);

    // Reset the deletion state after navigation has completed
    Future.delayed(const Duration(milliseconds: 800), () {
      TaskDeletionState.reset();
    });
  }
}
