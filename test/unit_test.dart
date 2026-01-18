import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest_full/models/user.dart';
import 'package:lifequest_full/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('User Model Tests', () {
    test('User model creates correctly with default values', () {
      final user = User(
        id: 'test_id',
        email: 'test@example.com',
        username: 'testuser',
      );

      expect(user.id, 'test_id');
      expect(user.email, 'test@example.com');
      expect(user.username, 'testuser');
      expect(user.level, 1);
      expect(user.xp, 0);
      expect(user.streak, 0);
      expect(user.mentorType, 'The Mentor');
      expect(user.stats.length, 4);
      expect(user.stats['discipline'], 0);
    });

    test('User copyWith works correctly', () {
      final user = User(
        id: 'test_id',
        email: 'test@example.com',
        username: 'testuser',
      );

      final updatedUser = user.copyWith(
        level: 5,
        xp: 500,
        streak: 10,
      );

      expect(updatedUser.id, 'test_id'); // Unchanged
      expect(updatedUser.email, 'test@example.com'); // Unchanged
      expect(updatedUser.level, 5); // Changed
      expect(updatedUser.xp, 500); // Changed
      expect(updatedUser.streak, 10); // Changed
    });

    test('User toJson and fromJson work correctly', () {
      final user = User(
        id: 'test_id',
        email: 'test@example.com',
        username: 'testuser',
        level: 3,
        xp: 250,
        streak: 5,
      );

      final json = user.toJson();
      final reconstructedUser = User.fromJson(json);

      expect(reconstructedUser.id, user.id);
      expect(reconstructedUser.email, user.email);
      expect(reconstructedUser.username, user.username);
      expect(reconstructedUser.level, user.level);
      expect(reconstructedUser.xp, user.xp);
      expect(reconstructedUser.streak, user.streak);
    });
  });

  group('AuthProvider Tests', () {
    late AuthProvider authProvider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      authProvider = AuthProvider();
    });

    test('Calculate level correctly', () {
      expect(authProvider.calculateLevel(0), 1);
      expect(authProvider.calculateLevel(50), 1);
      expect(authProvider.calculateLevel(100), 2);
      expect(authProvider.calculateLevel(250), 3);
      expect(authProvider.calculateLevel(999), 10);
    });

    // Note: These tests would need additional methods in AuthProvider
    // test('XP for next level calculation', () {
    //   // This would test getXPForNextLevel() method
    //   expect(true, true); // Placeholder
    // });

    // test('Level progress calculation', () {
    //   // This would test getLevelProgress() method  
    //   expect(true, true); // Placeholder
    // });
  });
}

// Extension to expose private methods for testing - removed as calculateLevel is now public