import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:taskoro/models/task.dart';
import 'package:taskoro/models/user.dart';

void main() {
  group('Firebase Integration Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;

    setUpAll(() async {
      // Initialize fake Firebase for testing
      fakeFirestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
    });

    setUp(() {
      // Reset the fake firestore before each test
      fakeFirestore = FakeFirebaseFirestore();
    });

    test('should create fake Firebase services without errors', () {
      expect(fakeFirestore, isNotNull);
      expect(mockAuth, isNotNull);
    });

    test('Task model serialization works correctly', () {
      final now = DateTime.now();
      final task = Task(
        id: 'test-id',
        title: 'Test Task',
        description: 'Test Description',
        startDate: now,
        endDate: now.add(Duration(days: 1)),
        priority: TaskPriority.medium,
        category: TaskCategory.work,
        isCompleted: false,
        createdAt: now,
        assignedTeamId: 'team-id',
        assignedMemberIds: ['user-id'],
      );

      final taskMap = task.toMap();
      final recreatedTask = Task.fromMap(taskMap);

      expect(recreatedTask.id, equals(task.id));
      expect(recreatedTask.title, equals(task.title));
      expect(recreatedTask.description, equals(task.description));
      expect(recreatedTask.isCompleted, equals(task.isCompleted));
      expect(recreatedTask.priority, equals(task.priority));
      expect(recreatedTask.category, equals(task.category));
      expect(recreatedTask.assignedTeamId, equals(task.assignedTeamId));
    });

    test('User model serialization works correctly', () {
      final now = DateTime.now();
      final user = AppUser(
        id: 'test-user-id',
        displayName: 'Test User',
        email: 'test@example.com',
        photoUrl: 'avatar-url',
        createdAt: now,
      );

      final userMap = user.toMap();
      final recreatedUser = AppUser.fromMap(userMap);

      expect(recreatedUser.id, equals(user.id));
      expect(recreatedUser.displayName, equals(user.displayName));
      expect(recreatedUser.email, equals(user.email));
      expect(recreatedUser.photoUrl, equals(user.photoUrl));
    });

    test('can add and retrieve task from fake Firestore', () async {
      final now = DateTime.now();
      final task = Task(
        id: 'test-task-1',
        title: 'Test Firestore Task',
        description: 'Testing Firestore operations',
        startDate: now,
        endDate: now.add(Duration(days: 1)),
        priority: TaskPriority.high,
        category: TaskCategory.work,
        isCompleted: false,
        createdAt: now,
      );

      // Add task to fake firestore
      await fakeFirestore.collection('tasks').doc(task.id).set(task.toMap());

      // Retrieve task from fake firestore
      final doc = await fakeFirestore.collection('tasks').doc(task.id).get();
      expect(doc.exists, isTrue);

      final retrievedTask = Task.fromMap(doc.data()!);
      expect(retrievedTask.title, equals(task.title));
      expect(retrievedTask.priority, equals(task.priority));
    });

    test('can add and retrieve user from fake Firestore', () async {
      final now = DateTime.now();
      final user = AppUser(
        id: 'test-user-1',
        displayName: 'Test Firestore User',
        email: 'testuser@example.com',
        photoUrl: 'test-photo-url',
        createdAt: now,
      );

      // Add user to fake firestore
      await fakeFirestore.collection('users').doc(user.id).set(user.toMap());

      // Retrieve user from fake firestore
      final doc = await fakeFirestore.collection('users').doc(user.id).get();
      expect(doc.exists, isTrue);

      final retrievedUser = AppUser.fromMap(doc.data()!);
      expect(retrievedUser.displayName, equals(user.displayName));
      expect(retrievedUser.email, equals(user.email));
    });
  });
}
