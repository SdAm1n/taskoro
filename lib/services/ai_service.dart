import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  static const String _geminiApiKey =
      'AIzaSyAM6kjJ8A-kLipJq2EV2RSWqV6ohhLzkkA'; // Using your existing Google API key
  static const String _ollamaBaseUrl =
      'http://localhost:11434/api'; // Local Ollama instance

  late final GenerativeModel _geminiModel;

  AIService() {
    _geminiModel = GenerativeModel(model: 'gemini-pro', apiKey: _geminiApiKey);
  }

  /// Generate detailed task description from title using AI
  Future<String> generateTaskDescription(
    String title, {
    String? context,
  }) async {
    try {
      // Try Gemini first
      final geminiResult = await _generateWithGemini(title, context);
      if (geminiResult.isNotEmpty) return geminiResult;

      // Fallback to local Ollama if available
      final ollamaResult = await _generateWithOllama(title, context);
      if (ollamaResult.isNotEmpty) return ollamaResult;

      // Final fallback to rule-based generation
      return _generateRuleBasedDescription(title);
    } catch (e) {
      debugPrint('AI description generation failed: $e');
      return _generateRuleBasedDescription(title);
    }
  }

  /// Generate task suggestions based on user patterns and context
  Future<List<String>> generateTaskSuggestions({
    required List<String> recentTasks,
    String? currentContext,
    DateTime? targetDate,
  }) async {
    try {
      final prompt = '''
Based on the user's recent tasks and current context, suggest 5 relevant tasks they might want to add:

Recent tasks: ${recentTasks.join(', ')}
Current context: ${currentContext ?? 'general productivity'}
Target date: ${targetDate?.toString() ?? 'today'}

Provide 5 practical, actionable task suggestions that follow the user's patterns. 
Return only the task titles, one per line, without numbering or bullets.
''';

      final response = await _geminiModel.generateContent([
        Content.text(prompt),
      ]);
      if (response.text?.isNotEmpty == true) {
        return response.text!
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .take(5)
            .toList();
      }
    } catch (e) {
      debugPrint('Task suggestions generation failed: $e');
    }

    return _generateRuleBasedSuggestions(recentTasks);
  }

  /// Parse natural language input to extract task details
  Future<Map<String, dynamic>> parseNaturalLanguageTask(String input) async {
    try {
      final prompt = '''
Parse this natural language input into a structured task format:
"$input"

Extract and return a JSON object with these fields:
- title: Main task title (required)
- description: Detailed description
- priority: "high", "medium", or "low"
- dueDate: ISO date string if mentioned (null if not)
- category: Inferred category like "work", "personal", "health", etc.
- estimatedDuration: Number of minutes if mentioned
- location: Location if mentioned
- tags: Array of relevant tags

Example: "Schedule dentist appointment for next Tuesday at 2pm in downtown clinic"
Should return: {
  "title": "Schedule dentist appointment",
  "description": "Book appointment with dentist for routine checkup",
  "priority": "medium",
  "dueDate": "2025-06-03T14:00:00Z",
  "category": "health",
  "estimatedDuration": 60,
  "location": "downtown clinic",
  "tags": ["health", "appointment", "dentist"]
}

Return only valid JSON, no additional text.
''';

      final response = await _geminiModel.generateContent([
        Content.text(prompt),
      ]);
      if (response.text?.isNotEmpty == true) {
        try {
          final cleanJson =
              response.text!
                  .replaceAll('```json', '')
                  .replaceAll('```', '')
                  .trim();
          return jsonDecode(cleanJson);
        } catch (e) {
          debugPrint('JSON parsing failed: $e');
        }
      }
    } catch (e) {
      debugPrint('Natural language parsing failed: $e');
    }

    return _parseRuleBasedTask(input);
  }

  /// Generate smart scheduling suggestions
  Future<List<Map<String, dynamic>>> generateSchedulingSuggestions({
    required List<Map<String, dynamic>> existingTasks,
    required Map<String, dynamic> newTask,
  }) async {
    try {
      final prompt = '''
Given this new task and existing schedule, suggest the best times to schedule it:

New task: ${newTask['title']} (estimated ${newTask['estimatedDuration'] ?? 30} minutes)
Priority: ${newTask['priority'] ?? 'medium'}

Existing tasks: ${existingTasks.map((t) => '${t['title']} at ${t['dueDate']}').join(', ')}

Suggest 3 optimal time slots considering:
- Task priority and urgency
- Existing schedule conflicts
- Optimal productivity times
- Buffer time between tasks

Return JSON array with format:
[
  {
    "suggestedTime": "2025-05-28T09:00:00Z",
    "reason": "Morning slot for high focus tasks",
    "confidence": 0.9
  }
]
''';

      final response = await _geminiModel.generateContent([
        Content.text(prompt),
      ]);
      if (response.text?.isNotEmpty == true) {
        try {
          final cleanJson =
              response.text!
                  .replaceAll('```json', '')
                  .replaceAll('```', '')
                  .trim();
          return List<Map<String, dynamic>>.from(jsonDecode(cleanJson));
        } catch (e) {
          debugPrint('Scheduling JSON parsing failed: $e');
        }
      }
    } catch (e) {
      debugPrint('Scheduling suggestions failed: $e');
    }

    return [];
  }

  /// AI-powered chat for task management
  Future<String> chatWithAI(
    String message, {
    Map<String, dynamic>? context,
  }) async {
    try {
      // Validate API key first
      if (_geminiApiKey.isEmpty) {
        debugPrint('Gemini API key is empty');
        return 'AI service is not properly configured. Please check your API key.';
      }

      final systemContext = '''
You are TaskoroAI, an intelligent assistant for task management. Help users with:
- Creating, updating, and organizing tasks
- Scheduling and time management
- Productivity tips and suggestions
- Breaking down complex projects
- Setting priorities and deadlines

Context: ${context != null ? jsonEncode(context) : 'General assistance'}

Be helpful, concise, and actionable in your responses.
''';

      final prompt = '$systemContext\n\nUser: $message\n\nAssistant:';

      debugPrint('Sending request to Gemini API...');
      final response = await _geminiModel.generateContent([
        Content.text(prompt),
      ]);

      debugPrint('Received response from Gemini API');
      final responseText = response.text;

      if (responseText != null && responseText.isNotEmpty) {
        return responseText;
      } else {
        debugPrint('Empty response from Gemini API');
        return 'I received an empty response. Please try rephrasing your question.';
      }
    } catch (e) {
      debugPrint('AI chat failed with error: $e');
      debugPrint('Error type: ${e.runtimeType}');

      // More specific error messages
      if (e.toString().contains('API_KEY_INVALID')) {
        return 'Invalid API key. Please check your Gemini API configuration.';
      } else if (e.toString().contains('QUOTA_EXCEEDED')) {
        return 'API quota exceeded. Please try again later.';
      } else if (e.toString().contains('NETWORK')) {
        return 'Network connection issue. Please check your internet connection.';
      } else {
        return 'I\'m having trouble connecting right now. Please try again later.\n\nError: ${e.toString()}';
      }
    }
  }

  // Private helper methods
  Future<String> _generateWithGemini(String title, String? context) async {
    final prompt = '''
Generate a detailed, actionable description for this task: "$title"

Context: ${context ?? 'general task'}

Create a description that includes:
- What needs to be done
- Key steps or considerations
- Potential challenges or requirements
- Expected outcome

Keep it practical and under 200 words.
''';

    final response = await _geminiModel.generateContent([Content.text(prompt)]);
    return response.text?.trim() ?? '';
  }

  Future<String> _generateWithOllama(String title, String? context) async {
    try {
      final response = await http.post(
        Uri.parse('$_ollamaBaseUrl/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'llama3.2',
          'prompt':
              'Generate a detailed task description for: $title\nContext: ${context ?? 'general task'}\nDescription:',
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? '';
      }
    } catch (e) {
      debugPrint('Ollama request failed: $e');
    }
    return '';
  }

  String _generateRuleBasedDescription(String title) {
    final lowerTitle = title.toLowerCase();

    if (lowerTitle.contains('meeting') || lowerTitle.contains('call')) {
      return 'Prepare agenda, gather necessary materials, and ensure all participants are notified. Review relevant documents beforehand and set clear objectives for the discussion.';
    } else if (lowerTitle.contains('exercise') ||
        lowerTitle.contains('workout') ||
        lowerTitle.contains('gym')) {
      return 'Plan your workout routine, prepare appropriate clothing and equipment. Stay hydrated and focus on proper form. Track your progress and adjust intensity as needed.';
    } else if (lowerTitle.contains('study') ||
        lowerTitle.contains('learn') ||
        lowerTitle.contains('research')) {
      return 'Gather relevant materials and create a focused study environment. Break down the topic into manageable sections and take regular breaks. Make notes and test your understanding.';
    } else if (lowerTitle.contains('shop') ||
        lowerTitle.contains('buy') ||
        lowerTitle.contains('purchase')) {
      return 'Create a list of items needed, compare prices and reviews. Check for discounts or promotions. Ensure you have budget allocated and payment method ready.';
    } else {
      return 'Plan the necessary steps to complete this task efficiently. Gather required resources, set realistic timelines, and track progress. Consider potential obstacles and prepare solutions.';
    }
  }

  List<String> _generateRuleBasedSuggestions(List<String> recentTasks) {
    final suggestions = <String>[];
    final categories = {
      'work': [
        'Review emails',
        'Update project status',
        'Schedule team meeting',
        'Prepare presentation',
      ],
      'health': [
        'Drink 8 glasses of water',
        'Take a 10-minute walk',
        'Practice deep breathing',
        'Stretch for 5 minutes',
      ],
      'personal': [
        'Call family member',
        'Read for 30 minutes',
        'Organize workspace',
        'Plan tomorrow\'s tasks',
      ],
      'learning': [
        'Watch educational video',
        'Practice new skill',
        'Review notes',
        'Take online course',
      ],
    };

    // Suggest tasks from different categories
    for (var tasks in categories.values) {
      if (suggestions.length < 5) {
        suggestions.add(tasks[DateTime.now().millisecond % tasks.length]);
      }
    }

    return suggestions.take(5).toList();
  }

  Map<String, dynamic> _parseRuleBasedTask(String input) {
    final lowerInput = input.toLowerCase();

    // Extract priority
    String priority = 'medium';
    if (lowerInput.contains('urgent') ||
        lowerInput.contains('asap') ||
        lowerInput.contains('important')) {
      priority = 'high';
    } else if (lowerInput.contains('later') ||
        lowerInput.contains('when possible') ||
        lowerInput.contains('someday')) {
      priority = 'low';
    }

    // Extract category
    String category = 'personal';
    if (lowerInput.contains('work') ||
        lowerInput.contains('office') ||
        lowerInput.contains('meeting')) {
      category = 'work';
    } else if (lowerInput.contains('doctor') ||
        lowerInput.contains('health') ||
        lowerInput.contains('exercise')) {
      category = 'health';
    } else if (lowerInput.contains('study') ||
        lowerInput.contains('learn') ||
        lowerInput.contains('course')) {
      category = 'learning';
    }

    // Basic time extraction
    DateTime? dueDate;
    if (lowerInput.contains('today')) {
      dueDate = DateTime.now();
    } else if (lowerInput.contains('tomorrow')) {
      dueDate = DateTime.now().add(const Duration(days: 1));
    } else if (lowerInput.contains('next week')) {
      dueDate = DateTime.now().add(const Duration(days: 7));
    }

    return {
      'title': _extractTitle(input),
      'description': _generateRuleBasedDescription(input),
      'priority': priority,
      'dueDate': dueDate?.toIso8601String(),
      'category': category,
      'estimatedDuration': 30,
      'location': null,
      'tags': [category],
    };
  }

  String _extractTitle(String input) {
    // Remove common prefixes and clean up
    final cleaned =
        input
            .replaceAll(
              RegExp(
                r'^(i need to|i have to|i should|i want to|i will|add task|create task|new task)\s*',
                caseSensitive: false,
              ),
              '',
            )
            .replaceAll(
              RegExp(
                r'\s+(today|tomorrow|next week|urgent|asap|important).*$',
                caseSensitive: false,
              ),
              '',
            )
            .trim();

    // Capitalize first letter
    if (cleaned.isEmpty) return input;
    return cleaned[0].toUpperCase() + cleaned.substring(1);
  }
}
