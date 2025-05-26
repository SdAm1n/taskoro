import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/user.dart';

class TaskProvider extends ChangeNotifier {
  // Dummy user for frontend development
  AppUser _currentUser = AppUser(
    id: 'user1',
    displayName: 'John Doe',
    email: 'john@example.com',
    createdAt: DateTime.now(),
    photoUrl: null,
  );

  // Dummy tasks for frontend development
  final List<Task> _tasks = [
    Task(
      id: '1',
      title: 'Create UI design for mobile app',
      description:
          'Complete the UI design for the new mobile application. Include all screens and components.',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 2)),
      priority: TaskPriority.high,
      category: TaskCategory.work,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Task(
      id: '2',
      title: 'Buy groceries',
      description: 'Milk, eggs, bread, fruits, vegetables',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 1)),
      priority: TaskPriority.medium,
      category: TaskCategory.shopping,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Task(
      id: '3',
      title: 'Workout session',
      description: '30 min cardio, 30 min strength training',
      startDate: DateTime.now(),
      endDate: DateTime.now(),
      priority: TaskPriority.low,
      category: TaskCategory.health,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Task(
      id: '4',
      title: 'Team meeting',
      description: 'Discuss project progress and next steps with the team',
      startDate: DateTime.now().add(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 3)),
      priority: TaskPriority.high,
      category: TaskCategory.work,
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    Task(
      id: '5',
      title: 'Call mom',
      description: "Don't forget to wish her happy birthday!",
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 1)),
      priority: TaskPriority.medium,
      category: TaskCategory.personal,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    // Team-assigned tasks
    Task(
      id: '6',
      title: 'Review project documentation',
      description: 'Review and update project documentation for the mobile app',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 3)),
      priority: TaskPriority.high,
      category: TaskCategory.work,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      assignedTeamId: 'team1',
      assignedMemberIds: ['member2', 'member3'],
    ),
    Task(
      id: '7',
      title: 'Test new features',
      description: 'Test all new features before the release',
      startDate: DateTime.now().add(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 2)),
      priority: TaskPriority.medium,
      category: TaskCategory.work,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      assignedTeamId: 'team1',
      assignedMemberIds: ['member1'],
    ),
  ];

  // Getters
  AppUser get currentUser => _currentUser;
  List<Task> get tasks => _tasks;
  List<Task> get completedTasks =>
      _tasks.where((task) => task.isCompleted).toList();
  List<Task> get pendingTasks =>
      _tasks.where((task) => !task.isCompleted).toList();

  // Filter tasks by category
  List<Task> getTasksByCategory(TaskCategory category) {
    return _tasks.where((task) => task.category == category).toList();
  }

  // Filter tasks by priority
  List<Task> getTasksByPriority(TaskPriority priority) {
    return _tasks.where((task) => task.priority == priority).toList();
  }

  // Filter tasks by date
  List<Task> getTasksForDate(DateTime date) {
    return _tasks.where((task) {
      // A task is for a specific date if the date falls within its date range (inclusive)
      return (date.isAtSameMomentAs(task.startDate) ||
              date.isAfter(task.startDate)) &&
          (date.isAtSameMomentAs(task.endDate) || date.isBefore(task.endDate));
    }).toList();
  }

  // Filter tasks by search query
  List<Task> searchTasks(String query) {
    if (query.isEmpty) return _tasks;

    final lowercaseQuery = query.toLowerCase();
    return _tasks.where((task) {
      return task.title.toLowerCase().contains(lowercaseQuery) ||
          task.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Add a new task
  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  // Update an existing task
  void updateTask(Task updatedTask) {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();
    }
  }

  // Delete a task
  bool deleteTask(String taskId) {
    try {
      final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        // Remove the task from the list
        _tasks.removeAt(taskIndex);

        // Immediate notification is important to avoid race conditions
        // that could cause "task not found" messages to appear before
        // the success message
        notifyListeners();

        return true; // Successfully deleted
      } else {
        debugPrint('Task not found for deletion: $taskId');
        return false; // Task not found
      }
    } catch (e) {
      // Handle any errors silently to prevent UI glitches
      debugPrint('Error deleting task: $e');

      // Still notify listeners to ensure UI is updated
      notifyListeners();

      return false; // Error during deletion
    }
  }

  // Toggle task completion status
  void toggleTaskCompletion(String taskId) {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      _tasks[index] = task.copyWith(isCompleted: !task.isCompleted);
      notifyListeners();
    }
  }

  // Sort tasks by different criteria
  void sortTasks(String sortBy) {
    switch (sortBy) {
      case 'dueDate':
        // Sort by end date as that represents the due date
        _tasks.sort((a, b) => a.endDate.compareTo(b.endDate));
        break;
      case 'priority':
        _tasks.sort((a, b) => b.priority.index.compareTo(a.priority.index));
        break;
      case 'title':
        _tasks.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'createdAt':
        _tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    notifyListeners();
  }

  // Update user information
  void updateUser(AppUser updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }

  // Team-related task methods

  // Get tasks assigned to a specific team
  List<Task> getTasksForTeam(String teamId) {
    return _tasks.where((task) => task.assignedTeamId == teamId).toList();
  }

  // Get tasks assigned to a specific team member
  List<Task> getTasksForMember(String memberId) {
    return _tasks.where((task) => task.isAssignedToMember(memberId)).toList();
  }

  // Get tasks assigned to a specific team member within a specific team
  List<Task> getTasksForTeamMember(String teamId, String memberId) {
    return _tasks
        .where(
          (task) =>
              task.assignedTeamId == teamId &&
              task.isAssignedToMember(memberId),
        )
        .toList();
  }

  // Get all team-assigned tasks
  List<Task> get teamTasks => _tasks.where((task) => task.isTeamTask).toList();

  // Get personal (non-team) tasks
  List<Task> get personalTasks =>
      _tasks.where((task) => !task.isTeamTask).toList();

  // Assign task to team members
  void assignTaskToMembers(
    String taskId,
    String teamId,
    List<String> memberIds,
  ) {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      _tasks[index] = task.copyWith(
        assignedTeamId: teamId,
        assignedMemberIds: memberIds,
      );
      notifyListeners();
    }
  }

  // Assign task to a single team member (backward compatibility)
  void assignTaskToMember(String taskId, String teamId, String memberId) {
    assignTaskToMembers(taskId, teamId, [memberId]);
  }

  // Add a member to an existing task assignment
  void addMemberToTask(String taskId, String memberId) {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      final currentMembers = task.assignedMemberIds ?? [];
      if (!currentMembers.contains(memberId)) {
        final updatedMembers = [...currentMembers, memberId];
        _tasks[index] = task.copyWith(assignedMemberIds: updatedMembers);
        notifyListeners();
      }
    }
  }

  // Remove a member from an existing task assignment
  void removeMemberFromTask(String taskId, String memberId) {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      final currentMembers = task.assignedMemberIds ?? [];
      if (currentMembers.contains(memberId)) {
        final updatedMembers =
            currentMembers.where((id) => id != memberId).toList();
        _tasks[index] = task.copyWith(assignedMemberIds: updatedMembers);
        notifyListeners();
      }
    }
  }

  // Remove team assignment from task
  void removeTeamAssignment(String taskId) {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      _tasks[index] = task.copyWith(
        assignedTeamId: null,
        assignedMemberIds: null,
      );
      notifyListeners();
    }
  }
}
