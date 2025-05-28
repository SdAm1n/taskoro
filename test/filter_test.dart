import 'package:flutter_test/flutter_test.dart';
import 'package:taskoro/models/task.dart';

void main() {
  group('Task Filter Tests', () {
    late List<Task> testTasks;

    setUp(() {
      final now = DateTime.now();
      testTasks = [
        // Personal task (no team assignment)
        Task(
          id: 'personal_1',
          title: 'Personal Task 1',
          description: 'This is a personal task',
          startDate: now,
          endDate: now.add(Duration(days: 1)),
          priority: TaskPriority.medium,
          category: TaskCategory.personal,
          isCompleted: false,
          createdAt: now,
          assignedTeamId: null, // Personal task
        ),

        // Team task (has team assignment)
        Task(
          id: 'team_1',
          title: 'Team Task 1',
          description: 'This is a team task',
          startDate: now,
          endDate: now.add(Duration(days: 1)),
          priority: TaskPriority.high,
          category: TaskCategory.work,
          isCompleted: false,
          createdAt: now,
          assignedTeamId: 'team_123', // Team task
        ),

        // Another personal task
        Task(
          id: 'personal_2',
          title: 'Personal Task 2',
          description: 'Another personal task',
          startDate: now,
          endDate: now.add(Duration(days: 2)),
          priority: TaskPriority.low,
          category: TaskCategory.health,
          isCompleted: true,
          createdAt: now,
          assignedTeamId: null, // Personal task
        ),

        // Another team task
        Task(
          id: 'team_2',
          title: 'Team Task 2',
          description: 'Another team task',
          startDate: now,
          endDate: now.add(Duration(days: 3)),
          priority: TaskPriority.medium,
          category: TaskCategory.work,
          isCompleted: false,
          createdAt: now,
          assignedTeamId: 'team_456', // Team task
          assignedMemberIds: ['member_1', 'member_2'],
        ),
      ];
    });

    test('Team filter should return only team tasks', () {
      final teamTasks = testTasks.where((task) => task.isTeamTask).toList();

      expect(teamTasks.length, equals(2));
      expect(teamTasks[0].title, equals('Team Task 1'));
      expect(teamTasks[1].title, equals('Team Task 2'));

      // Verify all returned tasks are team tasks
      for (final task in teamTasks) {
        expect(task.isTeamTask, isTrue);
        expect(task.assignedTeamId, isNotNull);
      }
    });

    test('All filter should return all tasks', () {
      final allTasks = testTasks;

      expect(allTasks.length, equals(4));
    });

    test('Completed filter should return only completed tasks', () {
      final completedTasks =
          testTasks.where((task) => task.isCompleted).toList();

      expect(completedTasks.length, equals(1));
      expect(completedTasks[0].title, equals('Personal Task 2'));
      expect(completedTasks[0].isCompleted, isTrue);
    });

    test('Task.isTeamTask property works correctly', () {
      expect(testTasks[0].isTeamTask, isFalse); // Personal task 1
      expect(testTasks[1].isTeamTask, isTrue); // Team task 1
      expect(testTasks[2].isTeamTask, isFalse); // Personal task 2
      expect(testTasks[3].isTeamTask, isTrue); // Team task 2
    });

    test('Today filter logic', () {
      final today = DateTime.now();
      final todayTasks =
          testTasks.where((task) {
            return (today.isAtSameMomentAs(task.startDate) ||
                    today.isAfter(task.startDate)) &&
                (today.isAtSameMomentAs(task.endDate) ||
                    today.isBefore(task.endDate));
          }).toList();

      // Should include tasks that span today
      expect(todayTasks.length, greaterThan(0));
    });

    test('Upcoming filter logic', () {
      final now = DateTime.now();
      final upcomingTasks =
          testTasks.where((task) {
            return task.endDate.isAfter(now) &&
                task.endDate.difference(now).inDays <= 7;
          }).toList();

      // Should include tasks ending within 7 days
      expect(upcomingTasks.length, greaterThan(0));
    });
  });
}
