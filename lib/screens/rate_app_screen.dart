import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';

class RateAppScreen extends StatelessWidget {
  const RateAppScreen({super.key});

  // Mock function for app store URL
  // In a real app, these would be actual store URLs
  Future<void> _launchAppStore(BuildContext context) async {
    // For Android
    Uri androidUri = Uri.parse(
      'https://play.google.com/store/apps/details?id=com.example.taskoro',
    );
    // For iOS
    Uri iosUri = Uri.parse('https://apps.apple.com/app/id123456789');

    if (Theme.of(context).platform == TargetPlatform.android) {
      if (await canLaunchUrl(androidUri)) {
        await launchUrl(androidUri);
      }
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      if (await canLaunchUrl(iosUri)) {
        await launchUrl(iosUri);
      }
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
      appBar: CustomAppBar(title: 'Rate App'),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 30),

            // Heading
            Text(
              'Enjoying Taskoro?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color:
                    isDarkMode
                        ? AppTheme.darkPrimaryTextColor
                        : AppTheme.lightPrimaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              'Your feedback helps us improve and motivates us to make Taskoro even better!',
              style: TextStyle(
                fontSize: 16,
                color:
                    isDarkMode
                        ? AppTheme.darkSecondaryTextColor
                        : AppTheme.lightSecondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Rate stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Icon(Icons.star, size: 40, color: AppTheme.accentYellow);
              }),
            ),
            const SizedBox(height: 40),

            // Rate now button
            CustomButton(
              text: 'Rate on App Store',
              onPressed: () => _launchAppStore(context),
              icon: Icons.thumb_up,
            ),
            const SizedBox(height: 16),

            // Not now button
            CustomButton(
              text: 'Not Now',
              onPressed: () => Navigator.pop(context),
              isOutlined: true,
            ),
          ],
        ),
      ),
    );
  }
}
