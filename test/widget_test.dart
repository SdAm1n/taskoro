// Basic Flutter widget test for Taskoro app
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:taskoro/main.dart';
import 'package:taskoro/services/task_provider.dart';
import 'package:taskoro/services/team_provider.dart';
import 'package:taskoro/services/language_provider.dart';
import 'package:taskoro/services/theme_provider.dart';

void main() {
  testWidgets('Taskoro app loads without error', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TaskProvider()),
          ChangeNotifierProvider(create: (_) => TeamProvider()),
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the app loads and shows the home screen
    expect(find.byType(MyApp), findsOneWidget);

    // Wait for any async initialization to complete
    await tester.pumpAndSettle();

    // The app should load without throwing any exceptions
    expect(tester.takeException(), isNull);
  });
}
