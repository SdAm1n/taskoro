import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';

class FirebaseUserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _currentUserId => _auth.currentUser?.uid;

  // Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');

  // Create or update user profile in Firestore
  Future<void> createOrUpdateUser(AppUser user) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      await _usersCollection
          .doc(user.id)
          .set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to create/update user: $e');
    }
  }

  // Get user profile from Firestore
  Future<AppUser?> getUserProfile(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return AppUser.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Get current user profile
  Future<AppUser?> getCurrentUserProfile() async {
    if (_currentUserId == null) return null;
    return getUserProfile(_currentUserId!);
  }

  // Stream of current user profile
  Stream<AppUser?> getCurrentUserProfileStream() {
    if (_currentUserId == null) return Stream.value(null);

    return _usersCollection.doc(_currentUserId).snapshots().map((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return AppUser.fromMap(data);
      }
      return null;
    });
  }

  // Update user profile
  Future<void> updateUserProfile(AppUser user) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      await _usersCollection.doc(user.id).update(user.toMap());
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Update specific user fields
  Future<void> updateUserFields(
    String userId,
    Map<String, dynamic> fields,
  ) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      await _usersCollection.doc(userId).update(fields);
    } catch (e) {
      throw Exception('Failed to update user fields: $e');
    }
  }

  // Update user username (displayName field)
  Future<void> updateUsername(String username) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      await _usersCollection.doc(_currentUserId).update({
        'displayName': username,
      });

      // Also update Firebase Auth profile
      await _auth.currentUser?.updateDisplayName(username);
    } catch (e) {
      throw Exception('Failed to update username: $e');
    }
  }

  // Update user photo URL
  Future<void> updatePhotoUrl(String photoUrl) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      await _usersCollection.doc(_currentUserId).update({'photoUrl': photoUrl});

      // Also update Firebase Auth profile
      await _auth.currentUser?.updatePhotoURL(photoUrl);
    } catch (e) {
      throw Exception('Failed to update photo URL: $e');
    }
  }

  // Update user settings
  Future<void> updateUserSettings(Map<String, dynamic> settings) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    try {
      await _usersCollection.doc(_currentUserId).update({'settings': settings});
    } catch (e) {
      throw Exception('Failed to update user settings: $e');
    }
  }

  // Search users by email (for team invitations)
  Future<List<AppUser>> searchUsersByEmail(String email) async {
    try {
      final snapshot =
          await _usersCollection
              .where('email', isEqualTo: email.toLowerCase())
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return AppUser.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search users by username: $e');
    }
  }

  // Search users by username (displayName field)
  Future<List<AppUser>> searchUsersByUsername(String query) async {
    try {
      // Firebase doesn't support case-insensitive text search natively
      // This is a simple implementation that gets all users and filters locally
      // For production, consider using Algolia or similar search service
      final snapshot = await _usersCollection.get();

      final lowercaseQuery = query.toLowerCase();
      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return AppUser.fromMap(data);
          })
          .where(
            (user) => user.displayName.toLowerCase().contains(lowercaseQuery),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to search users by display name: $e');
    }
  }

  // Get multiple users by IDs
  Future<List<AppUser>> getUsersByIds(List<String> userIds) async {
    if (userIds.isEmpty) return [];

    try {
      final users = <AppUser>[];

      // Firestore 'in' query limit is 10, so we need to batch
      for (int i = 0; i < userIds.length; i += 10) {
        final batch = userIds.skip(i).take(10).toList();
        final snapshot =
            await _usersCollection.where('id', whereIn: batch).get();

        final batchUsers =
            snapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return AppUser.fromMap(data);
            }).toList();

        users.addAll(batchUsers);
      }

      return users;
    } catch (e) {
      throw Exception('Failed to get users by IDs: $e');
    }
  }

  // Delete user profile (for account deletion)
  Future<void> deleteUserProfile(String userId) async {
    if (_currentUserId == null) throw Exception('User not authenticated');
    if (_currentUserId != userId) {
      throw Exception('Unauthorized to delete this profile');
    }

    try {
      await _usersCollection.doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user profile: $e');
    }
  }

  // Initialize user profile after registration
  Future<void> initializeUserProfile(User firebaseUser) async {
    try {
      final appUser = AppUser(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName:
            firebaseUser.displayName ??
            'user${firebaseUser.uid.substring(0, 6)}',
        photoUrl: firebaseUser.photoURL,
        createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
        settings: {'theme': 'system', 'language': 'en', 'notifications': true},
      );

      await createOrUpdateUser(appUser);
    } catch (e) {
      throw Exception('Failed to initialize user profile: $e');
    }
  }

  // Check if user exists
  Future<bool> userExists(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Get user by email
  Future<AppUser?> getUserByEmail(String email) async {
    try {
      final snapshot =
          await _usersCollection
              .where('email', isEqualTo: email.toLowerCase())
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        data['id'] = snapshot.docs.first.id;
        return AppUser.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user by email: $e');
    }
  }

  // Update last seen timestamp
  Future<void> updateLastSeen() async {
    if (_currentUserId == null) return;

    try {
      await _usersCollection.doc(_currentUserId).update({
        'lastSeen': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      // Silently fail for last seen updates
      // Debug: Failed to update last seen: $e
    }
  }

  // Batch create multiple users (for migration or testing)
  Future<void> batchCreateUsers(List<AppUser> users) async {
    if (users.isEmpty) return;

    try {
      final batch = _firestore.batch();

      for (final user in users) {
        final docRef = _usersCollection.doc(user.id);
        batch.set(docRef, user.toMap());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch create users: $e');
    }
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    try {
      // This would typically involve aggregating data from multiple collections
      // For now, return basic user information
      final user = await getUserProfile(userId);
      if (user == null) return {};

      return {
        'joinDate': user.createdAt.millisecondsSinceEpoch,
        'displayName': user.displayName,
        'email': user.email,
        // Add more statistics as needed
      };
    } catch (e) {
      throw Exception('Failed to get user statistics: $e');
    }
  }
}
