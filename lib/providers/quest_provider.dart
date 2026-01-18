import 'package:flutter/foundation.dart';
import '../models/quest.dart';
import '../services/quest_service.dart';

class QuestProvider with ChangeNotifier {
  final QuestService _questService = QuestService();
  List<Quest> _quests = [];
  List<Quest> _todaysQuests = [];
  bool _isLoading = false;

  List<Quest> get quests => _quests;
  List<Quest> get todaysQuests => _todaysQuests;
  bool get isLoading => _isLoading;

  // Get completed quests count for today
  int get todaysCompletedCount {
    return _todaysQuests.where((quest) => quest.isCompleted).length;
  }

  // Get total XP earned today
  int get todaysXP {
    return _todaysQuests
        .where((quest) => quest.isCompleted)
        .fold(0, (sum, quest) => sum + quest.xpReward);
  }

  // Get stat boosts earned today
  Map<String, int> get todaysStatBoosts {
    final stats = <String, int>{};
    
    for (final quest in _todaysQuests.where((q) => q.isCompleted)) {
      quest.statBoosts.forEach((stat, boost) {
        stats[stat] = (stats[stat] ?? 0) + boost;
      });
    }
    
    return stats;
  }

  // Initialize quests
  Future<void> initQuests() async {
    _isLoading = true;
    notifyListeners();

    try {
      await loadQuests();
      await ensureDailyQuests();
    } catch (e) {
      print('Error initializing quests: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load all quests
  Future<void> loadQuests() async {
    try {
      _quests = await _questService.getUserQuests();
      _todaysQuests = await _questService.getTodaysQuests();
      notifyListeners();
    } catch (e) {
      print('Error loading quests: $e');
    }
  }

  // Ensure daily quests are available
  Future<void> ensureDailyQuests() async {
    try {
      final dailyQuests = await _questService.ensureDailyQuests();
      if (dailyQuests.isNotEmpty) {
        await loadQuests(); // Reload to get the updated quests
      }
    } catch (e) {
      print('Error ensuring daily quests: $e');
    }
  }

  // Complete a quest
  Future<bool> completeQuest(String questId) async {
    try {
      final success = await _questService.completeQuest(questId);
      if (success) {
        // Update local state
        final questIndex = _quests.indexWhere((q) => q.id == questId);
        if (questIndex != -1) {
          _quests[questIndex] = _quests[questIndex].copyWith(
            isCompleted: true,
            completedAt: DateTime.now(),
          );
        }

        final todayQuestIndex = _todaysQuests.indexWhere((q) => q.id == questId);
        if (todayQuestIndex != -1) {
          _todaysQuests[todayQuestIndex] = _todaysQuests[todayQuestIndex].copyWith(
            isCompleted: true,
            completedAt: DateTime.now(),
          );
        }

        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error completing quest: $e');
    }
    return false;
  }

  // Undo quest completion
  Future<bool> undoQuestCompletion(String questId) async {
    try {
      final success = await _questService.undoQuestCompletion(questId);
      if (success) {
        // Update local state
        final questIndex = _quests.indexWhere((q) => q.id == questId);
        if (questIndex != -1) {
          _quests[questIndex] = _quests[questIndex].copyWith(
            isCompleted: false,
            completedAt: null,
          );
        }

        final todayQuestIndex = _todaysQuests.indexWhere((q) => q.id == questId);
        if (todayQuestIndex != -1) {
          _todaysQuests[todayQuestIndex] = _todaysQuests[todayQuestIndex].copyWith(
            isCompleted: false,
            completedAt: null,
          );
        }

        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error undoing quest completion: $e');
    }
    return false;
  }

  // Add a custom quest
  Future<bool> addCustomQuest({
    required String title,
    required String description,
    required QuestCategory category,
    required QuestDifficulty difficulty,
    DateTime? dueDate,
  }) async {
    try {
      final quest = Quest(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        description: description,
        type: QuestType.custom,
        category: category,
        difficulty: difficulty,
        xpReward: _calculateXPReward(difficulty),
        statBoosts: _generateStatBoosts(category, difficulty),
        createdAt: DateTime.now(),
        dueDate: dueDate,
      );

      final success = await _questService.addCustomQuest(quest);
      if (success) {
        await loadQuests();
        return true;
      }
    } catch (e) {
      print('Error adding custom quest: $e');
    }
    return false;
  }

  // Remove a quest
  Future<bool> removeQuest(String questId) async {
    try {
      final success = await _questService.removeQuest(questId);
      if (success) {
        _quests.removeWhere((q) => q.id == questId);
        _todaysQuests.removeWhere((q) => q.id == questId);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error removing quest: $e');
    }
    return false;
  }

  // Generate new daily quests manually
  Future<void> generateNewDailyQuests() async {
    _isLoading = true;
    notifyListeners();

    try {
      final newQuests = await _questService.generateDailyQuests();
      final existingQuests = await _questService.getUserQuests();
      
      // Remove old daily quests
      final nonDailyQuests = existingQuests.where((q) => q.type != QuestType.daily).toList();
      
      // Add new daily quests
      final allQuests = [...nonDailyQuests, ...newQuests];
      
      await _questService.saveUserQuests(allQuests);
      await loadQuests();
    } catch (e) {
      print('Error generating new daily quests: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Helper methods
  int _calculateXPReward(QuestDifficulty difficulty) {
    switch (difficulty) {
      case QuestDifficulty.easy:
        return 10;
      case QuestDifficulty.medium:
        return 20;
      case QuestDifficulty.hard:
        return 30;
    }
  }

  Map<String, int> _generateStatBoosts(QuestCategory category, QuestDifficulty difficulty) {
    final baseBoost = difficulty == QuestDifficulty.easy ? 1 : 
                     difficulty == QuestDifficulty.medium ? 2 : 3;
    
    switch (category) {
      case QuestCategory.health:
        return {'health': baseBoost * 2, 'discipline': baseBoost};
      case QuestCategory.productivity:
        return {'discipline': baseBoost * 2, 'productivity': baseBoost};
      case QuestCategory.learning:
        return {'knowledge': baseBoost * 2, 'discipline': baseBoost};
      case QuestCategory.social:
        return {'social': baseBoost * 2};
      case QuestCategory.creativity:
        return {'creativity': baseBoost * 2};
      case QuestCategory.mindfulness:
        return {'discipline': baseBoost, 'health': baseBoost};
    }
  }

  // Get quest by ID
  Quest? getQuestById(String questId) {
    try {
      return _quests.firstWhere((quest) => quest.id == questId);
    } catch (e) {
      return null;
    }
  }

  // Get quests by category
  List<Quest> getQuestsByCategory(QuestCategory category) {
    return _quests.where((quest) => quest.category == category).toList();
  }

  // Get completed quests
  List<Quest> getCompletedQuests() {
    return _quests.where((quest) => quest.isCompleted).toList();
  }

  // Get pending quests
  List<Quest> getPendingQuests() {
    return _quests.where((quest) => !quest.isCompleted).toList();
  }
}

