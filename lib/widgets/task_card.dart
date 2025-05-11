import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import 'task_priority_badge.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final Function() onTap;
  final Function() onDelete;
  final Function() onToggleCompleted;
  final bool isCompact;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onTap,
    required this.onDelete,
    required this.onToggleCompleted,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: AppTheme.accentRed,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(12),
            ),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isDarkMode ? AppTheme.darkCardColor : AppTheme.lightCardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: isCompact ? 16 : 18,
                        fontWeight: FontWeight.bold,
                        color:
                            isDarkMode
                                ? AppTheme.darkPrimaryTextColor
                                : AppTheme.lightPrimaryTextColor,
                        decoration:
                            task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TaskPriorityBadge(
                    priority: task.getPriorityString(),
                    isSmall: isCompact,
                  ),
                ],
              ),
              if (!isCompact) ...[
                const SizedBox(height: 8),
                Text(
                  task.description,
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        isDarkMode
                            ? AppTheme.darkSecondaryTextColor
                            : AppTheme.lightSecondaryTextColor,
                    decoration:
                        task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: isCompact ? 14 : 16,
                        color: _getDueDateColor(task.dueDate, context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(task.dueDate),
                        style: TextStyle(
                          fontSize: isCompact ? 12 : 14,
                          color: _getDueDateColor(task.dueDate, context),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? AppTheme.darkSurfaceColor
                              : AppTheme.lightSurfaceColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: onToggleCompleted,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              task.isCompleted
                                  ? Icons.check_circle_rounded
                                  : Icons.circle_outlined,
                              size: isCompact ? 18 : 20,
                              color:
                                  task.isCompleted
                                      ? AppTheme.accentGreen
                                      : isDarkMode
                                      ? AppTheme.darkSecondaryTextColor
                                      : AppTheme.lightSecondaryTextColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task.isCompleted ? 'Completed' : 'Mark done',
                              style: TextStyle(
                                fontSize: isCompact ? 12 : 14,
                                color:
                                    task.isCompleted
                                        ? AppTheme.accentGreen
                                        : isDarkMode
                                        ? AppTheme.darkSecondaryTextColor
                                        : AppTheme.lightSecondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
}
