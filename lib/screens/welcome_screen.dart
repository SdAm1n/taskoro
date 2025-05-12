import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Navigate to home screen for now (no authentication implemented yet)
      Navigator.pushReplacementNamed(context, '/home');
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20), // Reduced from 40
                // App logo and name
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40, // Reduced from 50
                      height: 40, // Reduced from 50
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 24, // Reduced from 30
                      ),
                    ),
                    const SizedBox(width: 14), // Reduced from 12
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'TASKORO',
                          style: Theme.of(
                            context,
                          ).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            fontSize: 24, // Reduced font size
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 60), // Reduced from 60
                // Welcome text
                Text(
                  _isLogin ? 'Welcome Back!' : 'Create Account',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    // Changed from displayMedium to displaySmall
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  _isLogin
                      ? 'Sign in to continue managing your tasks'
                      : 'Sign up to start managing your tasks',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 20), // Reduced from 40
                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!_isLogin) ...[
                        Text(
                          'Name',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: _nameController,
                          hintText: 'Your name',
                          prefixIcon: Icons.person_outline,
                          validator: (value) {
                            if (!_isLogin && (value == null || value.isEmpty)) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12), // Reduced from 20
                      ],

                      Text(
                        'Email',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
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

                      const SizedBox(height: 12), // Reduced from 20

                      Text(
                        'Password',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _passwordController,
                        hintText: 'Your password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (!_isLogin && value.length < 6) {
                            return 'Password should be at least 6 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 8), // Reduced from 16

                      if (_isLogin)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Handle forgot password
                            },
                            child: const Text('Forgot Password?'),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16), // Reduced from 24
                // Submit button
                CustomButton(
                  text: _isLogin ? 'Sign In' : 'Sign Up',
                  onPressed: _submitForm,
                ),

                const SizedBox(height: 16),

                // Switch between login and signup
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLogin
                          ? 'Don\'t have an account?'
                          : 'Already have an account?',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                          _formKey.currentState?.reset();
                        });
                      },
                      child: Text(_isLogin ? 'Sign Up' : 'Sign In'),
                    ),
                  ],
                ),

                const SizedBox(height: 16), // Reduced from 32
                // Social login options
                Column(
                  children: [
                    Center(
                      child: Text(
                        'Or continue with',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 8), // Reduced from 16
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(Icons.g_mobiledata, 'Google'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        // Handle Google login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Google Sign In will be implemented in a future update',
            ),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ), // Reduced vertical padding
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.red, size: 20), // Reduced from size 24
            const SizedBox(width: 8),
            Text(
              'Continue with Google',
              style: TextStyle(
                fontSize: 12, // Reduced from 14
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
