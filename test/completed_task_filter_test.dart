import 'package:flutter_test/flutter_test.dart';
import 'package:taskoro/models/task.dart';

void main() {
  group('Completed Task Filter Tests', () {
    late List<Task> testTasks;

    setUp(() {
      final now = DateTime.now();
      testTasks = [
        // Active task
        Task(
          id: 'active_1',
          title: 'Active Task',
          description: 'This is an active task',
          startDate: now,
          endDate: now.add(Duration(days: 1)),
          priority: TaskPriority.medium,
          category: TaskCategory.personal,
          isCompleted: false,
          createdAt: now,
          assignedTeamId: null,
        ),

        // Completed task
        Task(
          id: 'completed_1',
          title: 'Completed Task',
          description: 'This is a completed task',
          startDate: now.subtract(Duration(days: 1)),
          endDate: now,
          priority: TaskPriority.medium,
          category: TaskCategory.personal,
          isCompleted: true,
          createdAt: now,
          assignedTeamId: null,
        ),

        // Active team task
        Task(
          id: 'team_active',
          title: 'Active Team Task',
          description: 'This is an active team task',
          startDate: now,
          endDate: now.add(Duration(days: 2)),
          priority: TaskPriority.high,
          category: TaskCategory.work,
          isCompleted: false,
          createdAt: now,
          assignedTeamId: 'team_123',
        ),

        // Completed team task
        Task(
          id: 'team_completed',
          title: 'Completed Team Task',
          description: 'This is a completed team task',
          startDate: now.subtract(Duration(days: 2)),
          endDate: now.subtract(Duration(days: 1)),
          priority: TaskPriority.high,
          category: TaskCategory.work,
          isCompleted: true,
          createdAt: now,
          assignedTeamId: 'team_456',
        ),
      ];
    });

    test('Pending tasks should exclude completed tasks', () {
      final pendingTasks =
          testTasks.where((task) => !task.isCompleted).toList();

      expect(pendingTasks.length, equals(2)); // Should only have active tasks
      expect(pendingTasks.every((task) => !task.isCompleted), isTrue);

      // Verify specific tasks are included
      expect(pendingTasks.any((task) => task.id == 'active_1'), isTrue);
      expect(pendingTasks.any((task) => task.id == 'team_active'), isTrue);

      // Verify completed tasks are excluded
      expect(pendingTasks.any((task) => task.id == 'completed_1'), isFalse);
      expect(pendingTasks.any((task) => task.id == 'team_completed'), isFalse);
    });

    test('Team filter should exclude completed team tasks', () {
      final teamTasks = testTasks.where((task) => task.isTeamTask).toList();
      final activeTeamTasks =
          teamTasks.where((task) => !task.isCompleted).toList();

      expect(teamTasks.length, equals(2)); // Total team tasks
      expect(activeTeamTasks.length, equals(1)); // Only active team task
      expect(activeTeamTasks.every((task) => !task.isCompleted), isTrue);
      expect(activeTeamTasks.every((task) => task.isTeamTask), isTrue);
      expect(activeTeamTasks[0].id, equals('team_active'));
    });

    test('Completed filter should only show completed tasks', () {
      final completedTasks =
          testTasks.where((task) => task.isCompleted).toList();

      expect(completedTasks.length, equals(2)); // All completed tasks
      expect(completedTasks.every((task) => task.isCompleted), isTrue);

      // Verify all completed tasks are included
      expect(completedTasks.any((task) => task.id == 'completed_1'), isTrue);
      expect(completedTasks.any((task) => task.id == 'team_completed'), isTrue);

      // Verify active tasks are excluded
      expect(completedTasks.any((task) => task.id == 'active_1'), isFalse);
      expect(completedTasks.any((task) => task.id == 'team_active'), isFalse);
    });

    test('Search with completed filter should exclude completed tasks', () {
      final searchQuery = 'task';
      final searchResults =
          testTasks.where((task) {
            final matchesSearch =
                task.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                task.description.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                );
            return matchesSearch && !task.isCompleted;
          }).toList();

      expect(searchResults.length, equals(2)); // Only active tasks that match
      expect(searchResults.every((task) => !task.isCompleted), isTrue);
      expect(
        searchResults.every(
          (task) =>
              task.title.toLowerCase().contains(searchQuery) ||
              task.description.toLowerCase().contains(searchQuery),
        ),
        isTrue,
      );

      // Should include active tasks
      expect(searchResults.any((task) => task.id == 'active_1'), isTrue);
      expect(searchResults.any((task) => task.id == 'team_active'), isTrue);

      // Should exclude completed tasks even if they match search
      expect(searchResults.any((task) => task.id == 'completed_1'), isFalse);
      expect(searchResults.any((task) => task.id == 'team_completed'), isFalse);
    });
  });
}
