import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ai_service.dart';
import 'speech_service.dart';
import '../models/task.dart';
import 'firebase_task_service.dart';

class AITaskService extends ChangeNotifier {
  final AIService _aiService = AIService();
  final SpeechService _speechService = SpeechService();
  final FirebaseTaskService _taskService = FirebaseTaskService();

  bool _isProcessing = false;
  String _lastAIResponse = '';
  List<String> _taskSuggestions = [];
  List<Map<String, dynamic>> _schedulingSuggestions = [];

  // Getters
  bool get isProcessing => _isProcessing;
  String get lastAIResponse => _lastAIResponse;
  List<String> get taskSuggestions => _taskSuggestions;
  List<Map<String, dynamic>> get schedulingSuggestions =>
      _schedulingSuggestions;
  SpeechService get speechService => _speechService;

  /// Create task from voice input
  Future<Task?> createTaskFromVoice({String? prompt, String? userId}) async {
    if (userId == null) return null;

    _isProcessing = true;
    notifyListeners();

    try {
      // Listen for voice input with extended timeout
      final voiceInput = await _speechService.listenForPhrase(
        timeout: const Duration(seconds: 30),
        prompt: prompt ?? "What task would you like to create?",
      );

      if (voiceInput == null || voiceInput.trim().isEmpty) {
        await _speechService.speak(
          "I didn't capture any speech. Let me try listening again.",
        );
        // Try one more time with a shorter timeout
        final retryInput = await _speechService.listenForPhrase(
          timeout: const Duration(seconds: 15),
          prompt: "Please speak your task clearly now.",
        );

        if (retryInput == null || retryInput.trim().isEmpty) {
          await _speechService.speak(
            "I still couldn't hear anything. Please check your microphone and try again.",
          );
          return null;
        } else {
          // Use the retry input
          final finalInput = retryInput.trim();
          await _speechService.speak("Got it! Creating task: $finalInput");
          // Continue with task creation using finalInput
          final taskData = await _aiService.parseNaturalLanguageTask(
            finalInput,
          );

          // Generate description if not provided
          if (taskData['description'] == null ||
              taskData['description'].isEmpty) {
            taskData['description'] = await _aiService.generateTaskDescription(
              taskData['title'],
              context: taskData['category'],
            );
          }

          // Create the task
          final now = DateTime.now();
          final endDate =
              taskData['dueDate'] != null
                  ? DateTime.tryParse(taskData['dueDate']) ??
                      now.add(Duration(days: 1))
                  : now.add(Duration(days: 1));

          final task = Task(
            id: '', // Will be set by Firebase
            title: taskData['title'] ?? finalInput,
            description: taskData['description'] ?? '',
            startDate: now,
            endDate: endDate,
            priority: _stringToPriority(taskData['priority']),
            category: _stringToCategory(taskData['category']),
            isCompleted: false,
            createdAt: now,
          );

          // Save to Firebase
          final taskId = await _taskService.createTask(task);

          // Retrieve the created task to return it
          final savedTask = task.copyWith(id: taskId);

          await _speechService.speak(
            "Task '${savedTask.title}' has been created successfully!",
          );

          // Generate scheduling suggestions
          await _generateSchedulingSuggestions(savedTask, userId);

          return savedTask;
        }
      }

      // Provide voice feedback
      await _speechService.speak("Got it! Creating task: $voiceInput");

      // Parse the voice input using AI
      final taskData = await _aiService.parseNaturalLanguageTask(voiceInput);

      // Generate description if not provided
      if (taskData['description'] == null || taskData['description'].isEmpty) {
        taskData['description'] = await _aiService.generateTaskDescription(
          taskData['title'],
          context: taskData['category'],
        );
      }

      // Create the task
      final now = DateTime.now();
      final endDate =
          taskData['dueDate'] != null
              ? DateTime.tryParse(taskData['dueDate']) ??
                  now.add(Duration(days: 1))
              : now.add(Duration(days: 1));

      final task = Task(
        id: '', // Will be set by Firebase
        title: taskData['title'] ?? voiceInput,
        description: taskData['description'] ?? '',
        startDate: now,
        endDate: endDate,
        priority: _stringToPriority(taskData['priority']),
        category: _stringToCategory(taskData['category']),
        isCompleted: false,
        createdAt: now,
      );

      // Save to Firebase
      final taskId = await _taskService.createTask(task);

      // Retrieve the created task to return it
      final savedTask = task.copyWith(id: taskId);

      await _speechService.speak(
        "Task '${savedTask.title}' has been created successfully!",
      );

      // Generate scheduling suggestions
      await _generateSchedulingSuggestions(savedTask, userId);

      return savedTask;
    } catch (e) {
      debugPrint('Voice task creation error: $e');
      await _speechService.speak(
        "Sorry, I couldn't create that task. Please try again.",
      );
      return null;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Create task from text input using AI enhancement
  Future<Task?> createTaskFromText({
    required String input,
    required String userId,
  }) async {
    _isProcessing = true;
    notifyListeners();

    try {
      // Parse the text input using AI
      final taskData = await _aiService.parseNaturalLanguageTask(input);

      // Generate description if not provided
      if (taskData['description'] == null || taskData['description'].isEmpty) {
        taskData['description'] = await _aiService.generateTaskDescription(
          taskData['title'],
          context: taskData['category'],
        );
      }

      // Create the task
      final now = DateTime.now();
      final endDate =
          taskData['dueDate'] != null
              ? DateTime.tryParse(taskData['dueDate']) ??
                  now.add(Duration(days: 1))
              : now.add(Duration(days: 1));

      final task = Task(
        id: '', // Will be set by Firebase
        title: taskData['title'] ?? input,
        description: taskData['description'] ?? '',
        startDate: now,
        endDate: endDate,
        priority: _stringToPriority(taskData['priority']),
        category: _stringToCategory(taskData['category']),
        isCompleted: false,
        createdAt: now,
      );

      // Save to Firebase
      final taskId = await _taskService.createTask(task);

      // Retrieve the created task to return it
      final savedTask = task.copyWith(id: taskId);

      // Generate scheduling suggestions
      await _generateSchedulingSuggestions(savedTask, userId);

      return savedTask;
    } catch (e) {
      debugPrint('Text task creation error: $e');
      return null;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Generate task description using AI
  Future<String> generateTaskDescription(
    String title, {
    String? context,
  }) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final description = await _aiService.generateTaskDescription(
        title,
        context: context,
      );
      return description;
    } catch (e) {
      debugPrint('Description generation error: $e');
      return 'Complete this task efficiently and effectively.';
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Get AI-powered task suggestions
  Future<void> generateTaskSuggestions({
    required String userId,
    String? context,
  }) async {
    _isProcessing = true;
    notifyListeners();

    try {
      // Get recent tasks for context
      final recentTasks = await _getRecentTasks(userId, limit: 10);
      final recentTaskTitles = recentTasks.map((t) => t.title).toList();

      _taskSuggestions = await _aiService.generateTaskSuggestions(
        recentTasks: recentTaskTitles,
        currentContext: context,
        targetDate: DateTime.now(),
      );

      notifyListeners();
    } catch (e) {
      debugPrint('Task suggestions error: $e');
      _taskSuggestions = [];
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Delete task with voice confirmation
  Future<bool> deleteTaskWithVoice(Task task) async {
    try {
      // Ask for confirmation
      final confirmation = await _speechService.listenForPhrase(
        timeout: const Duration(seconds: 10),
        prompt:
            "Are you sure you want to delete '${task.title}'? Say yes or no.",
      );

      if (confirmation != null &&
          (confirmation.toLowerCase().contains('yes') ||
              confirmation.toLowerCase().contains('confirm') ||
              confirmation.toLowerCase().contains('delete'))) {
        try {
          await _taskService.deleteTask(task.id);
          await _speechService.speak("Task '${task.title}' has been deleted.");
          return true;
        } catch (e) {
          await _speechService.speak("Sorry, I couldn't delete that task.");
          return false;
        }
      } else {
        await _speechService.speak("Task deletion cancelled.");
        return false;
      }
    } catch (e) {
      debugPrint('Voice task deletion error: $e');
      await _speechService.speak("Sorry, I couldn't process that request.");
      return false;
    }
  }

  /// AI chat for task management
  Future<String> chatWithAI(String message, {String? userId}) async {
    _isProcessing = true;
    notifyListeners();

    try {
      // Check if the message is a task creation request
      final lowerMessage = message.toLowerCase();
      final isTaskCreationRequest = lowerMessage.contains('create') ||
          lowerMessage.contains('add') ||
          lowerMessage.contains('new task') ||
          lowerMessage.contains('make a task') ||
          lowerMessage.contains('remind me') ||
          lowerMessage.contains('schedule');

      if (isTaskCreationRequest && userId != null) {
        try {
          // Try to create a task from the message
          final createdTask = await createTaskFromText(
            input: message,
            userId: userId,
          );

          if (createdTask != null) {
            _lastAIResponse = 
                "Perfect! I've created the task '${createdTask.title}' for you.\n\n"
                "📋 **Task Details:**\n"
                "• **Title:** ${createdTask.title}\n"
                "• **Description:** ${createdTask.description.isNotEmpty ? createdTask.description : 'No description'}\n"
                "• **Priority:** ${_capitalizeString(createdTask.priority.toString().split('.').last)}\n"
                "• **Category:** ${_capitalizeString(createdTask.category.toString().split('.').last)}\n"
                "• **Due Date:** ${createdTask.endDate.day}/${createdTask.endDate.month}/${createdTask.endDate.year}\n\n"
                "The task has been saved to your task list! Is there anything else you'd like me to help you with?";
            notifyListeners();
            return _lastAIResponse;
          } else {
            // Fall back to conversational AI if task creation failed
            debugPrint('Task creation failed, falling back to conversational AI');
          }
        } catch (e) {
          debugPrint('Task creation from chat failed: $e');
          // Fall back to conversational AI if task creation failed
        }
      }

      // For non-task-creation requests or if task creation failed, 
      // provide conversational AI response
      Map<String, dynamic>? context;

      if (userId != null) {
        final recentTasks = await _getRecentTasks(userId, limit: 5);
        context = {
          'userId': userId,
          'recentTasks':
              recentTasks
                  .map(
                    (t) => {
                      'title': t.title,
                      'category': t.category.toString(),
                      'priority': t.priority.toString(),
                      'isCompleted': t.isCompleted,
                      'endDate': t.endDate.toIso8601String(),
                    },
                  )
                  .toList(),
          'taskCount': recentTasks.length,
        };
      }

      _lastAIResponse = await _aiService.chatWithAI(message, context: context);
      notifyListeners();
      return _lastAIResponse;
    } catch (e) {
      debugPrint('AI chat error: $e');
      _lastAIResponse =
          'I apologize, but I cannot process that request right now.';
      return _lastAIResponse;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Voice-controlled task management
  Future<void> voiceTaskManagement({String? userId}) async {
    if (userId == null) return;

    try {
      await _speechService.speak(
        "Hi! I'm your AI task assistant. You can say 'create task', 'show tasks', 'delete task', or ask me anything about your tasks.",
      );

      await for (final voiceInput in _speechService.continuousListen(
        phraseTimeout: const Duration(seconds: 8),
        sessionTimeout: const Duration(minutes: 5),
      )) {
        final lowerInput = voiceInput.toLowerCase();

        if (lowerInput.contains('create') ||
            lowerInput.contains('add') ||
            lowerInput.contains('new task')) {
          await createTaskFromVoice(
            prompt: "What task would you like to create?",
            userId: userId,
          );
        } else if (lowerInput.contains('show') ||
            lowerInput.contains('list') ||
            lowerInput.contains('my tasks')) {
          await _readTasksSummary(userId);
        } else if (lowerInput.contains('delete') ||
            lowerInput.contains('remove')) {
          await _voiceDeleteTask(userId);
        } else if (lowerInput.contains('complete') ||
            lowerInput.contains('done')) {
          await _voiceCompleteTask(userId);
        } else if (lowerInput.contains('help')) {
          await _speechService.speak(
            "I can help you create tasks, show your tasks, delete tasks, mark tasks as complete, or answer questions about task management. What would you like to do?",
          );
        } else if (lowerInput.contains('bye') ||
            lowerInput.contains('stop') ||
            lowerInput.contains('exit')) {
          await _speechService.speak("Goodbye! Have a productive day!");
          break;
        } else {
          // General AI chat
          final response = await chatWithAI(voiceInput, userId: userId);
          await _speechService.speak(response);
        }
      }
    } catch (e) {
      debugPrint('Voice task management error: $e');
      await _speechService.speak(
        "Sorry, there was an error. Please try again.",
      );
    }
  }

  // Private helper methods
  TaskPriority _stringToPriority(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return TaskPriority.high;
      case 'low':
        return TaskPriority.low;
      default:
        return TaskPriority.medium;
    }
  }

  TaskCategory _stringToCategory(String? category) {
    switch (category?.toLowerCase()) {
      case 'work':
        return TaskCategory.work;
      case 'shopping':
        return TaskCategory.shopping;
      case 'health':
        return TaskCategory.health;
      case 'study':
        return TaskCategory.study;
      case 'other':
        return TaskCategory.other;
      default:
        return TaskCategory.personal;
    }
  }

  Future<List<Task>> _getRecentTasks(String userId, {int limit = 10}) async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('tasks')
              .where('userId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .limit(limit)
              .get();

      return snapshot.docs
          .map((doc) => Task.fromMap({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      debugPrint('Get recent tasks error: $e');
      return [];
    }
  }

  Future<void> _generateSchedulingSuggestions(Task task, String userId) async {
    try {
      final existingTasks = await _getRecentTasks(userId, limit: 20);
      final existingTaskData =
          existingTasks
              .map(
                (t) => {
                  'title': t.title,
                  'endDate': t.endDate.toIso8601String(),
                  'priority': t.priority.toString(),
                  'category': t.category.toString(),
                },
              )
              .toList();

      final newTaskData = {
        'title': task.title,
        'priority': task.priority.toString(),
        'category': task.category.toString(),
      };

      _schedulingSuggestions = await _aiService.generateSchedulingSuggestions(
        existingTasks: existingTaskData,
        newTask: newTaskData,
      );

      notifyListeners();
    } catch (e) {
      debugPrint('Scheduling suggestions error: $e');
    }
  }

  Future<void> _readTasksSummary(String userId) async {
    try {
      final tasks = await _getRecentTasks(userId, limit: 5);

      if (tasks.isEmpty) {
        await _speechService.speak(
          "You have no tasks at the moment. Would you like to create one?",
        );
        return;
      }

      final incompleteTasks = tasks.where((t) => !t.isCompleted).toList();
      final completedTasks = tasks.where((t) => t.isCompleted).toList();

      String summary = "Here's your task summary: ";

      if (incompleteTasks.isNotEmpty) {
        summary += "${incompleteTasks.length} pending tasks: ";
        for (int i = 0; i < incompleteTasks.length && i < 3; i++) {
          summary += "${i + 1}. ${incompleteTasks[i].title}. ";
        }
      }

      if (completedTasks.isNotEmpty) {
        summary += "And ${completedTasks.length} completed tasks.";
      }

      await _speechService.speak(summary);
    } catch (e) {
      debugPrint('Read tasks summary error: $e');
      await _speechService.speak(
        "Sorry, I couldn't read your tasks right now.",
      );
    }
  }

  Future<void> _voiceDeleteTask(String userId) async {
    try {
      final tasks = await _getRecentTasks(userId, limit: 10);
      final incompleteTasks = tasks.where((t) => !t.isCompleted).toList();

      if (incompleteTasks.isEmpty) {
        await _speechService.speak("You have no tasks to delete.");
        return;
      }

      // Read task options
      String taskOptions = "Which task would you like to delete? ";
      for (int i = 0; i < incompleteTasks.length && i < 5; i++) {
        taskOptions += "${i + 1}. ${incompleteTasks[i].title}. ";
      }
      taskOptions += "Say the number or the task name.";

      final response = await _speechService.listenForPhrase(
        timeout: const Duration(seconds: 15),
        prompt: taskOptions,
      );

      if (response != null) {
        Task? taskToDelete;

        // Try to match by number
        final match = RegExp(r'\b(\d+)\b').firstMatch(response);
        if (match != null) {
          final index = int.tryParse(match.group(1)!) ?? 0;
          if (index > 0 && index <= incompleteTasks.length) {
            taskToDelete = incompleteTasks[index - 1];
          }
        }

        // Try to match by title
        if (taskToDelete == null) {
          for (final task in incompleteTasks) {
            if (task.title.toLowerCase().contains(response.toLowerCase())) {
              taskToDelete = task;
              break;
            }
          }
        }

        if (taskToDelete != null) {
          await deleteTaskWithVoice(taskToDelete);
        } else {
          await _speechService.speak(
            "I couldn't find that task. Please try again.",
          );
        }
      }
    } catch (e) {
      debugPrint('Voice delete task error: $e');
      await _speechService.speak("Sorry, I couldn't delete that task.");
    }
  }

  Future<void> _voiceCompleteTask(String userId) async {
    try {
      final tasks = await _getRecentTasks(userId, limit: 10);
      final incompleteTasks = tasks.where((t) => !t.isCompleted).toList();

      if (incompleteTasks.isEmpty) {
        await _speechService.speak(
          "You have no pending tasks to complete. Great job!",
        );
        return;
      }

      // Read task options
      String taskOptions = "Which task did you complete? ";
      for (int i = 0; i < incompleteTasks.length && i < 5; i++) {
        taskOptions += "${i + 1}. ${incompleteTasks[i].title}. ";
      }
      taskOptions += "Say the number or the task name.";

      final response = await _speechService.listenForPhrase(
        timeout: const Duration(seconds: 15),
        prompt: taskOptions,
      );

      if (response != null) {
        Task? taskToComplete;

        // Try to match by number
        final match = RegExp(r'\b(\d+)\b').firstMatch(response);
        if (match != null) {
          final index = int.tryParse(match.group(1)!) ?? 0;
          if (index > 0 && index <= incompleteTasks.length) {
            taskToComplete = incompleteTasks[index - 1];
          }
        }

        // Try to match by title
        if (taskToComplete == null) {
          for (final task in incompleteTasks) {
            if (task.title.toLowerCase().contains(response.toLowerCase())) {
              taskToComplete = task;
              break;
            }
          }
        }

        if (taskToComplete != null) {
          final updatedTask = taskToComplete.copyWith(isCompleted: true);

          try {
            await _taskService.updateTask(updatedTask);
            await _speechService.speak(
              "Great! '${taskToComplete.title}' has been marked as complete. Well done!",
            );
          } catch (e) {
            await _speechService.speak("Sorry, I couldn't update that task.");
          }
        } else {
          await _speechService.speak(
            "I couldn't find that task. Please try again.",
          );
        }
      }
    } catch (e) {
      debugPrint('Voice complete task error: $e');
      await _speechService.speak("Sorry, I couldn't complete that task.");
    }
  }

  // Helper method to capitalize strings
  String _capitalizeString(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }
}
