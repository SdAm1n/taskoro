import 'package:flutter_test/flutter_test.dart';
import 'package:taskoro/models/task.dart';

void main() {
  group('Task Model Tests', () {
    test('Task should handle single member assignment', () {
      final task = Task(
        id: '1',
        title: 'Test Task',
        description: 'Test Description',
        startDate: DateTime(2025, 5, 26),
        endDate: DateTime(2025, 5, 27),
        priority: TaskPriority.medium,
        category: TaskCategory.work,
        isCompleted: false,
        createdAt: DateTime(2025, 5, 26),
        assignedMemberIds: ['member1'],
      );

      expect(task.assignedMemberIds, isNotNull);
      expect(task.assignedMemberIds!.length, 1);
      expect(task.assignedMemberIds!.first, 'member1');
      expect(task.isAssignedToMembers, true);
      expect(task.isAssignedToMember('member1'), true);
      expect(task.isAssignedToMember('member2'), false);
    });

    test('Task should handle multiple member assignments', () {
      final task = Task(
        id: '2',
        title: 'Multi Member Task',
        description: 'Task with multiple members',
        startDate: DateTime(2025, 5, 26),
        endDate: DateTime(2025, 5, 27),
        priority: TaskPriority.high,
        category: TaskCategory.work,
        isCompleted: false,
        createdAt: DateTime(2025, 5, 26),
        assignedMemberIds: ['member1', 'member2', 'member3'],
      );

      expect(task.assignedMemberIds!.length, 3);
      expect(task.isAssignedToMembers, true);
      expect(task.isAssignedToMember('member1'), true);
      expect(task.isAssignedToMember('member2'), true);
      expect(task.isAssignedToMember('member3'), true);
      expect(task.isAssignedToMember('member4'), false);
    });

    test('Task should handle no member assignments', () {
      final task = Task(
        id: '3',
        title: 'Unassigned Task',
        description: 'Task with no assigned members',
        startDate: DateTime(2025, 5, 26),
        endDate: DateTime(2025, 5, 27),
        priority: TaskPriority.low,
        category: TaskCategory.personal,
        isCompleted: false,
        createdAt: DateTime(2025, 5, 26),
        assignedMemberIds: null,
      );

      expect(task.assignedMemberIds, isNull);
      expect(task.isAssignedToMembers, false);
      expect(task.isAssignedToMember('member1'), false);
    });

    test('Task should handle empty member list', () {
      final task = Task(
        id: '4',
        title: 'Empty Members Task',
        description: 'Task with empty member list',
        startDate: DateTime(2025, 5, 26),
        endDate: DateTime(2025, 5, 27),
        priority: TaskPriority.medium,
        category: TaskCategory.work,
        isCompleted: false,
        createdAt: DateTime(2025, 5, 26),
        assignedMemberIds: [],
      );

      expect(task.assignedMemberIds, isNotNull);
      expect(task.assignedMemberIds!.isEmpty, true);
      expect(task.isAssignedToMembers, false);
      expect(task.isAssignedToMember('member1'), false);
    });

    test('Task copyWith should update member assignments', () {
      final originalTask = Task(
        id: '5',
        title: 'Original Task',
        description: 'Original description',
        startDate: DateTime(2025, 5, 26),
        endDate: DateTime(2025, 5, 27),
        priority: TaskPriority.medium,
        category: TaskCategory.work,
        isCompleted: false,
        createdAt: DateTime(2025, 5, 26),
        assignedMemberIds: ['member1'],
      );

      final updatedTask = originalTask.copyWith(
        assignedMemberIds: ['member1', 'member2'],
      );

      expect(updatedTask.assignedMemberIds!.length, 2);
      expect(updatedTask.isAssignedToMember('member1'), true);
      expect(updatedTask.isAssignedToMember('member2'), true);
      expect(originalTask.assignedMemberIds!.length, 1);
    });

    test('Task serialization should work with multiple members', () {
      final task = Task(
        id: '6',
        title: 'Serialization Test',
        description: 'Testing serialization',
        startDate: DateTime(2025, 5, 26),
        endDate: DateTime(2025, 5, 27),
        priority: TaskPriority.high,
        category: TaskCategory.work,
        isCompleted: false,
        createdAt: DateTime(2025, 5, 26),
        assignedMemberIds: ['member1', 'member2'],
      );

      final map = task.toMap();
      expect(map['assignedMemberIds'], isA<List>());
      expect(map['assignedMemberIds'].length, 2);

      final reconstructedTask = Task.fromMap(map);
      expect(reconstructedTask.assignedMemberIds!.length, 2);
      expect(reconstructedTask.isAssignedToMember('member1'), true);
      expect(reconstructedTask.isAssignedToMember('member2'), true);
    });
  });
}
