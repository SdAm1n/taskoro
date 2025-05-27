import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/task_provider.dart';
import '../services/theme_provider.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../utils/task_deletion_state.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/task_card.dart';
import '../localization/translation_helper.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Task> _selectedDayTasks = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSelectedDayTasks();
    });
  }

  void _updateSelectedDayTasks() {
    if (_selectedDay != null) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      setState(() {
        _selectedDayTasks = taskProvider.getTasksForDate(_selectedDay!);
      });
    }
  }

  void _updateSelectedDayTasksWithProvider(TaskProvider taskProvider) {
    if (_selectedDay != null) {
      setState(() {
        _selectedDayTasks = taskProvider.getTasksForDate(_selectedDay!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppTheme.darkBackgroundColor
              : AppTheme.lightBackgroundColor,
      appBar: CustomAppBar(title: context.tr('calendar')),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            decoration: BoxDecoration(
              color:
                  isDarkMode ? AppTheme.darkCardColor : AppTheme.lightCardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2021, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              eventLoader: (day) {
                return taskProvider.getTasksForDate(day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _updateSelectedDayTasks();
                  });
                }
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 3,
                outsideDaysVisible: false,
                weekendTextStyle: TextStyle(
                  color:
                      isDarkMode
                          ? AppTheme.darkSecondaryTextColor
                          : AppTheme.lightSecondaryTextColor,
                ),
                defaultTextStyle: TextStyle(
                  color:
                      isDarkMode
                          ? AppTheme.darkPrimaryTextColor
                          : AppTheme.lightPrimaryTextColor,
                ),
              ),
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: true,
                formatButtonDecoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                formatButtonTextStyle: TextStyle(color: AppTheme.primaryColor),
                titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      isDarkMode
                          ? AppTheme.darkPrimaryTextColor
                          : AppTheme.lightPrimaryTextColor,
                ),
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color:
                      isDarkMode
                          ? AppTheme.darkPrimaryTextColor
                          : AppTheme.lightPrimaryTextColor,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color:
                      isDarkMode
                          ? AppTheme.darkPrimaryTextColor
                          : AppTheme.lightPrimaryTextColor,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color:
                      isDarkMode
                          ? AppTheme.darkSecondaryTextColor
                          : AppTheme.lightSecondaryTextColor,
                ),
                weekendStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color:
                      isDarkMode
                          ? AppTheme.darkSecondaryTextColor.withValues(
                            alpha: 0.7,
                          )
                          : AppTheme.lightSecondaryTextColor.withValues(
                            alpha: 0.7,
                          ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDay != null
                      ? DateFormat('MMMM dd, yyyy').format(_selectedDay!)
                      : context.tr('no_date_selected'),
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
                  '${_selectedDayTasks.length} ${context.tr('tasks')}',
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
          ),
          const SizedBox(height: 8),
          Expanded(
            child:
                _selectedDayTasks.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_available,
                            size: 64,
                            color: (isDarkMode
                                    ? AppTheme.darkSecondaryTextColor
                                    : AppTheme.lightSecondaryTextColor)
                                .withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            context.tr('no_tasks_for_this_day'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: (isDarkMode
                                      ? AppTheme.darkSecondaryTextColor
                                      : AppTheme.lightSecondaryTextColor)
                                  .withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _selectedDayTasks.length,
                      itemBuilder: (context, index) {
                        final task = _selectedDayTasks[index];
                        return TaskCard(
                          task: task,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/task_detail',
                              arguments: {'taskId': task.id},
                            ).then((_) => _updateSelectedDayTasks());
                          },
                          onDelete: () async {
                            // Extract context reference before async gap
                            final messenger = ScaffoldMessenger.of(context);

                            try {
                              // Mark that we're in a deletion process
                              TaskDeletionState.markDeletionInProgress();

                              // Store reference to task title before deletion
                              final taskTitle = task.title;

                              final deleteSuccess = await taskProvider
                                  .deleteTask(task.id);

                              if (mounted) {
                                _updateSelectedDayTasksWithProvider(
                                  taskProvider,
                                );

                                // Show confirmation message based on success
                                if (deleteSuccess) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Task "$taskTitle" deleted',
                                      ),
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                } else {
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('Could not delete task'),
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                }

                                // Reset deletion state after handling
                                TaskDeletionState.reset();
                              }
                            } catch (e) {
                              // Handle error with user feedback
                              debugPrint('Error handling task deletion: $e');

                              // Reset deletion state on error
                              TaskDeletionState.reset();

                              if (mounted) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text('Error deleting task: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          onToggleCompleted: () async {
                            // Extract context reference before async gap
                            final messenger = ScaffoldMessenger.of(context);

                            try {
                              await taskProvider.toggleTaskCompletion(task.id);
                              if (mounted) {
                                _updateSelectedDayTasksWithProvider(
                                  taskProvider,
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to update task: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_task').then((_) {
            _updateSelectedDayTasks();
          });
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
