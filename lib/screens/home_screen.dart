import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/task_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/task_card.dart';
import '../utils/task_deletion_state.dart';
import 'edit_profile_screen.dart';

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
              // Header with greeting and profile
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello,',
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
                      // Navigate to profile edit screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppTheme.primaryColor,
                          backgroundImage:
                              user.photoUrl != null
                                  ? NetworkImage(user.photoUrl!)
                                  : null,
                          child:
                              user.photoUrl == null
                                  ? Text(
                                    user.displayName.isNotEmpty
                                        ? user.displayName
                                            .substring(0, 1)
                                            .toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  )
                                  : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.8),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    isDarkMode
                                        ? AppTheme.darkBackgroundColor
                                        : AppTheme.lightBackgroundColor,
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 8,
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
                    hintText: 'Search tasks...',
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
                    _buildFilterChip('All', 0),
                    _buildFilterChip('Today', 1),
                    _buildFilterChip('Upcoming', 2),
                    _buildFilterChip('Completed', 3),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Task count and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_filteredTasks.length} Tasks',
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
                                                'Task "$taskTitle" deleted',
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
                                            const SnackBar(
                                              content: Text(
                                                'Could not delete task',
                                              ),
                                              duration: Duration(seconds: 3),
                                            ),
                                          );

                                          // Reset deletion state on failure
                                          TaskDeletionState.reset();
                                        }
                                      }
                                    },
                                  );
                                } catch (e) {
                                  // Handle error with user feedback
                                  debugPrint(
                                    'Error handling task deletion: $e',
                                  );

                                  // Reset deletion state on error
                                  TaskDeletionState.reset();

                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error deleting task: $e',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              onToggleCompleted: () {
                                taskProvider.toggleTaskCompletion(task.id);
                                _updateFilteredTasks();
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

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedIndex == index;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
          _searchController.clear();
          _searchQuery = '';
          _updateFilteredTasks();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16),
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

  Widget _buildEmptyState() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color:
                isDarkMode
                    ? AppTheme.darkSecondaryTextColor.withOpacity(0.5)
                    : AppTheme.lightSecondaryTextColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color:
                  isDarkMode
                      ? AppTheme.darkSecondaryTextColor.withOpacity(0.7)
                      : AppTheme.lightSecondaryTextColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedIndex == 3
                ? 'You haven\'t completed any tasks yet'
                : 'Tap the + button to add a new task',
            style: TextStyle(
              fontSize: 14,
              color:
                  isDarkMode
                      ? AppTheme.darkSecondaryTextColor.withOpacity(0.7)
                      : AppTheme.lightSecondaryTextColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
