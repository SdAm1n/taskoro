import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/task_provider.dart';
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
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    // Initialize the controllers with the current user data
    final user = Provider.of<TaskProvider>(context, listen: false).currentUser;
    _nameController = TextEditingController(text: user.displayName);
    _emailController = TextEditingController(text: user.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final currentUser = taskProvider.currentUser;

      // Create updated user with new display name and email
      final updatedUser = currentUser.copyWith(
        displayName: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );

      // Update the user in the provider
      taskProvider.updateUser(updatedUser);

      // Go back to settings screen
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
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
                        AppTheme.primaryColor.red,
                        AppTheme.primaryColor.green,
                        AppTheme.primaryColor.blue,
                        0.2,
                      ),
                      child: Text(
                        _nameController.text.isNotEmpty
                            ? _nameController.text[0].toUpperCase()
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

              // Name field
              Text('Name', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _nameController,
                hintText: 'Your name',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Email field
              Text('Email', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _emailController,
                hintText: 'Your email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
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
            ],
          ),
        ),
      ),
    );
  }
}
