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
  List<Task> _tasks = [
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
  void deleteTask(String taskId) {
    _tasks.removeWhere((task) => task.id == taskId);
    notifyListeners();
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
}
