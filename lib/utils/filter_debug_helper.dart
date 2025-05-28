import 'package:flutter/foundation.dart';
import '../models/task.dart';

class FilterDebugHelper {
  static void debugFilterResults(
    String filterName,
    int filterIndex,
    List<Task> allTasks,
    List<Task> filteredTasks,
  ) {
    if (!kDebugMode) return;

    debugPrint('=== FILTER DEBUG: $filterName (Index: $filterIndex) ===');
    debugPrint('Total tasks: ${allTasks.length}');
    debugPrint('Filtered tasks: ${filteredTasks.length}');

    if (filterIndex == 3) {
      // Debug team filter specifically
      final personalTasks = allTasks.where((task) => !task.isTeamTask).toList();
      final teamTasks = allTasks.where((task) => task.isTeamTask).toList();

      debugPrint(
        'Personal tasks (assignedTeamId == null): ${personalTasks.length}',
      );
      debugPrint('Team tasks (assignedTeamId != null): ${teamTasks.length}');

      for (var task in allTasks.take(5)) {
        debugPrint(
          'Task: "${task.title}" - '
          'assignedTeamId: ${task.assignedTeamId} - '
          'isTeamTask: ${task.isTeamTask}',
        );
      }
    }

    if (filteredTasks.isEmpty && allTasks.isNotEmpty) {
      debugPrint('WARNING: Filter returned no results but total tasks exist!');
    }

    debugPrint('=== END FILTER DEBUG ===\n');
  }

  static void debugTaskCreation(Task task) {
    if (!kDebugMode) return;

    debugPrint('=== TASK CREATION DEBUG ===');
    debugPrint('Task: "${task.title}"');
    debugPrint('assignedTeamId: ${task.assignedTeamId}');
    debugPrint('isTeamTask: ${task.isTeamTask}');
    debugPrint('assignedMemberIds: ${task.assignedMemberIds}');
    debugPrint('category: ${task.category}');
    debugPrint('=== END TASK CREATION DEBUG ===\n');
  }

  static void debugTaskUpdate(Task oldTask, Task newTask) {
    if (!kDebugMode) return;

    debugPrint('=== TASK UPDATE DEBUG ===');
    debugPrint('Task: "${newTask.title}"');
    debugPrint(
      'Old assignedTeamId: ${oldTask.assignedTeamId} -> New: ${newTask.assignedTeamId}',
    );
    debugPrint(
      'Old isTeamTask: ${oldTask.isTeamTask} -> New: ${newTask.isTeamTask}',
    );
    debugPrint('=== END TASK UPDATE DEBUG ===\n');
  }

  static void debugAllTasks(List<Task> tasks) {
    if (!kDebugMode) return;

    debugPrint('=== ALL TASKS DEBUG ===');
    debugPrint('Total tasks: ${tasks.length}');

    final personalTasks = tasks.where((task) => !task.isTeamTask).toList();
    final teamTasks = tasks.where((task) => task.isTeamTask).toList();

    debugPrint('Personal tasks: ${personalTasks.length}');
    debugPrint('Team tasks: ${teamTasks.length}');

    if (tasks.isNotEmpty) {
      debugPrint('First few tasks:');
      for (var task in tasks.take(3)) {
        debugPrint(
          '  - "${task.title}" (${task.isTeamTask ? "Team" : "Personal"})',
        );
      }
    }
    debugPrint('=== END ALL TASKS DEBUG ===\n');
  }
}
