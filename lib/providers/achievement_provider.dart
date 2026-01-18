import 'package:flutter/foundation.dart';
import '../models/achievement.dart';
import '../models/user.dart';
import '../models/quest.dart';
import '../services/achievement_service.dart';

class AchievementProvider with ChangeNotifier {
  final AchievementService _achievementService = AchievementService();
  List<Achievement> _achievements = [];
  List<UserTitle> _titles = [];
  bool _isLoading = false;
  List<Achievement> _recentlyUnlocked = [];

  List<Achievement> get achievements => _achievements;
  List<UserTitle> get titles => _titles;
  bool get isLoading => _isLoading;
  List<Achievement> get recentlyUnlocked => _recentlyUnlocked;

  // Get unlocked achievements
  List<Achievement> get unlockedAchievements => 
      _achievements.where((a) => a.isUnlocked).toList();

  // Get locked achievements
  List<Achievement> get lockedAchievements => 
      _achievements.where((a) => !a.isUnlocked).toList();

  // Get unlocked titles
  List<UserTitle> get unlockedTitles => 
      _titles.where((t) => t.isUnlocked).toList();

  // Get active title
  UserTitle? get activeTitle {
    try {
      return _titles.firstWhere((t) => t.isActive);
    } catch (e) {
      return null;
    }
  }

  // Initialize achievements
  Future<void> initAchievements() async {
    _isLoading = true;
    notifyListeners();

    try {
      await loadAchievements();
      await loadTitles();
    } catch (e) {
      print('Error initializing achievements: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load achievements
  Future<void> loadAchievements() async {
    try {
      _achievements = await _achievementService.getUserAchievements();
      notifyListeners();
    } catch (e) {
      print('Error loading achievements: $e');
    }
  }

  // Load titles
  Future<void> loadTitles() async {
    try {
      _titles = await _achievementService.getUserTitles();
      notifyListeners();
    } catch (e) {
      print('Error loading titles: $e');
    }
  }

  // Check achievements and return newly unlocked ones
  Future<List<Achievement>> checkAchievements(User user, List<Quest> completedQuests) async {
    try {
      final newlyUnlocked = await _achievementService.checkAchievements(user, completedQuests);
      
      if (newlyUnlocked.isNotEmpty) {
        _recentlyUnlocked.addAll(newlyUnlocked);
        await loadAchievements();
        await loadTitles();
        notifyListeners();
      }
      
      return newlyUnlocked;
    } catch (e) {
      print('Error checking achievements: $e');
      return [];
    }
  }

  // Clear recently unlocked achievements
  void clearRecentlyUnlocked() {
    _recentlyUnlocked.clear();
    notifyListeners();
  }

  // Set active title
  Future<bool> setActiveTitle(String titleId) async {
    try {
      final success = await _achievementService.setActiveTitle(titleId);
      if (success) {
        await loadTitles();
        return true;
      }
    } catch (e) {
      print('Error setting active title: $e');
    }
    return false;
  }

  // Get achievement progress
  Future<double> getAchievementProgress(String achievementId, User user, List<Quest> completedQuests) async {
    try {
      return await _achievementService.getAchievementProgress(achievementId, user, completedQuests);
    } catch (e) {
      print('Error getting achievement progress: $e');
      return 0.0;
    }
  }

  // Get achievements by rarity
  List<Achievement> getAchievementsByRarity(AchievementRarity rarity) {
    return _achievements.where((a) => a.rarity == rarity).toList();
  }

  // Get achievements by type
  List<Achievement> getAchievementsByType(AchievementType type) {
    return _achievements.where((a) => a.type == type).toList();
  }

  // Get achievement by ID
  Achievement? getAchievementById(String id) {
    try {
      return _achievements.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get title by ID
  UserTitle? getTitleById(String id) {
    try {
      return _titles.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get completion percentage
  double get completionPercentage {
    if (_achievements.isEmpty) return 0.0;
    final unlockedCount = _achievements.where((a) => a.isUnlocked).length;
    return unlockedCount / _achievements.length;
  }

  // Get total XP earned from achievements
  int get totalAchievementXP {
    return _achievements
        .where((a) => a.isUnlocked)
        .fold(0, (sum, achievement) => sum + achievement.xpReward);
  }

  // Get achievements grouped by rarity
  Map<AchievementRarity, List<Achievement>> get achievementsByRarity {
    final grouped = <AchievementRarity, List<Achievement>>{};
    
    for (final rarity in AchievementRarity.values) {
      grouped[rarity] = _achievements.where((a) => a.rarity == rarity).toList();
    }
    
    return grouped;
  }

  // Get recent achievements (unlocked in last 7 days)
  List<Achievement> get recentAchievements {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _achievements.where((a) {
      return a.isUnlocked && 
             a.unlockedAt != null && 
             a.unlockedAt!.isAfter(weekAgo);
    }).toList();
  }

  // Get next achievements to unlock (closest to completion)
  Future<List<Achievement>> getNextAchievements(User user, List<Quest> completedQuests) async {
    final locked = lockedAchievements;
    final progressList = <MapEntry<Achievement, double>>[];
    
    for (final achievement in locked) {
      final progress = await getAchievementProgress(achievement.id, user, completedQuests);
      progressList.add(MapEntry(achievement, progress));
    }
    
    // Sort by progress (highest first) and take top 3
    progressList.sort((a, b) => b.value.compareTo(a.value));
    return progressList.take(3).map((entry) => entry.key).toList();
  }

  // Reset achievements (for testing)
  Future<void> resetAchievements() async {
    try {
      await _achievementService.resetAchievements();
      _achievements.clear();
      _titles.clear();
      _recentlyUnlocked.clear();
      await initAchievements();
    } catch (e) {
      print('Error resetting achievements: $e');
    }
  }
}

