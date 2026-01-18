import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';
import '../models/user.dart';
import '../models/quest.dart';

class AchievementService {
  static const String _achievementsKey = 'user_achievements';
  static const String _titlesKey = 'user_titles';
  static const String _statsKey = 'achievement_stats';

  // Get user achievements
  Future<List<Achievement>> getUserAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final achievementsJson = prefs.getString(_achievementsKey);
      
      if (achievementsJson == null) {
        // Initialize with default achievements
        final defaultAchievements = Achievement.getDefaultAchievements();
        await saveUserAchievements(defaultAchievements);
        return defaultAchievements;
      }
      
      final achievementsList = List<Map<String, dynamic>>.from(jsonDecode(achievementsJson));
      return achievementsList.map((json) => Achievement.fromJson(json)).toList();
    } catch (e) {
      print('Error getting user achievements: $e');
      return Achievement.getDefaultAchievements();
    }
  }

  // Save user achievements
  Future<bool> saveUserAchievements(List<Achievement> achievements) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final achievementsJson = jsonEncode(achievements.map((a) => a.toJson()).toList());
      await prefs.setString(_achievementsKey, achievementsJson);
      return true;
    } catch (e) {
      print('Error saving user achievements: $e');
      return false;
    }
  }

  // Get user titles
  Future<List<UserTitle>> getUserTitles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final titlesJson = prefs.getString(_titlesKey);
      
      if (titlesJson == null) {
        // Initialize with default titles
        final defaultTitles = UserTitle.getDefaultTitles();
        await saveUserTitles(defaultTitles);
        return defaultTitles;
      }
      
      final titlesList = List<Map<String, dynamic>>.from(jsonDecode(titlesJson));
      return titlesList.map((json) => UserTitle.fromJson(json)).toList();
    } catch (e) {
      print('Error getting user titles: $e');
      return UserTitle.getDefaultTitles();
    }
  }

  // Save user titles
  Future<bool> saveUserTitles(List<UserTitle> titles) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final titlesJson = jsonEncode(titles.map((t) => t.toJson()).toList());
      await prefs.setString(_titlesKey, titlesJson);
      return true;
    } catch (e) {
      print('Error saving user titles: $e');
      return false;
    }
  }

  // Get achievement stats
  Future<Map<String, int>> getAchievementStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString(_statsKey) ?? '{}';
      return Map<String, int>.from(jsonDecode(statsJson));
    } catch (e) {
      print('Error getting achievement stats: $e');
      return {};
    }
  }

  // Save achievement stats
  Future<bool> saveAchievementStats(Map<String, int> stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = jsonEncode(stats);
      await prefs.setString(_statsKey, statsJson);
      return true;
    } catch (e) {
      print('Error saving achievement stats: $e');
      return false;
    }
  }

  // Check and unlock achievements based on user progress
  Future<List<Achievement>> checkAchievements(User user, List<Quest> completedQuests) async {
    final achievements = await getUserAchievements();
    final stats = await getAchievementStats();
    final newlyUnlocked = <Achievement>[];

    // Update stats
    stats['questsCompleted'] = completedQuests.length;
    stats['level'] = user.level;
    stats['streak'] = user.streak;

    // Count quests by category
    final categoryCount = <String, int>{};
    for (final quest in completedQuests) {
      final category = quest.category.toString().split('.').last;
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }

    // Check each achievement
    for (int i = 0; i < achievements.length; i++) {
      final achievement = achievements[i];
      if (achievement.isUnlocked) continue;

      bool shouldUnlock = false;

      switch (achievement.type) {
        case AchievementType.questCompletion:
          shouldUnlock = stats['questsCompleted']! >= achievement.targetValue;
          break;

        case AchievementType.streak:
          shouldUnlock = stats['streak']! >= achievement.targetValue;
          break;

        case AchievementType.levelUp:
          shouldUnlock = stats['level']! >= achievement.targetValue;
          break;

        case AchievementType.category:
          final category = achievement.criteria['category'] as String;
          final requiredCount = achievement.criteria['count'] as int;
          shouldUnlock = (categoryCount[category] ?? 0) >= requiredCount;
          break;

        case AchievementType.special:
          shouldUnlock = _checkSpecialAchievement(achievement, user, completedQuests);
          break;

        case AchievementType.statBoost:
          shouldUnlock = _checkStatBoostAchievement(achievement, user);
          break;
      }

      if (shouldUnlock) {
        achievements[i] = achievement.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
        newlyUnlocked.add(achievements[i]);
      }
    }

    // Save updated achievements and stats
    await saveUserAchievements(achievements);
    await saveAchievementStats(stats);

    // Check and unlock titles
    await _checkAndUnlockTitles(achievements);

    return newlyUnlocked;
  }

  // Check special achievements
  bool _checkSpecialAchievement(Achievement achievement, User user, List<Quest> completedQuests) {
    switch (achievement.id) {
      case 'perfect_day':
        // Check if all today's quests are completed
        final today = DateTime.now();
        final todaysQuests = completedQuests.where((quest) {
          return quest.completedAt != null &&
                 quest.completedAt!.year == today.year &&
                 quest.completedAt!.month == today.month &&
                 quest.completedAt!.day == today.day;
        }).toList();
        // This is a simplified check - in a real app, you'd need to know how many quests were available today
        return todaysQuests.length >= 3; // Assuming 3+ quests per day

      case 'early_bird':
        return completedQuests.any((quest) {
          return quest.completedAt != null && quest.completedAt!.hour < 8;
        });

      case 'night_owl':
        return completedQuests.any((quest) {
          return quest.completedAt != null && quest.completedAt!.hour >= 22;
        });

      default:
        return false;
    }
  }

  // Check stat boost achievements
  bool _checkStatBoostAchievement(Achievement achievement, User user) {
    // This would check if user has reached certain stat levels
    // For now, we'll return false as we don't have specific stat achievements defined
    return false;
  }

  // Check and unlock titles based on achievements
  Future<void> _checkAndUnlockTitles(List<Achievement> achievements) async {
    final titles = await getUserTitles();
    final unlockedAchievementIds = achievements
        .where((a) => a.isUnlocked)
        .map((a) => a.id)
        .toSet();

    bool titlesUpdated = false;

    for (int i = 0; i < titles.length; i++) {
      final title = titles[i];
      if (title.isUnlocked) continue;

      // Check if all required achievements are unlocked
      final hasAllRequirements = title.requiredAchievements
          .every((reqId) => unlockedAchievementIds.contains(reqId));

      if (hasAllRequirements) {
        titles[i] = title.copyWith(isUnlocked: true);
        titlesUpdated = true;
      }
    }

    if (titlesUpdated) {
      await saveUserTitles(titles);
    }
  }

  // Get unlocked achievements
  Future<List<Achievement>> getUnlockedAchievements() async {
    final achievements = await getUserAchievements();
    return achievements.where((a) => a.isUnlocked).toList();
  }

  // Get locked achievements
  Future<List<Achievement>> getLockedAchievements() async {
    final achievements = await getUserAchievements();
    return achievements.where((a) => !a.isUnlocked).toList();
  }

  // Get achievements by rarity
  Future<List<Achievement>> getAchievementsByRarity(AchievementRarity rarity) async {
    final achievements = await getUserAchievements();
    return achievements.where((a) => a.rarity == rarity).toList();
  }

  // Get unlocked titles
  Future<List<UserTitle>> getUnlockedTitles() async {
    final titles = await getUserTitles();
    return titles.where((t) => t.isUnlocked).toList();
  }

  // Get active title
  Future<UserTitle?> getActiveTitle() async {
    final titles = await getUserTitles();
    try {
      return titles.firstWhere((t) => t.isActive);
    } catch (e) {
      return null;
    }
  }

  // Set active title
  Future<bool> setActiveTitle(String titleId) async {
    final titles = await getUserTitles();
    
    // Find the title and check if it's unlocked
    final titleIndex = titles.indexWhere((t) => t.id == titleId);
    if (titleIndex == -1 || !titles[titleIndex].isUnlocked) {
      return false;
    }

    // Deactivate all titles
    for (int i = 0; i < titles.length; i++) {
      titles[i] = titles[i].copyWith(isActive: false);
    }

    // Activate the selected title
    titles[titleIndex] = titles[titleIndex].copyWith(isActive: true);

    return await saveUserTitles(titles);
  }

  // Get achievement progress for a specific achievement
  Future<double> getAchievementProgress(String achievementId, User user, List<Quest> completedQuests) async {
    final achievements = await getUserAchievements();
    final achievement = achievements.firstWhere((a) => a.id == achievementId);
    
    if (achievement.isUnlocked) return 1.0;

    final stats = await getAchievementStats();
    
    switch (achievement.type) {
      case AchievementType.questCompletion:
        return (stats['questsCompleted'] ?? 0) / achievement.targetValue;
      
      case AchievementType.streak:
        return (stats['streak'] ?? 0) / achievement.targetValue;
      
      case AchievementType.levelUp:
        return (stats['level'] ?? 0) / achievement.targetValue;
      
      case AchievementType.category:
        final category = achievement.criteria['category'] as String;
        final categoryCount = completedQuests
            .where((q) => q.category.toString().split('.').last == category)
            .length;
        return categoryCount / achievement.targetValue;
      
      default:
        return 0.0;
    }
  }

  // Reset all achievements (for testing)
  Future<void> resetAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_achievementsKey);
    await prefs.remove(_titlesKey);
    await prefs.remove(_statsKey);
  }
}

