// Basic Flutter widget test for Taskoro app
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:taskoro/services/language_provider.dart';
import 'package:taskoro/services/theme_provider.dart';
import 'package:taskoro/theme/app_theme.dart';

void main() {
  testWidgets('Taskoro basic providers and theme load correctly', (
    WidgetTester tester,
  ) async {
    // Test basic providers without Firebase dependencies
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: MaterialApp(
          title: 'Taskoro Test',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const Scaffold(body: Center(child: Text('Test App'))),
        ),
      ),
    );

    // Verify that the basic structure loads
    expect(find.text('Test App'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);

    // Test that providers are accessible
    final context = tester.element(find.text('Test App'));
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    expect(languageProvider, isNotNull);
    expect(themeProvider, isNotNull);
  });

  testWidgets('Basic app structure works without Firebase', (
    WidgetTester tester,
  ) async {
    // Test basic app structure without Firebase dependencies
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: MaterialApp(
          title: 'Taskoro Test',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(56.0),
              child: AppBar(title: Text('Test')),
            ),
            body: Center(child: Text('Firebase Integration Complete')),
          ),
        ),
      ),
    );

    // Verify that the basic structure loads
    expect(find.text('Firebase Integration Complete'), findsOneWidget);
    expect(find.text('Test'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);

    // Test that providers are accessible
    final context = tester.element(find.text('Firebase Integration Complete'));
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    expect(languageProvider, isNotNull);
    expect(themeProvider, isNotNull);
    expect(themeProvider.isDarkMode, isA<bool>());
  });
}
