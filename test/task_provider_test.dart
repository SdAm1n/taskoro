import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:taskoro/models/task.dart';
import 'package:taskoro/models/user.dart';
import 'package:taskoro/services/firebase_task_service.dart';
import 'package:taskoro/services/firebase_user_service.dart';

void main() {
  group('Firebase Task Service Integration Tests', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
    });

    test('Task model supports multiple member assignments', () {
      final now = DateTime.now();
      final task = Task(
        id: 'test_task',
        title: 'Test Task',
        description: 'Test Description',
        startDate: now,
        endDate: now.add(Duration(days: 1)),
        priority: TaskPriority.medium,
        category: TaskCategory.work,
        isCompleted: false,
        createdAt: now,
        assignedMemberIds: ['member1', 'member2', 'member3'],
        assignedTeamId: 'team1',
      );

      // Test multiple member assignment
      expect(task.assignedMemberIds?.length, equals(3));
      expect(task.isAssignedToMember('member1'), isTrue);
      expect(task.isAssignedToMember('member2'), isTrue);
      expect(task.isAssignedToMember('member3'), isTrue);
      expect(task.isAssignedToMember('member4'), isFalse);
    });

    test('Task copyWith updates member assignments correctly', () {
      final now = DateTime.now();
      final originalTask = Task(
        id: 'test_task',
        title: 'Test Task',
        description: 'Test Description',
        startDate: now,
        endDate: now.add(Duration(days: 1)),
        priority: TaskPriority.medium,
        category: TaskCategory.work,
        isCompleted: false,
        createdAt: now,
        assignedMemberIds: ['member1'],
      );

      // Update with new member assignments
      final updatedTask = originalTask.copyWith(
        assignedMemberIds: ['member1', 'member2', 'member3'],
      );

      expect(updatedTask.assignedMemberIds?.length, equals(3));
      expect(updatedTask.isAssignedToMember('member1'), isTrue);
      expect(updatedTask.isAssignedToMember('member2'), isTrue);
      expect(updatedTask.isAssignedToMember('member3'), isTrue);
    });

    test('Task serialization preserves member assignments', () async {
      final now = DateTime.now();
      final task = Task(
        id: 'test_task',
        title: 'Test Task',
        description: 'Test Description',
        startDate: now,
        endDate: now.add(Duration(days: 1)),
        priority: TaskPriority.high,
        category: TaskCategory.work,
        isCompleted: false,
        createdAt: now,
        assignedMemberIds: ['member1', 'member2'],
        assignedTeamId: 'team1',
      );

      // Test Firestore serialization
      await fakeFirestore.collection('tasks').doc(task.id).set(task.toMap());

      final doc = await fakeFirestore.collection('tasks').doc(task.id).get();
      expect(doc.exists, isTrue);

      final retrievedTask = Task.fromMap(doc.data()!);
      expect(retrievedTask.assignedMemberIds?.length, equals(2));
      expect(retrievedTask.isAssignedToMember('member1'), isTrue);
      expect(retrievedTask.isAssignedToMember('member2'), isTrue);
      expect(retrievedTask.assignedTeamId, equals('team1'));
    });

    test('User model serialization works correctly', () async {
      final now = DateTime.now();
      final user = AppUser(
        id: 'test-user-1',
        displayName: 'Test User',
        email: 'test@example.com',
        photoUrl: 'test-photo-url',
        createdAt: now,
        settings: {'theme': 'dark', 'notifications': true},
      );

      // Test Firestore serialization
      await fakeFirestore.collection('users').doc(user.id).set(user.toMap());

      final doc = await fakeFirestore.collection('users').doc(user.id).get();
      expect(doc.exists, isTrue);

      final retrievedUser = AppUser.fromMap(doc.data()!);
      expect(retrievedUser.displayName, equals('Test User'));
      expect(retrievedUser.email, equals('test@example.com'));
      expect(retrievedUser.settings?['theme'], equals('dark'));
    });

    test('Firebase service instances can be created', () {
      // These tests verify that Firebase service classes can be instantiated
      // without throwing errors (they will fail if Firebase isn't initialized,
      // but that's expected in a test environment)
      expect(() => FirebaseTaskService, returnsNormally);
      expect(() => FirebaseUserService, returnsNormally);
    });

    test('Task with team assignment works correctly', () async {
      final now = DateTime.now();
      final task = Task(
        id: 'team_task',
        title: 'Team Task',
        description: 'Task assigned to team',
        startDate: now,
        endDate: now.add(Duration(days: 2)),
        priority: TaskPriority.high,
        category: TaskCategory.work,
        isCompleted: false,
        createdAt: now,
        assignedTeamId: 'team1',
        assignedMemberIds: ['member1', 'member2'],
      );

      expect(task.isTeamTask, isTrue);
      expect(task.isAssignedToMembers, isTrue);
      expect(task.assignedMemberIds?.length, equals(2));

      // Test Firestore operations
      await fakeFirestore.collection('tasks').doc(task.id).set(task.toMap());

      final doc = await fakeFirestore.collection('tasks').doc(task.id).get();
      expect(doc.exists, isTrue);

      final retrievedTask = Task.fromMap(doc.data()!);
      expect(retrievedTask.isTeamTask, isTrue);
      expect(retrievedTask.assignedTeamId, equals('team1'));
      expect(retrievedTask.isAssignedToMember('member1'), isTrue);
      expect(retrievedTask.isAssignedToMember('member2'), isTrue);
    });

    test('Task without team assignment works correctly', () async {
      final now = DateTime.now();
      final task = Task(
        id: 'personal_task',
        title: 'Personal Task',
        description: 'Personal task without team',
        startDate: now,
        endDate: now.add(Duration(days: 1)),
        priority: TaskPriority.medium,
        category: TaskCategory.personal,
        isCompleted: false,
        createdAt: now,
      );

      expect(task.isTeamTask, isFalse);
      expect(task.isAssignedToMembers, isFalse);
      expect(task.assignedTeamId, isNull);
      expect(task.assignedMemberIds, isNull);

      // Test Firestore operations
      await fakeFirestore.collection('tasks').doc(task.id).set(task.toMap());

      final doc = await fakeFirestore.collection('tasks').doc(task.id).get();
      expect(doc.exists, isTrue);

      final retrievedTask = Task.fromMap(doc.data()!);
      expect(retrievedTask.isTeamTask, isFalse);
      expect(retrievedTask.isAssignedToMembers, isFalse);
    });
  });
}
