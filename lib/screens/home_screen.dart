import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/task_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/task_card.dart';
import '../utils/task_deletion_state.dart';
import '../localization/translation_helper.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Task> _filteredTasks = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFilteredTasks();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    // Only update if we have tasks loaded and filtered tasks is empty or outdated
    if (taskProvider.tasks.isNotEmpty && _filteredTasks.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateFilteredTasks();
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilteredTasks() {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    setState(() {
      if (_searchQuery.isNotEmpty) {
        _filteredTasks = taskProvider.searchTasks(_searchQuery);
      } else {
        switch (_selectedIndex) {
          case 0: // All
            _filteredTasks = taskProvider.tasks;
            break;
          case 1: // Today
            _filteredTasks = taskProvider.getTasksForDate(DateTime.now());
            break;
          case 2: // Upcoming
            _filteredTasks =
                taskProvider.tasks.where((task) {
                  return task.endDate.isAfter(DateTime.now()) &&
                      task.endDate.difference(DateTime.now()).inDays <= 7;
                }).toList();
            break;
          case 3: // Personal
            _filteredTasks =
                taskProvider.tasks.where((task) => !task.isTeamTask).toList();
            break;
          case 4: // Team Tasks
            _filteredTasks =
                taskProvider.tasks.where((task) => task.isTeamTask).toList();
            break;
          case 5: // Completed
            _filteredTasks = taskProvider.completedTasks;
            break;
        }
      }
    });
  }

  void _updateFilteredTasksWithProvider(TaskProvider taskProvider) {
    setState(() {
      if (_searchQuery.isNotEmpty) {
        _filteredTasks = taskProvider.searchTasks(_searchQuery);
      } else {
        switch (_selectedIndex) {
          case 0: // All
            _filteredTasks = taskProvider.tasks;
            break;
          case 1: // Today
            _filteredTasks = taskProvider.getTasksForDate(DateTime.now());
            break;
          case 2: // Upcoming
            _filteredTasks =
                taskProvider.tasks.where((task) {
                  return task.endDate.isAfter(DateTime.now()) &&
                      task.endDate.difference(DateTime.now()).inDays <= 7;
                }).toList();
            break;
          case 3: // Personal
            _filteredTasks =
                taskProvider.tasks.where((task) => !task.isTeamTask).toList();
            break;
          case 4: // Team Tasks
            _filteredTasks =
                taskProvider.tasks.where((task) => task.isTeamTask).toList();
            break;
          case 5: // Completed
            _filteredTasks = taskProvider.completedTasks;
            break;
        }
      }
    });
  }

  // Helper method to get remaining days until deadline
  String _getRemainingDays(DateTime endDate) {
    final difference = endDate.difference(DateTime.now()).inDays;
    return '$difference ${difference == 1 ? context.tr('day') : context.tr('days')}';
  }

  // Build the priority task card
  Widget _buildPriorityTaskCard(Task task) {
    Color cardColor;
    IconData categoryIcon;

    // Set color based on category
    switch (task.category) {
      case TaskCategory.work:
        cardColor = const Color(0xFF5E35B1); // Deep purple for work
        categoryIcon = Icons.work_outline;
        break;
      case TaskCategory.personal:
        cardColor = const Color(0xFF1E88E5); // Blue for personal
        categoryIcon = Icons.person_outline;
        break;
      case TaskCategory.shopping:
        cardColor = const Color(0xFF00ACC1); // Teal for shopping
        categoryIcon = Icons.shopping_cart_outlined;
        break;
      case TaskCategory.health:
        cardColor = const Color(0xFF43A047); // Green for health
        categoryIcon = Icons.favorite_border;
        break;
      case TaskCategory.study:
        cardColor = const Color(0xFF8E24AA); // Purple for study
        categoryIcon = Icons.school_outlined;
        break;
      case TaskCategory.other:
        cardColor = const Color(0xFFE53935); // Red for other
        categoryIcon = Icons.lightbulb_outline;
        break;
    }

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/task_detail',
          arguments: {'taskId': task.id},
        );
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            // Background gradient circles (for visual effect)
            Positioned(
              top: -20,
              left: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              right: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            // Task completion indicator
            if (task.isCompleted)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle, color: cardColor, size: 18),
                ),
              ),
            // Card content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                categoryIcon,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _getCategoryName(task.category),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Text(
                            task.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Due date information
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('due_date'),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('MMM dd').format(task.endDate),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getRemainingDays(task.endDate),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  } // Helper method to get category name

  String _getCategoryName(TaskCategory category) {
    switch (category) {
      case TaskCategory.work:
        return context.tr('work');
      case TaskCategory.personal:
        return context.tr('personal');
      case TaskCategory.shopping:
        return context.tr('shopping');
      case TaskCategory.health:
        return context.tr('health');
      case TaskCategory.study:
        return context.tr('study');
      case TaskCategory.other:
        return context.tr('other');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final user = taskProvider.currentUser;
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        // Get high priority tasks
        final priorityTasks = taskProvider.getTasksByPriority(
          TaskPriority.high,
        );

        // Update filtered tasks when provider data changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && taskProvider.tasks.isNotEmpty) {
            _updateFilteredTasksWithProvider(taskProvider);
          }
        });

        return GestureDetector(
          onTap: () {
            // Dismiss keyboard when tapping outside of text field
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            resizeToAvoidBottomInset: true, // This helps adjust for keyboard
            backgroundColor:
                isDarkMode
                    ? AppTheme.darkBackgroundColor
                    : AppTheme.lightBackgroundColor,
            body: SafeArea(
              bottom: false, // Allow content to extend past safe area at bottom
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with greeting and notification icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.tr('hello'),
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.displayName, // This displays the username
                                    style:
                                        Theme.of(
                                          context,
                                        ).textTheme.displayMedium,
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Navigate to notifications screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const NotificationsScreen(),
                                    ),
                                  );
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color:
                                            isDarkMode
                                                ? AppTheme.darkSurfaceColor
                                                : AppTheme.lightSurfaceColor,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.primaryColor
                                                .withValues(alpha: 0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                        border: Border.all(
                                          color: AppTheme.primaryColor
                                              .withValues(alpha: 0.3),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.notifications,
                                        size: 22,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                    // Notification badge
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          color: AppTheme.accentRed,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color:
                                                isDarkMode
                                                    ? AppTheme
                                                        .darkBackgroundColor
                                                    : AppTheme
                                                        .lightBackgroundColor,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            '3',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Modern Search bar with pill-shaped shadow
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      isDarkMode
                                          ? AppTheme.primaryColor.withValues(
                                            alpha: 0.2,
                                          )
                                          : Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, -2), // Shadow at top
                                ),
                                BoxShadow(
                                  color:
                                      isDarkMode
                                          ? AppTheme.primaryColor.withValues(
                                            alpha: 0.3,
                                          )
                                          : Colors.black.withValues(
                                            alpha: 0.15,
                                          ),
                                  blurRadius: 8,
                                  offset: const Offset(
                                    0,
                                    4,
                                  ), // Shadow at bottom
                                ),
                              ],
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color:
                                    isDarkMode
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : Colors.black.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: TextField(
                                controller: _searchController,
                                style: TextStyle(
                                  color:
                                      isDarkMode
                                          ? AppTheme.darkPrimaryTextColor
                                          : AppTheme.lightPrimaryTextColor,
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  hintText: context.tr('search_tasks'),
                                  hintStyle: TextStyle(
                                    color:
                                        isDarkMode
                                            ? AppTheme.darkDisabledTextColor
                                            : AppTheme.lightDisabledTextColor,
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                  isDense: true,
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color:
                                        isDarkMode
                                            ? AppTheme.darkSecondaryTextColor
                                            : AppTheme.lightSecondaryTextColor,
                                    size: 20,
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    minWidth: 40,
                                    minHeight: 40,
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value;
                                    _updateFilteredTasks();
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Expanded to make the rest of the content scrollable
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Priority Tasks Section
                                  if (priorityTasks.isNotEmpty) ...[
                                    Text(
                                      context.tr('my_priority_tasks'),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            isDarkMode
                                                ? AppTheme.darkPrimaryTextColor
                                                : AppTheme
                                                    .lightPrimaryTextColor,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      height: 170,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: priorityTasks.length,
                                        itemBuilder: (context, index) {
                                          return _buildPriorityTaskCard(
                                            priorityTasks[index],
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],

                                  // Filter tabs
                                  SizedBox(
                                    height: 40,
                                    child: Center(
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        children: [
                                          _buildFilterChip(
                                            context.tr('all'),
                                            0,
                                          ),
                                          _buildFilterChip(
                                            context.tr('today'),
                                            1,
                                          ),
                                          _buildFilterChip(
                                            context.tr('upcoming'),
                                            2,
                                          ),
                                          _buildFilterChip(
                                            context.tr('personal_tasks'),
                                            3,
                                          ),
                                          _buildFilterChip(
                                            context.tr('team_tasks'),
                                            4,
                                          ),
                                          _buildFilterChip(
                                            context.tr('completed'),
                                            5,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Task count and date
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${_filteredTasks.length} ${context.tr('tasks')}',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                      ),
                                      Text(
                                        DateFormat(
                                          'MMMM dd, yyyy',
                                        ).format(DateTime.now()),
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Task list - Using SizedBox with ListView.builder
                                  _filteredTasks.isEmpty
                                      ? _buildEmptyState()
                                      : ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: _filteredTasks.length,
                                        itemBuilder: (context, index) {
                                          final task = _filteredTasks[index];
                                          return TaskCard(
                                            task: task,
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                '/task_detail',
                                                arguments: {'taskId': task.id},
                                              );
                                            },
                                            onToggleCompleted: () async {
                                              final messenger =
                                                  ScaffoldMessenger.of(context);
                                              try {
                                                await taskProvider
                                                    .toggleTaskCompletion(
                                                      task.id,
                                                    );
                                                if (mounted) {
                                                  _updateFilteredTasksWithProvider(
                                                    taskProvider,
                                                  );
                                                }
                                              } catch (e) {
                                                if (mounted) {
                                                  messenger.showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Failed to update task: $e',
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                            onDelete: () async {
                                              final messenger =
                                                  ScaffoldMessenger.of(context);
                                              final tr = context.tr;
                                              try {
                                                // Mark that we're in a deletion process
                                                TaskDeletionState.markDeletionInProgress();

                                                // Store a reference to the task title before deletion
                                                final taskTitle = task.title;

                                                final deleteSuccess =
                                                    await taskProvider
                                                        .deleteTask(task.id);

                                                if (mounted) {
                                                  _updateFilteredTasksWithProvider(
                                                    taskProvider,
                                                  );

                                                  // Show a snackbar confirmation based on success
                                                  if (deleteSuccess) {
                                                    messenger.showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          '${tr('task_deleted')}: "$taskTitle"',
                                                        ),
                                                        duration:
                                                            const Duration(
                                                              seconds: 3,
                                                            ),
                                                      ),
                                                    );
                                                  } else {
                                                    messenger.showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          tr(
                                                            'task_deleted_error',
                                                          ),
                                                        ),
                                                        backgroundColor:
                                                            Colors.red,
                                                        duration:
                                                            const Duration(
                                                              seconds: 3,
                                                            ),
                                                      ),
                                                    );
                                                  }

                                                  // Reset deletion state after handling
                                                  TaskDeletionState.reset();
                                                }
                                              } catch (e) {
                                                // Handle error with user feedback
                                                debugPrint(
                                                  'Error handling task deletion: $e',
                                                );

                                                // Reset deletion state on error
                                                TaskDeletionState.reset();

                                                if (mounted) {
                                                  messenger.showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Error deleting task: $e',
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                          );
                                        },
                                      ),
                                  // Add extra padding at the bottom to ensure no overflow
                                  const SizedBox(height: 80),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add_task').then((_) {
                  // Refresh the task list when returning from add task screen
                  if (mounted) {
                    _updateFilteredTasks();
                  }
                });
              },
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.task_alt,
            size: 80,
            color:
                isDarkMode
                    ? AppTheme.darkDisabledTextColor
                    : AppTheme.lightDisabledTextColor,
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('no_tasks_found'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color:
                  isDarkMode
                      ? AppTheme.darkSecondaryTextColor
                      : AppTheme.lightSecondaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedIndex == 3
                ? context.tr('no_completed_tasks')
                : _searchQuery.isNotEmpty
                ? context.tr('no_search_results')
                : context.tr('add_task_hint'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color:
                  isDarkMode
                      ? AppTheme.darkDisabledTextColor
                      : AppTheme.lightDisabledTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedIndex == index;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
          _updateFilteredTasks();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppTheme.primaryColor
                  : isDarkMode
                  ? AppTheme.darkSurfaceColor
                  : AppTheme.lightSurfaceColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  isSelected
                      ? Colors.white
                      : isDarkMode
                      ? AppTheme.darkSecondaryTextColor
                      : AppTheme.lightSecondaryTextColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
