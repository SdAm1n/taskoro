import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/task_provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  // Password controllers
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the controllers with the current user data
    final user = Provider.of<TaskProvider>(context, listen: false).currentUser;
    _usernameController = TextEditingController(text: user.displayName);
    _emailController = TextEditingController(text: user.email);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final currentUser = taskProvider.currentUser;

      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const Center(child: CircularProgressIndicator()),
        );

        // Create updated user with new username (keep original email)
        final updatedUser = currentUser.copyWith(
          displayName: _usernameController.text.trim(),
          // Don't update email - keep original
        );

        // Update user using TaskProvider (which handles Firebase Auth and Firestore)
        await taskProvider.updateUser(updatedUser);

        // Close loading dialog
        if (mounted) Navigator.of(context).pop();

        // Go back to settings screen
        if (mounted) Navigator.pop(context);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        debugPrint('Edit Profile Error: $e'); // Debug log

        // Close loading dialog
        if (mounted) Navigator.of(context).pop();

        // Show detailed error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update profile: ${e.toString()}'),
              duration: const Duration(seconds: 4),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showChangePasswordDialog() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final passwordFormKey = GlobalKey<FormState>();

    // Reset password controllers
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor:
              isDarkMode
                  ? AppTheme.darkSurfaceColor
                  : AppTheme.lightSurfaceColor,
          title: const Text('Change Password'),
          content: Form(
            key: passwordFormKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: _currentPasswordController,
                    hintText: 'Current Password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your current password';
                      }
                      // In a real app, you would verify the current password
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _newPasswordController,
                    hintText: 'New Password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a new password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm New Password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your new password';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (passwordFormKey.currentState!.validate()) {
                  // Capture context and messenger before async operations
                  final navigator = Navigator.of(dialogContext);
                  final messenger = ScaffoldMessenger.of(context);

                  try {
                    // Show loading indicator
                    showDialog(
                      context: dialogContext,
                      barrierDismissible: false,
                      builder:
                          (context) =>
                              const Center(child: CircularProgressIndicator()),
                    );

                    // Change password using AuthService
                    final authService = AuthService();
                    await authService.changePassword(
                      _currentPasswordController.text,
                      _newPasswordController.text,
                    );

                    // Close loading dialog
                    if (mounted) navigator.pop();

                    // Close password dialog
                    if (mounted) navigator.pop();

                    // Show success message
                    if (mounted) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Password changed successfully'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    // Close loading dialog
                    if (mounted) navigator.pop();

                    // Show error message
                    if (mounted) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Failed to change password: $e'),
                          duration: const Duration(seconds: 3),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: Text(
                'Change',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppTheme.darkBackgroundColor
              : AppTheme.lightBackgroundColor,
      appBar: CustomAppBar(title: 'Edit Profile'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Color.fromRGBO(
                        (AppTheme.primaryColor.r * 255).round(),
                        (AppTheme.primaryColor.g * 255).round(),
                        (AppTheme.primaryColor.b * 255).round(),
                        0.2,
                      ),
                      child: Text(
                        _usernameController.text.isNotEmpty
                            ? _usernameController.text[0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                isDarkMode
                                    ? AppTheme.darkBackgroundColor
                                    : AppTheme.lightBackgroundColor,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Username field
              Text('Username', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _usernameController,
                hintText: 'Your username',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  if (value.trim().length < 3) {
                    return 'Username must be at least 3 characters';
                  }
                  if (value.trim().length > 20) {
                    return 'Username must be less than 20 characters';
                  }
                  // Check for valid username pattern
                  if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(value.trim())) {
                    return 'Username can only contain letters, numbers, _ and -';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Email field (read-only)
              Text('Email', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _emailController,
                hintText: 'Your email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                enabled: false, // Make email field read-only
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 40),

              // Save button
              CustomButton(
                text: 'Save Changes',
                onPressed: _saveProfile,
                isFullWidth: true,
              ),

              const SizedBox(height: 24),

              // Change Password button
              CustomButton(
                text: 'Change Password',
                onPressed: _showChangePasswordDialog,
                isOutlined: true,
                isFullWidth: true,
                backgroundColor:
                    isDarkMode ? AppTheme.darkSurfaceColor : Colors.white,
                textColor: AppTheme.primaryColor,
                icon: Icons.lock_outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
