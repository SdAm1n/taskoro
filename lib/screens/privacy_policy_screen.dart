import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Future<void> _launchWebPrivacyPolicy() async {
    final Uri privacyPolicyUri = Uri.parse(
      'https://taskoro.example.com/privacy-policy',
    );

    if (await canLaunchUrl(privacyPolicyUri)) {
      await launchUrl(privacyPolicyUri);
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
      appBar: CustomAppBar(title: 'Privacy Policy'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Last updated
            Text(
              'Last Updated: May 12, 2025',
              style: TextStyle(
                fontSize: 14,
                color:
                    isDarkMode
                        ? AppTheme.darkSecondaryTextColor
                        : AppTheme.lightSecondaryTextColor,
              ),
            ),
            const SizedBox(height: 24),

            // Introduction
            _buildSectionTitle(context, 'Introduction', isDarkMode),
            _buildParagraph(
              context,
              'Welcome to Taskoro. We respect your privacy and are committed to protecting your personal data. This Privacy Policy will inform you about how we look after your personal data when you use our application and tell you about your privacy rights.',
              isDarkMode,
            ),

            // Data collection
            _buildSectionTitle(context, 'What Data We Collect', isDarkMode),
            _buildParagraph(
              context,
              'We collect and process the following categories of personal data:',
              isDarkMode,
            ),
            _buildBulletPoint(
              context,
              'Account Information: When you create a Taskoro account, we collect your name and email address.',
              isDarkMode,
            ),
            _buildBulletPoint(
              context,
              'Task Data: The tasks, notes, dates, and other content you create while using the app.',
              isDarkMode,
            ),
            _buildBulletPoint(
              context,
              'Usage Data: Information about how you use the app, including frequency and duration of use.',
              isDarkMode,
            ),
            _buildBulletPoint(
              context,
              'Device Information: Information about your device, including device type, operating system, and unique device identifiers.',
              isDarkMode,
            ),

            // How we use data
            _buildSectionTitle(context, 'How We Use Your Data', isDarkMode),
            _buildParagraph(
              context,
              'We use your personal data for the following purposes:',
              isDarkMode,
            ),
            _buildBulletPoint(
              context,
              'To provide and maintain our service',
              isDarkMode,
            ),
            _buildBulletPoint(
              context,
              'To notify you about changes to our service',
              isDarkMode,
            ),
            _buildBulletPoint(
              context,
              'To provide customer support',
              isDarkMode,
            ),
            _buildBulletPoint(
              context,
              'To improve and personalize your experience',
              isDarkMode,
            ),

            // Data security
            _buildSectionTitle(context, 'Data Security', isDarkMode),
            _buildParagraph(
              context,
              'We implement appropriate security measures to protect your personal data against accidental or unlawful destruction, loss, alteration, unauthorized disclosure, or access. We limit access to your personal data to those employees and third parties who have a business need to know.',
              isDarkMode,
            ),

            // Your rights
            _buildSectionTitle(context, 'Your Rights', isDarkMode),
            _buildParagraph(
              context,
              'Depending on your location, you may have the following rights regarding your personal data:',
              isDarkMode,
            ),
            _buildBulletPoint(
              context,
              'Access and receive a copy of your data',
              isDarkMode,
            ),
            _buildBulletPoint(
              context,
              'Rectify inaccurate or incomplete data',
              isDarkMode,
            ),
            _buildBulletPoint(
              context,
              'Request deletion of your data',
              isDarkMode,
            ),
            _buildBulletPoint(
              context,
              'Object to or restrict the processing of your data',
              isDarkMode,
            ),

            // Contact
            _buildSectionTitle(context, 'Contact Us', isDarkMode),
            _buildParagraph(
              context,
              'If you have any questions about this Privacy Policy or our data practices, please contact us at privacy@taskoro.com',
              isDarkMode,
            ),

            const SizedBox(height: 30),

            // View full policy button
            Center(
              child: CustomButton(
                text: 'View Full Policy Online',
                onPressed: _launchWebPrivacyPolicy,
                icon: Icons.open_in_new,
                width: 250,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 24),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color:
              isDarkMode
                  ? AppTheme.darkPrimaryTextColor
                  : AppTheme.lightPrimaryTextColor,
        ),
      ),
    );
  }

  Widget _buildParagraph(BuildContext context, String text, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color:
              isDarkMode
                  ? AppTheme.darkPrimaryTextColor
                  : AppTheme.lightPrimaryTextColor,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color:
                    isDarkMode
                        ? AppTheme.darkPrimaryTextColor
                        : AppTheme.lightPrimaryTextColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
