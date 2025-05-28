import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import 'firebase_user_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseUserService _userService = FirebaseUserService();

  // Current user
  User? get currentFirebaseUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Convert Firebase User to AppUser
  AppUser? _userFromFirebase(User? user) {
    if (user == null) return null;

    // Get username/display name with improved fallback logic
    String username = user.displayName ?? 'user${user.uid.substring(0, 6)}';

    return AppUser(
      id: user.uid,
      email: user.email ?? '',
      displayName: username,
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  // Get current app user
  AppUser? get currentUser => _userFromFirebase(_auth.currentUser);

  // Sign in with email and password
  Future<AppUser?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // First, check if user profile already exists in Firestore
      AppUser? existingUser;
      if (result.user != null) {
        try {
          existingUser = await _userService.getUserProfile(result.user!.uid);
        } catch (e) {
          // Failed to get existing profile, will create new one
        }
      }

      AppUser? user;
      if (existingUser != null) {
        // Use existing profile from Firestore (preserves original username)
        user = existingUser;
      } else {
        // Create new profile for first-time login
        user = _userFromFirebase(result.user);
        if (user != null) {
          await _userService.createOrUpdateUser(user);
        }
      }

      notifyListeners(); // Notify listeners of auth state change
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      // Log the error but don't throw if the user was actually created
      if (_auth.currentUser != null) {
        // Try to get existing profile first
        AppUser? existingUser;
        try {
          existingUser = await _userService.getUserProfile(
            _auth.currentUser!.uid,
          );
        } catch (_) {}

        final user = existingUser ?? _userFromFirebase(_auth.currentUser);

        // Try to create/update profile only if no existing profile
        if (user != null && existingUser == null) {
          try {
            await _userService.createOrUpdateUser(user);
          } catch (_) {
            // Profile update failed, but continue
          }
        }
        notifyListeners();
        return user;
      }
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Register with email and password
  Future<AppUser?> registerWithEmailAndPassword(
    String email,
    String password,
    String username,
  ) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name in Firebase Auth with the username
      await result.user?.updateDisplayName(username);
      await result.user?.reload();

      // Create user profile in Firestore with the username as displayName
      // Don't rely on _userFromFirebase here since it might fall back to email prefix
      final user = AppUser(
        id: result.user!.uid,
        email: result.user!.email ?? '',
        displayName: username, // Use the provided username directly
        photoUrl: result.user?.photoURL,
        createdAt: result.user!.metadata.creationTime ?? DateTime.now(),
      );

      // Create user profile in Firestore immediately
      await _userService.createOrUpdateUser(user);

      // Small delay to ensure Firestore document is available
      await Future.delayed(const Duration(milliseconds: 100));

      notifyListeners(); // Notify listeners of auth state change
      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      // Log the error but don't throw if the user was actually created
      if (_auth.currentUser != null) {
        final user = _userFromFirebase(_auth.currentUser);
        // Try to create profile even if there was an error
        if (user != null) {
          try {
            final userWithUsername = user.copyWith(displayName: username);
            await _userService.createOrUpdateUser(userWithUsername);
            // Small delay for Firestore
            await Future.delayed(const Duration(milliseconds: 100));
            return userWithUsername;
          } catch (_) {
            // Profile creation failed, but continue
          }
        }
        notifyListeners();
        return user?.copyWith(displayName: username);
      }
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign in with Google
  Future<AppUser?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      final UserCredential result = await _auth.signInWithCredential(
        credential,
      );

      // First, check if user profile already exists in Firestore
      AppUser? existingUser;
      if (result.user != null) {
        try {
          existingUser = await _userService.getUserProfile(result.user!.uid);
        } catch (e) {
          // Failed to get existing profile, will create new one
        }
      }

      AppUser? user;
      if (existingUser != null) {
        // Use existing profile from Firestore (preserves original username)
        user = existingUser;
      } else {
        // Create new profile for first-time Google sign-in
        user = _userFromFirebase(result.user);
        if (user != null) {
          // For Google sign-in, use the Google display name or email prefix as fallback
          final properDisplayName =
              result.user?.displayName ?? user.email.split('@').first;
          final userWithCorrectName = user.copyWith(
            displayName: properDisplayName,
          );
          await _userService.createOrUpdateUser(userWithCorrectName);
          user = userWithCorrectName;
        }
      }

      notifyListeners(); // Notify listeners of auth state change
      return user;
    } catch (e) {
      // Log the error but don't throw if the user was actually signed in
      if (_auth.currentUser != null) {
        // Try to get existing profile first
        AppUser? existingUser;
        try {
          existingUser = await _userService.getUserProfile(
            _auth.currentUser!.uid,
          );
        } catch (_) {}

        notifyListeners();
        return existingUser ?? _userFromFirebase(_auth.currentUser);
      }
      throw 'Google sign-in failed. Please try again.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
      notifyListeners(); // Notify listeners of auth state change
    } catch (e) {
      // Even if there's an error, check if sign out was successful
      if (_auth.currentUser == null) {
        notifyListeners();
        return; // Sign out was successful despite the error
      }
      throw 'Sign out failed. Please try again.';
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to send password reset email. Please try again.';
    }
  }

  // Update user profile
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'No user signed in';

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }

      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      await user.reload();
      notifyListeners();
    } catch (e) {
      throw 'Failed to update profile. Please try again.';
    }
  }

  // Change user password
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'No user signed in';

      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to change password. Please try again.';
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'No user signed in';

      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to delete account. Please try again.';
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'invalid-credential':
        return 'The provided credentials are invalid.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different sign-in credentials.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please sign in again.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }

  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  // Get user ID token for API calls
  Future<String?> getIdToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      return await user.getIdToken();
    } catch (e) {
      return null;
    }
  }
}
