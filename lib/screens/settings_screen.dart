import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import '../services/task_provider.dart';
import '../services/language_provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';
import '../localization/translation_helper.dart';
import 'edit_profile_screen.dart';
import 'app_version_screen.dart';
import 'rate_app_screen.dart';
import 'help_support_screen.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Show language selection dialog
  void _showLanguageSelectionDialog(
    BuildContext context,
    LanguageProvider languageProvider,
  ) {
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor:
                isDarkMode
                    ? AppTheme.darkSurfaceColor
                    : AppTheme.lightSurfaceColor,
            title: Text(context.tr('select_language')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // English option
                ListTile(
                  title: const Text('English'),
                  leading: Radio<String>(
                    value: LanguageProvider.english,
                    groupValue: languageProvider.currentLanguage,
                    onChanged: (String? value) {
                      if (value != null) {
                        languageProvider.setLanguage(value);
                        Navigator.pop(context);
                      }
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                  onTap: () {
                    languageProvider.setLanguage(LanguageProvider.english);
                    Navigator.pop(context);
                  },
                ),

                // Bangla option
                ListTile(
                  title: const Text('বাংলা'),
                  leading: Radio<String>(
                    value: LanguageProvider.bangla,
                    groupValue: languageProvider.currentLanguage,
                    onChanged: (String? value) {
                      if (value != null) {
                        languageProvider.setLanguage(value);
                        Navigator.pop(context);
                      }
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                  onTap: () {
                    languageProvider.setLanguage(LanguageProvider.bangla);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.tr('cancel')),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final user = taskProvider.currentUser;
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppTheme.darkBackgroundColor
              : AppTheme.lightBackgroundColor,
      appBar: CustomAppBar(title: context.tr('settings')),
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
              context.tr('app_settings'),
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
                        context.tr('dark_mode'),
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

            // Language selection
            GestureDetector(
              onTap: () {
                _showLanguageSelectionDialog(context, languageProvider);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
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
                        Icon(Icons.language, color: AppTheme.primaryColor),
                        const SizedBox(width: 12),
                        Text(
                          context.tr('language'),
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
                    Row(
                      children: [
                        Text(
                          languageProvider.getLanguageName(),
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                isDarkMode
                                    ? AppTheme.darkSecondaryTextColor
                                    : AppTheme.lightSecondaryTextColor,
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
                  ],
                ),
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
                        context.tr('notifications'),
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
              context.tr('about'),
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
              title: context.tr('app_version'),
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
              title: context.tr('rate_app'),
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
              title: context.tr('help_support'),
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
              title: context.tr('privacy_policy'),
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
                        title: Text(context.tr('logout')),
                        content: Text(context.tr('logout_confirm')),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: Text(context.tr('cancel')),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(dialogContext); // Close dialog

                              try {
                                // Sign out using AuthService
                                await context.read<AuthService>().signOut();

                                // Show success message
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Logged out successfully'),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }

                                // The AuthWrapper will automatically handle navigation
                                // to the login screen when the auth state changes
                              } catch (e) {
                                if (context.mounted) {
                                  // Check if logout was actually successful
                                  final authService =
                                      context.read<AuthService>();
                                  if (authService.currentUser == null) {
                                    // Logout was successful despite the error
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Logged out successfully',
                                        ),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  } else {
                                    // Logout actually failed
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Logout failed: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            child: Text(
                              context.tr('logout'),
                              style: const TextStyle(color: AppTheme.accentRed),
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
                    context.tr('logout'),
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
