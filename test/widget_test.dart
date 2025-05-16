// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// Import relative path instead of package path for tests
import '../lib/main.dart';
import '../lib/utils/constants.dart';

void main() {
  testWidgets('App renders home screen with help button', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(false),
        child: const MyApp(),
      ),
    );

    // Verify that the app title is displayed
    expect(find.text(AppConstants.appName), findsOneWidget);

    // Verify that the help button is displayed
    expect(find.text('HELP'), findsOneWidget);
  });
}
