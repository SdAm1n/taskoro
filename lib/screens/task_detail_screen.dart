import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/team.dart';
import '../services/task_provider.dart';
import '../services/team_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/task_priority_badge.dart';
import '../utils/custom_page_route.dart';
import '../utils/task_deletion_state.dart';
import '../utils/task_detail_navigation.dart';
import '../localization/translation_helper.dart';
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(context.tr('task_not_found'))));
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
        appBar: CustomAppBar(title: 'task_details'),
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
        title: 'task_details',
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: Theme.of(
                            context,
                          ).textTheme.displaySmall?.copyWith(
                            decoration:
                                task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Show category as a subtitle under task title
                        Row(
                          children: [
                            Icon(
                              Icons.category,
                              size: 16,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              task.getCategoryString(),
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  TaskPriorityBadge(priority: task.getPriorityString()),
                ],
              ),

              const SizedBox(height: 24),

              // Start date and end date
              Row(
                children: [
                  _buildInfoCard(
                    context,
                    context.tr('start_date'),
                    DateFormat('MMM dd, yyyy').format(task.startDate),
                    Icons.calendar_today,
                    AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 16),
                  _buildInfoCard(
                    context,
                    context.tr('end_date'),
                    DateFormat('MMM dd, yyyy').format(task.endDate),
                    Icons.event_available,
                    _getDueDateColor(task.endDate, context),
                  ),
                ],
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
                          context.tr('status'),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task.isCompleted
                              ? context.tr('completed_status')
                              : context.tr('in_progress'),
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
                      onChanged: (value) async {
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        try {
                          await taskProvider.toggleTaskCompletion(task.id);
                        } catch (e) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text('Failed to update task: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      activeColor: AppTheme.accentGreen,
                      activeTrackColor: AppTheme.accentGreen.withValues(
                        alpha: 0.3,
                      ),
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

              // Team assignment section
              if (task.isTeamTask) ...[
                _buildTeamAssignmentSection(context, task),
                const SizedBox(height: 24),
              ],

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
                onPressed: () async {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  try {
                    await taskProvider.toggleTaskCompletion(task.id);
                  } catch (e) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Failed to update task: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
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
            title: Text(context.tr('delete')),
            content: Text('${context.tr('confirm_delete')} "${task.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(context.tr('cancel')),
              ),
              TextButton(
                onPressed: () async {
                  // Extract context references before any async operations
                  final messenger = ScaffoldMessenger.of(context);
                  final tr = context.tr;

                  try {
                    // Mark that we're in a deletion process to prevent "task not found" message
                    TaskDeletionState.markDeletionInProgress();

                    // Delete the task and close dialog first
                    Navigator.pop(dialogContext);

                    final success = await taskProvider.deleteTask(task.id);

                    // After deletion is complete, handle navigation
                    if (success) {
                      // Show success message immediately
                      if (context.mounted) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(tr('task_deleted')),
                            duration: const Duration(seconds: 2),
                          ),
                        );

                        // Navigate back using the current context (mounted check ensures it's valid)
                        Navigator.of(context, rootNavigator: false).pop();
                      }

                      // Reset the deletion state after navigation
                      TaskDeletionState.reset();
                    } else {
                      // Task not found or error, just show error message
                      if (context.mounted) {
                        messenger.showSnackBar(
                          SnackBar(content: Text(tr('task_deleted_error'))),
                        );
                      }

                      // Reset deletion state since we're not navigating away
                      TaskDeletionState.reset();
                    }
                  } catch (e) {
                    // Handle error with feedback to user
                    debugPrint('Error deleting task: $e');

                    // Reset deletion state on error
                    TaskDeletionState.reset();

                    if (context.mounted) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Error deleting task: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Text(
                  context.tr('delete'),
                  style: const TextStyle(color: AppTheme.accentRed),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildTeamAssignmentSection(BuildContext context, Task task) {
    final teamProvider = Provider.of<TeamProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (!task.isTeamTask || task.assignedTeamId == null) {
      return const SizedBox();
    }

    // Find the team
    final team = teamProvider.teams.cast<Team?>().firstWhere(
      (t) => t?.id == task.assignedTeamId,
      orElse: () => null,
    );

    if (team == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.orange.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_outlined, color: Colors.orange, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Team not found',
                style: TextStyle(fontSize: 14, color: Colors.orange.shade700),
              ),
            ),
          ],
        ),
      );
    }

    // Find the assigned members if any
    List<TeamMember> assignedMembers = [];
    if (task.assignedMemberIds != null && task.assignedMemberIds!.isNotEmpty) {
      assignedMembers =
          team.members
              .where(
                (member) => task.assignedMemberIds!.contains(member.userId),
              )
              .toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('team_assignment'),
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isDarkMode ? AppTheme.darkCardColor : AppTheme.lightCardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Team information
              Row(
                children: [
                  Icon(Icons.groups, color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                isDarkMode
                                    ? AppTheme.darkPrimaryTextColor
                                    : AppTheme.lightPrimaryTextColor,
                          ),
                        ),
                        Text(
                          '${team.memberCount} members',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                isDarkMode
                                    ? AppTheme.darkSecondaryTextColor
                                    : AppTheme.lightSecondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Assigned members information
              if (assignedMembers.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignedMembers.length == 1
                            ? 'Assigned to'
                            : 'Assigned to ${assignedMembers.length} members',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryColor.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children:
                            assignedMembers
                                .map(
                                  (member) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: AppTheme.primaryColor
                                              .withValues(alpha: 0.8),
                                          child: Text(
                                            member.displayName.isNotEmpty
                                                ? member.displayName[0]
                                                    .toUpperCase()
                                                : 'M',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            member.displayName,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Not assigned to any specific member',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
