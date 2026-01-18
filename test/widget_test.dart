// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lifequest_full/main.dart';

void main() {
  // Setup for testing
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('LifeQuest app builds without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LifeQuestApp());
    await tester.pumpAndSettle();

    // Verify that the app loads - check for onboarding or auth screen
    expect(find.byType(Scaffold), findsAtLeast(1));
  });

  testWidgets('AuthWrapper shows loading initially', (WidgetTester tester) async {
    await tester.pumpWidget(const LifeQuestApp());
    
    // Should show loading spinner initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
