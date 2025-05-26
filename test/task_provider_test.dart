import 'package:flutter_test/flutter_test.dart';
import 'package:taskoro/models/task.dart';
import 'package:taskoro/models/user.dart';
import 'package:taskoro/services/task_provider.dart';

void main() {
  group('TaskProvider Multiple Members Tests', () {
    late TaskProvider taskProvider;

    setUp(() {
      taskProvider = TaskProvider();
      // Clear any existing tasks to start with a clean slate
      taskProvider.tasks.clear();
      // Update the current user for test
      taskProvider.updateUser(
        AppUser(
          id: 'test-user-1',
          displayName: 'Test User',
          email: 'test@example.com',
          createdAt: DateTime.now(),
        ),
      );
    });

    test('assignTaskToMembers should assign task to multiple members', () {
      // Create a test task
      final task = Task(
        id: 'test_task',
        title: 'Test Task',
        description: 'Test Description',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 1)),
        priority: TaskPriority.medium,
        category: TaskCategory.work,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      taskProvider.addTask(task);

      // Assign task to multiple members
      final memberIds = ['member1', 'member2', 'member3'];
      taskProvider.assignTaskToMembers('test_task', 'team1', memberIds);

      final updatedTask = taskProvider.tasks.firstWhere(
        (t) => t.id == 'test_task',
      );
      expect(updatedTask.assignedMemberIds, equals(memberIds));
      expect(updatedTask.isAssignedToMember('member1'), true);
      expect(updatedTask.isAssignedToMember('member2'), true);
      expect(updatedTask.isAssignedToMember('member3'), true);
    });

    test('addMemberToTask should add member to existing assignment', () {
      final task = Task(
        id: 'test_task',
        title: 'Test Task',
        description: 'Test Description',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 1)),
        priority: TaskPriority.medium,
        category: TaskCategory.work,
        isCompleted: false,
        createdAt: DateTime.now(),
        assignedMemberIds: ['member1'],
      );

      taskProvider.addTask(task);

      // Add another member
      taskProvider.addMemberToTask('test_task', 'member2');

      final updatedTask = taskProvider.tasks.firstWhere(
        (t) => t.id == 'test_task',
      );
      expect(updatedTask.assignedMemberIds!.length, 2);
      expect(updatedTask.isAssignedToMember('member1'), true);
      expect(updatedTask.isAssignedToMember('member2'), true);
    });

    test('removeMemberFromTask should remove specific member', () {
      final task = Task(
        id: 'test_task',
        title: 'Test Task',
        description: 'Test Description',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 1)),
        priority: TaskPriority.medium,
        category: TaskCategory.work,
        isCompleted: false,
        createdAt: DateTime.now(),
        assignedMemberIds: ['member1', 'member2', 'member3'],
      );

      taskProvider.addTask(task);

      // Remove one member
      taskProvider.removeMemberFromTask('test_task', 'member2');

      final updatedTask = taskProvider.tasks.firstWhere(
        (t) => t.id == 'test_task',
      );
      expect(updatedTask.assignedMemberIds!.length, 2);
      expect(updatedTask.isAssignedToMember('member1'), true);
      expect(updatedTask.isAssignedToMember('member2'), false);
      expect(updatedTask.isAssignedToMember('member3'), true);
    });

    test(
      'getTasksForMember should return tasks assigned to specific member',
      () {
        final task1 = Task(
          id: 'task1',
          title: 'Task 1',
          description: 'Description 1',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 1)),
          priority: TaskPriority.medium,
          category: TaskCategory.work,
          isCompleted: false,
          createdAt: DateTime.now(),
          assignedMemberIds: ['member1', 'member2'],
        );

        final task2 = Task(
          id: 'task2',
          title: 'Task 2',
          description: 'Description 2',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 1)),
          priority: TaskPriority.high,
          category: TaskCategory.work,
          isCompleted: false,
          createdAt: DateTime.now(),
          assignedMemberIds: ['member2', 'member3'],
        );

        final task3 = Task(
          id: 'task3',
          title: 'Task 3',
          description: 'Description 3',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 1)),
          priority: TaskPriority.low,
          category: TaskCategory.personal,
          isCompleted: false,
          createdAt: DateTime.now(),
          assignedMemberIds: ['member1'],
        );

        taskProvider.addTask(task1);
        taskProvider.addTask(task2);
        taskProvider.addTask(task3);

        final member1Tasks = taskProvider.getTasksForMember('member1');
        final member2Tasks = taskProvider.getTasksForMember('member2');
        final member3Tasks = taskProvider.getTasksForMember('member3');

        expect(member1Tasks.length, 2); // task1 and task3
        expect(member2Tasks.length, 2); // task1 and task2
        expect(member3Tasks.length, 1); // task2 only

        expect(member1Tasks.any((t) => t.id == 'task1'), true);
        expect(member1Tasks.any((t) => t.id == 'task3'), true);
        expect(member2Tasks.any((t) => t.id == 'task1'), true);
        expect(member2Tasks.any((t) => t.id == 'task2'), true);
        expect(member3Tasks.any((t) => t.id == 'task2'), true);
      },
    );

    test('assignTaskToMember should work for backward compatibility', () {
      final task = Task(
        id: 'test_task',
        title: 'Test Task',
        description: 'Test Description',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 1)),
        priority: TaskPriority.medium,
        category: TaskCategory.work,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      taskProvider.addTask(task);

      // Use the old single member assignment method
      taskProvider.assignTaskToMember('test_task', 'team1', 'member1');

      final updatedTask = taskProvider.tasks.firstWhere(
        (t) => t.id == 'test_task',
      );
      expect(updatedTask.assignedMemberIds!.length, 1);
      expect(updatedTask.isAssignedToMember('member1'), true);
    });
  });
}
