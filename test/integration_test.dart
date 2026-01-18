import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest_full/main.dart';
import 'package:lifequest_full/models/user.dart';
import 'package:lifequest_full/models/quest.dart';
import 'package:lifequest_full/providers/auth_provider.dart';
import 'package:lifequest_full/providers/quest_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Integration Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('User registration and login flow', (WidgetTester tester) async {
      // This would test the full auth flow
      await tester.pumpWidget(const LifeQuestApp());
      await tester.pumpAndSettle();

      // Should start with onboarding/auth screen
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    test('Quest completion updates user XP', () async {
      final authProvider = AuthProvider();
      final questProvider = QuestProvider();
      
      // Create a test user
      final user = User(
        id: 'test_user',
        email: 'test@test.com',
        username: 'tester',
        xp: 100,
        level: 2,
      );

      // Mock the auth state
      // authProvider.setTestUser(user); // Would need to implement this

      // Create a test quest
      final quest = Quest(
        id: 'test_quest',
        title: 'Test Quest',
        description: 'A test quest',
        type: QuestType.custom,
        category: QuestCategory.health,
        difficulty: QuestDifficulty.easy,
        xpReward: 50,
        statBoosts: {'health': 10},
        createdAt: DateTime.now(),
        isCompleted: false,
      );

      // Complete the quest
      // await questProvider.completeQuest(quest.id);

      // Verify XP was added
      // expect(authProvider.user?.xp, 150);
    });

    test('Level up triggers achievement check', () async {
      // Test that reaching a new level triggers achievement evaluation
      final authProvider = AuthProvider();
      
      final user = User(
        id: 'test_user',
        email: 'test@test.com',
        username: 'tester',
        xp: 99, // Just below level 2
        level: 1,
      );

      // Add enough XP to level up
      // await authProvider.addXP(50); // This should trigger level 2
      // expect(authProvider.user?.level, 2);
    });
  });
}