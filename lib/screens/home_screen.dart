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
          case 3: // Completed
            _filteredTasks = taskProvider.completedTasks;
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final user = taskProvider.currentUser;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppTheme.darkBackgroundColor
              : AppTheme.lightBackgroundColor,
      body: SafeArea(
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
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.displayName,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to notifications screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
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
                                color: AppTheme.primaryColor.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: AppTheme.primaryColor.withOpacity(0.3),
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
                                        ? AppTheme.darkBackgroundColor
                                        : AppTheme.lightBackgroundColor,
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

              const SizedBox(height: 24),

              // Search bar
              Container(
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.darkSurfaceColor
                          : AppTheme.lightSurfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.darkPrimaryTextColor
                            : AppTheme.lightPrimaryTextColor,
                  ),
                  decoration: InputDecoration(
                    hintText: context.tr('search_tasks'),
                    hintStyle: TextStyle(
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? AppTheme.darkDisabledTextColor
                              : AppTheme.lightDisabledTextColor,
                    ),
                    icon: Icon(
                      Icons.search,
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? AppTheme.darkSecondaryTextColor
                              : AppTheme.lightSecondaryTextColor,
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _updateFilteredTasks();
                    });
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Filter tabs
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip(context.tr('all'), 0),
                    _buildFilterChip(context.tr('today'), 1),
                    _buildFilterChip(context.tr('upcoming'), 2),
                    _buildFilterChip(context.tr('completed'), 3),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Task count and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_filteredTasks.length} ${context.tr('tasks')}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    DateFormat('MMMM dd, yyyy').format(DateTime.now()),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Task list
              Expanded(
                child:
                    _filteredTasks.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
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
                              onToggleCompleted: () {
                                taskProvider.toggleTaskCompletion(task.id);
                                _updateFilteredTasks();
                              },
                              onDelete: () {
                                try {
                                  // Mark that we're in a deletion process to prevent "task not found" message
                                  TaskDeletionState.markDeletionInProgress();

                                  // Store a reference to the task title before deletion
                                  final taskTitle = task.title;

                                  final deleteSuccess = taskProvider.deleteTask(
                                    task.id,
                                  );

                                  // Use post frame callback to ensure state is updated properly
                                  // Replace with a safer delayed execution method
                                  Future.delayed(
                                    const Duration(milliseconds: 200),
                                    () {
                                      if (mounted) {
                                        _updateFilteredTasks();

                                        // Show a snackbar confirmation based on success
                                        if (deleteSuccess) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '${context.tr('task_deleted')}: "$taskTitle"',
                                              ),
                                              duration: const Duration(
                                                seconds: 3,
                                              ),
                                            ),
                                          );

                                          // Reset deletion state after showing the message
                                          Future.delayed(
                                            const Duration(milliseconds: 500),
                                            () {
                                              TaskDeletionState.reset();
                                            },
                                          );
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                context.tr(
                                                  'task_deleted_error',
                                                ),
                                              ),
                                              duration: const Duration(
                                                seconds: 3,
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  );
                                } catch (e) {
                                  // Print error to console for debugging
                                  debugPrint('Error deleting task: $e');
                                }
                              },
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_task');
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppTheme.primaryColor
                  : isDarkMode
                  ? AppTheme.darkSurfaceColor
                  : AppTheme.lightSurfaceColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
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
    );
  }
}
