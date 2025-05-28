import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';
import '../models/user.dart';
import 'firebase_task_service.dart';
import 'firebase_user_service.dart';
import 'auth_service.dart';

class TaskProvider extends ChangeNotifier {
  final FirebaseTaskService _taskService = FirebaseTaskService();
  final FirebaseUserService _userService = FirebaseUserService();
  final AuthService _authService;

  // Current user and tasks
  AppUser _currentUser = AppUser.empty();
  List<Task> _tasks = [];
  StreamSubscription<List<Task>>? _tasksSubscription;
  StreamSubscription<AppUser?>? _userSubscription;
  StreamSubscription<User?>? _authSubscription;

  // Loading states
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _disposed = false;

  // Constructor
  TaskProvider({AuthService? authService})
    : _authService = authService ?? AuthService() {
    _initializeProvider();
  }

  // Initialize the provider with Firebase data
  void _initializeProvider() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Listen to auth state changes first
      _authSubscription = _authService.authStateChanges.listen((firebaseUser) {
        // Check if provider is disposed before processing auth changes
        if (_disposed) return;

        if (firebaseUser != null) {
          // User is authenticated, start listening to user profile
          _setupUserProfileListener();
        } else {
          // User is not authenticated, reset state
          _currentUser = AppUser.empty();
          _tasks = [];
          _userSubscription?.cancel();
          _tasksSubscription?.cancel();
          notifyListeners();
        }
      });

      _isInitialized = true;
    } catch (e) {
      // Handle error silently or log to crash reporting service
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Setup user profile listener
  void _setupUserProfileListener() {
    _userSubscription?.cancel();

    _userSubscription = _userService.getCurrentUserProfileStream().listen((
      user,
    ) {
      // Check if provider is disposed before notifying listeners
      if (_disposed) return;

      if (user != null) {
        _currentUser = user;
        _setupTasksListener();
      } else {
        // User document doesn't exist yet, create fallback from auth
        final authUser = _authService.currentUser;
        if (authUser != null) {
          _currentUser = authUser;
          // Try to create the user document in Firestore
          _userService.createOrUpdateUser(authUser).catchError((_) {
            // Ignore errors, the document will be created eventually
          });
        }
      }
      notifyListeners();
    });
  }

  // Setup Firebase listener for tasks
  void _setupTasksListener() {
    _tasksSubscription?.cancel();
    _tasksSubscription = _taskService.getUserTasks().listen((tasks) {
      // Check if provider is disposed before notifying listeners
      if (_disposed) return;

      _tasks = tasks;
      notifyListeners();
    });
  }

  // Loading state getters
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  // Getters
  AppUser get currentUser => _currentUser;
  List<Task> get tasks => _tasks;
  List<Task> get completedTasks =>
      _tasks.where((task) => task.isCompleted).toList();
  List<Task> get pendingTasks =>
      _tasks.where((task) => !task.isCompleted).toList();

  // Filter tasks by category
  List<Task> getTasksByCategory(TaskCategory category) {
    final filteredTasks =
        _tasks.where((task) => task.category == category).toList();
    return filteredTasks;
  }

  // Filter tasks by priority
  List<Task> getTasksByPriority(TaskPriority priority) {
    final filteredTasks =
        _tasks.where((task) => task.priority == priority).toList();
    return filteredTasks;
  }

  // Filter tasks by date
  List<Task> getTasksForDate(DateTime date) {
    final filteredTasks =
        _tasks.where((task) {
          // A task is for a specific date if the date falls within its date range (inclusive)
          return (date.isAtSameMomentAs(task.startDate) ||
                  date.isAfter(task.startDate)) &&
              (date.isAtSameMomentAs(task.endDate) ||
                  date.isBefore(task.endDate));
        }).toList();
    return filteredTasks;
  }

  // Filter tasks by search query
  List<Task> searchTasks(String query) {
    if (query.isEmpty) return _tasks;

    final lowercaseQuery = query.toLowerCase();
    final filteredTasks =
        _tasks.where((task) {
          return task.title.toLowerCase().contains(lowercaseQuery) ||
              task.description.toLowerCase().contains(lowercaseQuery);
        }).toList();
    return filteredTasks;
  }

  // Add a new task
  Future<String?> addTask(Task task) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Add timeout to prevent hanging
      final taskId = await _taskService
          .createTask(task)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Task creation timed out');
            },
          );

      print(
        'TaskProvider: Task created successfully with ID: $taskId',
      ); // Debug log

      // The task will be automatically added to _tasks via the stream listener
      return taskId;
    } catch (e) {
      print('TaskProvider: Error adding task: $e'); // Debug log
      // Debug: Error adding task: $e
      rethrow; // Re-throw so the UI can handle the error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update an existing task
  Future<bool> updateTask(Task updatedTask) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _taskService.updateTask(updatedTask);
      // The task will be automatically updated in _tasks via the stream listener
      return true;
    } catch (e) {
      // Debug: Error updating task: $e
      rethrow; // Re-throw so the UI can handle the error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a task
  Future<bool> deleteTask(String taskId) async {
    try {
      // First, check if task exists
      if (!_tasks.any((task) => task.id == taskId)) {
        print('Task $taskId already deleted or not found');
        return true; // Task already deleted
      }

      print('Deleting task $taskId from Firebase...');
      // Delete from Firebase
      await _taskService.deleteTask(taskId);

      print('Waiting for stream to update after deletion of task $taskId...');
      // Wait for the stream listener to update _tasks by polling
      // with a reasonable timeout to avoid infinite waiting
      const maxWaitTime = Duration(seconds: 5);
      const pollInterval = Duration(milliseconds: 100);
      final startTime = DateTime.now();

      while (_tasks.any((task) => task.id == taskId)) {
        if (DateTime.now().difference(startTime) > maxWaitTime) {
          print(
            'Timeout waiting for stream update, forcing local removal of task $taskId',
          );
          // Timeout reached, but deletion likely succeeded in Firebase
          // Force remove from local state as fallback
          _tasks.removeWhere((task) => task.id == taskId);
          notifyListeners();
          break;
        }
        await Future.delayed(pollInterval);
      }

      print('Task $taskId successfully deleted and removed from UI');
      return true;
    } catch (e) {
      print('Error deleting task $taskId: $e');
      return false;
    }
  }

  // Toggle task completion status
  Future<bool> toggleTaskCompletion(String taskId) async {
    try {
      final task = _tasks.firstWhere((t) => t.id == taskId);
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      await _taskService.updateTask(updatedTask);
      return true;
    } catch (e) {
      // Debug: Error toggling task completion: $e
      return false;
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
  Future<void> updateUser(AppUser updatedUser) async {
    try {
      print(
        'TaskProvider: Starting user update for ${updatedUser.displayName}',
      );

      // Update Firebase Auth profile (only displayName, not email)
      print('TaskProvider: Updating Firebase Auth profile...');
      await _authService.updateProfile(displayName: updatedUser.displayName);
      print('TaskProvider: Firebase Auth profile updated successfully');

      // Update Firestore user profile
      print('TaskProvider: Updating Firestore user profile...');
      await _userService.updateUserProfile(updatedUser);
      print('TaskProvider: Firestore user profile updated successfully');

      // Update local state
      _currentUser = updatedUser;
      notifyListeners();
      print('TaskProvider: User update completed successfully');
    } catch (e) {
      print('TaskProvider: Error updating user: $e');
      // Re-throw the error so the UI can handle it
      rethrow;
    }
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
  Future<bool> assignTaskToMembers(
    String taskId,
    String teamId,
    List<String> memberIds,
  ) async {
    try {
      await _taskService.assignTaskToMembers(taskId, teamId, memberIds);
      return true;
    } catch (e) {
      // Debug: Error assigning task to members: $e
      return false;
    }
  }

  // Assign task to a single team member (backward compatibility)
  Future<bool> assignTaskToMember(
    String taskId,
    String teamId,
    String memberId,
  ) async {
    return assignTaskToMembers(taskId, teamId, [memberId]);
  }

  // Add a member to an existing task assignment
  Future<bool> addMemberToTask(String taskId, String memberId) async {
    try {
      await _taskService.addMemberToTask(taskId, memberId);
      return true;
    } catch (e) {
      // Debug: Error adding member to task: $e
      return false;
    }
  }

  // Remove a member from an existing task assignment
  Future<bool> removeMemberFromTask(String taskId, String memberId) async {
    try {
      await _taskService.removeMemberFromTask(taskId, memberId);
      return true;
    } catch (e) {
      // Debug: Error removing member from task: $e
      return false;
    }
  }

  // Remove team assignment from task
  Future<bool> removeTeamAssignment(String taskId) async {
    try {
      await _taskService.removeTeamAssignment(taskId);
      return true;
    } catch (e) {
      // Debug: Error removing team assignment: $e
      return false;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _authSubscription?.cancel();
    _tasksSubscription?.cancel();
    _userSubscription?.cancel();
    super.dispose();
  }
}
