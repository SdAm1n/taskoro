import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Debug logging in development
        if (kDebugMode) {
          print('AuthWrapper - Connection state: ${snapshot.connectionState}');
          print('AuthWrapper - Has data: ${snapshot.hasData}');
          print('AuthWrapper - User: ${snapshot.data?.uid}');
          print('AuthWrapper - User email: ${snapshot.data?.email}');
        }

        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading...'),
                ],
              ),
            ),
          );
        }

        // Handle errors
        if (snapshot.hasError) {
          if (kDebugMode) {
            print('AuthWrapper - Error: ${snapshot.error}');
          }
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Authentication Error'),
                  SizedBox(height: 8),
                  Text('Please restart the app'),
                ],
              ),
            ),
          );
        }

        // User is signed in
        if (snapshot.hasData && snapshot.data != null) {
          if (kDebugMode) {
            print('AuthWrapper - User authenticated, showing MainScreen');
          }
          return const MainScreen();
        }

        // User is not signed in
        if (kDebugMode) {
          print('AuthWrapper - No user, showing LoginScreen');
        }
        return const LoginScreen();
      },
    );
  }
}
