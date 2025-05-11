import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@taskoro.com',
      queryParameters: {
        'subject': 'Taskoro Support Request',
        'body': 'Hello Taskoro Support Team,\n\n',
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchWebsite() async {
    final Uri websiteUri = Uri.parse('https://taskoro.example.com/support');

    if (await canLaunchUrl(websiteUri)) {
      await launchUrl(websiteUri);
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
      appBar: CustomAppBar(title: 'Help & Support'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Support options
            Text(
              'How Can We Help You?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color:
                    isDarkMode
                        ? AppTheme.darkPrimaryTextColor
                        : AppTheme.lightPrimaryTextColor,
              ),
            ),
            const SizedBox(height: 20),

            // Contact support
            _buildSupportCard(
              context,
              title: 'Contact Support',
              description:
                  'Have a question or issue? Our team is ready to help you.',
              icon: Icons.support_agent_outlined,
              iconColor: AppTheme.primaryColor,
              isDarkMode: isDarkMode,
              onTap: _launchEmail,
            ),

            // Visit help center
            _buildSupportCard(
              context,
              title: 'Visit Help Center',
              description:
                  'Browse our knowledge base for answers to common questions.',
              icon: Icons.help_outline,
              iconColor: AppTheme.accentBlue,
              isDarkMode: isDarkMode,
              onTap: _launchWebsite,
            ),

            // FAQs section
            const SizedBox(height: 30),
            Text(
              'Frequently Asked Questions',
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

            _buildFaqItem(
              context,
              question: 'How do I create a new task?',
              answer:
                  'Tap the + button on the home screen to add a new task. Fill in the details like title, description, dates, and priority, then tap Save.',
              isDarkMode: isDarkMode,
            ),

            _buildFaqItem(
              context,
              question: 'Can I set recurring tasks?',
              answer:
                  'Currently, recurring tasks are not supported but this feature is on our roadmap for a future update.',
              isDarkMode: isDarkMode,
            ),

            _buildFaqItem(
              context,
              question: 'How do I change the app theme?',
              answer:
                  'Go to Settings and toggle the Dark Mode switch to change between light and dark themes.',
              isDarkMode: isDarkMode,
            ),

            _buildFaqItem(
              context,
              question: 'Is my data backed up?',
              answer:
                  'Your data is stored locally on your device. We recommend regularly backing up your device to prevent data loss.',
              isDarkMode: isDarkMode,
            ),

            const SizedBox(height: 30),

            // Contact button
            Center(
              child: CustomButton(
                text: 'Contact Us',
                onPressed: _launchEmail,
                icon: Icons.email_outlined,
                width: 200,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.darkCardColor : AppTheme.lightCardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: iconColor.withAlpha(50), width: 1),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: iconColor.withAlpha(30),
              child: Icon(icon, color: iconColor, size: 25),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          isDarkMode
                              ? AppTheme.darkPrimaryTextColor
                              : AppTheme.lightPrimaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
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

  Widget _buildFaqItem(
    BuildContext context, {
    required String question,
    required String answer,
    required bool isDarkMode,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color:
                isDarkMode
                    ? AppTheme.darkPrimaryTextColor
                    : AppTheme.lightPrimaryTextColor,
          ),
        ),
        collapsedIconColor: AppTheme.primaryColor,
        iconColor: AppTheme.primaryColor,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 14,
                color:
                    isDarkMode
                        ? AppTheme.darkSecondaryTextColor
                        : AppTheme.lightSecondaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
