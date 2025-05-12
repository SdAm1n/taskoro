import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import '../services/task_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';
import 'edit_profile_screen.dart';
import 'app_version_screen.dart';
import 'rate_app_screen.dart';
import 'help_support_screen.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final user = taskProvider.currentUser;
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppTheme.darkBackgroundColor
              : AppTheme.lightBackgroundColor,
      appBar: CustomAppBar(title: 'Settings'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User profile section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:
                    isDarkMode
                        ? AppTheme.darkCardColor
                        : AppTheme.lightCardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                    child: Text(
                      user.displayName.isNotEmpty
                          ? user.displayName[0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:
                                isDarkMode
                                    ? AppTheme.darkPrimaryTextColor
                                    : AppTheme.lightPrimaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                isDarkMode
                                    ? AppTheme.darkSecondaryTextColor
                                    : AppTheme.lightSecondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    color: AppTheme.primaryColor,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // App settings section
            Text(
              'App Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color:
                    isDarkMode
                        ? AppTheme.darkPrimaryTextColor
                        : AppTheme.lightPrimaryTextColor,
              ),
            ),
            const SizedBox(height: 16),

            // Theme toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color:
                    isDarkMode
                        ? AppTheme.darkCardColor
                        : AppTheme.lightCardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Dark Mode',
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              isDarkMode
                                  ? AppTheme.darkPrimaryTextColor
                                  : AppTheme.lightPrimaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: isDarkMode,
                    onChanged: (_) {
                      themeProvider.toggleTheme();
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Notifications setting
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color:
                    isDarkMode
                        ? AppTheme.darkCardColor
                        : AppTheme.lightCardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.notifications_outlined,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              isDarkMode
                                  ? AppTheme.darkPrimaryTextColor
                                  : AppTheme.lightPrimaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value:
                        true, // This would be connected to actual notification settings
                    onChanged: (value) {
                      // Toggle notifications
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // About section
            Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color:
                    isDarkMode
                        ? AppTheme.darkPrimaryTextColor
                        : AppTheme.lightPrimaryTextColor,
              ),
            ),
            const SizedBox(height: 16),

            _buildSettingItem(
              context,
              icon: Icons.info_outline,
              title: 'App Version',
              subtitle: '1.0.0',
              isDarkMode: isDarkMode,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AppVersionScreen(),
                  ),
                );
              },
            ),

            _buildSettingItem(
              context,
              icon: Icons.star_outline,
              title: 'Rate App',
              isDarkMode: isDarkMode,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RateAppScreen(),
                  ),
                );
              },
            ),

            _buildSettingItem(
              context,
              icon: Icons.support_outlined,
              title: 'Help & Support',
              isDarkMode: isDarkMode,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpSupportScreen(),
                  ),
                );
              },
            ),

            _buildSettingItem(
              context,
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              isDarkMode: isDarkMode,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacyPolicyScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Logout button
            GestureDetector(
              onTap: () {
                // Confirm before logging out
                showDialog(
                  context: context,
                  builder:
                      (dialogContext) => AlertDialog(
                        backgroundColor:
                            isDarkMode
                                ? AppTheme.darkSurfaceColor
                                : AppTheme.lightSurfaceColor,
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(dialogContext); // Close dialog

                              // Navigate to welcome screen (logout functionality)
                              // Use a more reliable delayed execution approach
                              Future.delayed(
                                const Duration(milliseconds: 300),
                                () {
                                  if (context.mounted) {
                                    // Navigate to welcome screen and clear stack
                                    Navigator.of(
                                      context,
                                    ).pushNamedAndRemoveUntil(
                                      '/',
                                      (route) => false,
                                    );
                                  }
                                },
                              );
                            },
                            child: const Text(
                              'Logout',
                              style: TextStyle(color: AppTheme.accentRed),
                            ),
                          ),
                        ],
                      ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      color: AppTheme.accentRed,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required bool isDarkMode,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.darkCardColor : AppTheme.lightCardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          isDarkMode
                              ? AppTheme.darkPrimaryTextColor
                              : AppTheme.lightPrimaryTextColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            isDarkMode
                                ? AppTheme.darkSecondaryTextColor
                                : AppTheme.lightSecondaryTextColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color:
                  isDarkMode
                      ? AppTheme.darkSecondaryTextColor
                      : AppTheme.lightSecondaryTextColor,
            ),
          ],
        ),
      ),
    );
  }
}
