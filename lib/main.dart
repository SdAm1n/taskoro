import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_screen.dart';
import 'screens/task_detail_screen.dart';
import 'screens/add_edit_task_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/notifications_screen.dart';
import 'services/task_provider.dart';
import 'services/theme_provider.dart';
import 'services/language_provider.dart';
import 'theme/app_theme.dart';
import 'utils/custom_page_route.dart';
import 'package:flutter/services.dart';
import 'localization/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TaskProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (context) => LanguageProvider()..initLanguage(),
        ),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, _) {
          // Set system UI overlay style based on theme
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  themeProvider.isDarkMode ? Brightness.light : Brightness.dark,
              systemNavigationBarColor:
                  themeProvider.isDarkMode
                      ? AppTheme.darkBackgroundColor
                      : AppTheme.lightBackgroundColor,
              systemNavigationBarIconBrightness:
                  themeProvider.isDarkMode ? Brightness.light : Brightness.dark,
            ),
          );

          return MaterialApp(
            title: 'TASKORO',
            debugShowCheckedModeBanner: false,
            theme:
                themeProvider.isDarkMode
                    ? AppTheme.darkTheme
                    : AppTheme.lightTheme,
            // Use a custom page route to prevent automatic back button
            builder: (context, child) {
              return child!; // Return without any modifications
            },

            // Localization setup
            locale: Locale(languageProvider.currentLanguage),
            supportedLocales: const [
              Locale('en', ''), // English
              Locale('bn', ''), // Bangla
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            initialRoute: '/splash',
            routes: {
              '/splash': (context) => const SplashScreen(),
              '/': (context) => const WelcomeScreen(),
              '/home': (context) => const MainScreen(),
              '/add_task': (context) => const AddEditTaskScreen(),
              '/notifications': (context) => const NotificationsScreen(),
            },
            onGenerateRoute: (settings) {
              // Special case for task detail
              if (settings.name == '/task_detail') {
                final args = settings.arguments as Map<String, dynamic>;
                return NoBackButtonPageRoute(
                  builder:
                      (context) => TaskDetailScreen(taskId: args['taskId']),
                  fullscreenDialog: true,
                );
              }
              return null;
            },
          );
        },
      ),
    );
  }
}
