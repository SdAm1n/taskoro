import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/task.dart';

class FirebaseTaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  // Collection references
  CollectionReference get _tasksCollection => _firestore.collection('tasks');

  // Create a new task
  Future<String> createTask(Task task) async {
    debugPrint('FirebaseTaskService: Starting task creation'); // Debug log

    if (_currentUserId == null) {
      debugPrint(
        'FirebaseTaskService: No authenticated user found',
      ); // Debug log
      throw Exception('User not authenticated');
    }

    try {
      debugPrint(
        'FirebaseTaskService: Creating task for user: $_currentUserId',
      ); // Debug log

      // Generate a new task ID if not provided
      final taskId = task.id.isEmpty ? _tasksCollection.doc().id : task.id;

      debugPrint(
        'FirebaseTaskService: Generated task ID: $taskId',
      ); // Debug log

      // Create task with user ownership
      final taskData = task.copyWith(id: taskId).toMap();
      taskData['userId'] = _currentUserId; // Associate task with current user
      taskData['createdBy'] = _currentUserId;
      taskData['createdAt'] = DateTime.now().millisecondsSinceEpoch;
      taskData['updatedAt'] = DateTime.now().millisecondsSinceEpoch;

      debugPrint(
        'FirebaseTaskService: Task data prepared, writing to Firestore',
      ); // Debug log
      debugPrint(
        'FirebaseTaskService: Task data: ${taskData.keys.join(', ')}',
      ); // Debug log

      // Add timeout to prevent hanging
      await _tasksCollection
          .doc(taskId)
          .set(taskData)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              debugPrint(
                'FirebaseTaskService: Firestore write operation timed out',
              ); // Debug log
              throw Exception(
                'Task creation timed out - check internet connection',
              );
            },
          );

      debugPrint(
        'FirebaseTaskService: Task created successfully with ID: $taskId',
      ); // Debug log

      return taskId;
    } catch (e) {
      debugPrint('FirebaseTaskService: Error creating task: $e'); // Debug log
      debugPrint(
        'FirebaseTaskService: Error type: ${e.runtimeType}',
      ); // Debug log
      throw Exception('Failed to create task: $e');
    }
  }

  // Get all tasks for current user
  Stream<List<Task>> getUserTasks() {
    if (_currentUserId == null) return Stream.value([]);

    return _tasksCollection
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return Task.fromMap(data);
          }).toList();
        });
  }

  // Get tasks for a specific team
  Stream<List<Task>> getTeamTasks(String teamId) {
    if (_currentUserId == null) return Stream.value([]);

    return _tasksCollection
        .where('assignedTeamId', isEqualTo: teamId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return Task.fromMap(data);
          }).toList();
        });
  }

  // Get tasks assigned to a specific member
  Stream<List<Task>> getMemberTasks(String memberId) {
    if (_currentUserId == null) return Stream.value([]);

    return _tasksCollection
        .where('assignedMemberIds', arrayContains: memberId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return Task.fromMap(data);
          }).toList();
        });
  }

  // Get tasks for a specific date range
  Stream<List<Task>> getTasksForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    if (_currentUserId == null) return Stream.value([]);

    return _tasksCollection
        .where('userId', isEqualTo: _currentUserId)
        .where(
          'startDate',
          isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch,
        )
        .where('endDate', isLessThanOrEqualTo: endDate.millisecondsSinceEpoch)
        .orderBy('startDate')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return Task.fromMap(data);
          }).toList();
        });
  }

  // Update an existing task
  Future<void> updateTask(Task task) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      final taskData = task.toMap();
      taskData['updatedAt'] = DateTime.now().millisecondsSinceEpoch;

      await _tasksCollection.doc(task.id).update(taskData);
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      await _tasksCollection.doc(taskId).delete();
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  // Toggle task completion status
  Future<void> toggleTaskCompletion(String taskId) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      final doc = await _tasksCollection.doc(taskId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final currentStatus = data['isCompleted'] ?? false;

        await _tasksCollection.doc(taskId).update({
          'isCompleted': !currentStatus,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } catch (e) {
      throw Exception('Failed to toggle task completion: $e');
    }
  }

  // Assign task to team members
  Future<void> assignTaskToMembers(
    String taskId,
    String teamId,
    List<String> memberIds,
  ) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      await _tasksCollection.doc(taskId).update({
        'assignedTeamId': teamId,
        'assignedMemberIds': memberIds,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to assign task to members: $e');
    }
  }

  // Remove team assignment from task
  Future<void> removeTeamAssignment(String taskId) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      await _tasksCollection.doc(taskId).update({
        'assignedTeamId': null,
        'assignedMemberIds': null,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to remove team assignment: $e');
    }
  }

  // Add member to existing task assignment
  Future<void> addMemberToTask(String taskId, String memberId) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      await _tasksCollection.doc(taskId).update({
        'assignedMemberIds': FieldValue.arrayUnion([memberId]),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to add member to task: $e');
    }
  }

  // Remove member from task assignment
  Future<void> removeMemberFromTask(String taskId, String memberId) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      await _tasksCollection.doc(taskId).update({
        'assignedMemberIds': FieldValue.arrayRemove([memberId]),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to remove member from task: $e');
    }
  }

  // Get task by ID
  Future<Task?> getTaskById(String taskId) async {
    try {
      final doc = await _tasksCollection.doc(taskId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Task.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get task: $e');
    }
  }

  // Search tasks by title or description
  Future<List<Task>> searchTasks(String query) async {
    if (_currentUserId == null) return [];

    try {
      // Firebase doesn't support case-insensitive text search natively
      // This is a simple implementation that gets all user tasks and filters locally
      final snapshot =
          await _tasksCollection
              .where('userId', isEqualTo: _currentUserId)
              .get();

      final lowercaseQuery = query.toLowerCase();
      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return Task.fromMap(data);
          })
          .where(
            (task) =>
                task.title.toLowerCase().contains(lowercaseQuery) ||
                task.description.toLowerCase().contains(lowercaseQuery),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to search tasks: $e');
    }
  }

  // Get tasks by category
  Stream<List<Task>> getTasksByCategory(TaskCategory category) {
    if (_currentUserId == null) return Stream.value([]);

    return _tasksCollection
        .where('userId', isEqualTo: _currentUserId)
        .where('category', isEqualTo: category.toString().split('.').last)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return Task.fromMap(data);
          }).toList();
        });
  }

  // Get tasks by priority
  Stream<List<Task>> getTasksByPriority(TaskPriority priority) {
    if (_currentUserId == null) return Stream.value([]);

    return _tasksCollection
        .where('userId', isEqualTo: _currentUserId)
        .where('priority', isEqualTo: priority.toString().split('.').last)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return Task.fromMap(data);
          }).toList();
        });
  }

  // Get completed tasks
  Stream<List<Task>> getCompletedTasks() {
    if (_currentUserId == null) return Stream.value([]);

    return _tasksCollection
        .where('userId', isEqualTo: _currentUserId)
        .where('isCompleted', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return Task.fromMap(data);
          }).toList();
        });
  }

  // Get pending tasks
  Stream<List<Task>> getPendingTasks() {
    if (_currentUserId == null) return Stream.value([]);

    return _tasksCollection
        .where('userId', isEqualTo: _currentUserId)
        .where('isCompleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return Task.fromMap(data);
          }).toList();
        });
  }
}
