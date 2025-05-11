import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';

class AppVersionScreen extends StatelessWidget {
  const AppVersionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode
              ? AppTheme.darkBackgroundColor
              : AppTheme.lightBackgroundColor,
      appBar: CustomAppBar(title: 'App Version'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App logo and version
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Taskoro',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color:
                          isDarkMode
                              ? AppTheme.darkPrimaryTextColor
                              : AppTheme.lightPrimaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          isDarkMode
                              ? AppTheme.darkSecondaryTextColor
                              : AppTheme.lightSecondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // What's new section
            Text(
              "What's New",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color:
                    isDarkMode
                        ? AppTheme.darkPrimaryTextColor
                        : AppTheme.lightPrimaryTextColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildVersionHistoryItem(
              context,
              version: '1.0.0',
              date: 'May 12, 2025',
              isDarkMode: isDarkMode,
              features: [
                'Initial release',
                'Task management with priority levels',
                'Calendar integration',
                'Analytics dashboard',
                'Dark and light theme support',
              ],
            ),

            const SizedBox(height: 24),
            _buildVersionHistoryItem(
              context,
              version: '0.9.0',
              date: 'April 15, 2025',
              isDarkMode: isDarkMode,
              features: [
                'Beta release',
                'Core functionality implementation',
                'User interface design finalization',
                'Performance improvements',
              ],
            ),

            const SizedBox(height: 40),

            // About developer section
            Center(
              child: Column(
                children: [
                  Text(
                    'Developed by',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          isDarkMode
                              ? AppTheme.darkSecondaryTextColor
                              : AppTheme.lightSecondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Flutter Development Team',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© 2025 All Rights Reserved',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          isDarkMode
                              ? AppTheme.darkSecondaryTextColor
                              : AppTheme.lightSecondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionHistoryItem(
    BuildContext context, {
    required String version,
    required String date,
    required bool isDarkMode,
    required List<String> features,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkCardColor : AppTheme.lightCardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Version $version',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color:
                      isDarkMode
                          ? AppTheme.darkPrimaryTextColor
                          : AppTheme.lightPrimaryTextColor,
                ),
              ),
              Text(
                date,
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
          const SizedBox(height: 12),
          ...features
              .map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                isDarkMode
                                    ? AppTheme.darkPrimaryTextColor
                                    : AppTheme.lightPrimaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}
