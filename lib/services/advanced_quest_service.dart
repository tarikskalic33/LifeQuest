import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quest.dart';
import '../models/user.dart';

/// Advanced Quest Service with new features and optimizations
class AdvancedQuestService {
  static const String _questsKey = 'user_quests';
  static const String _questHistoryKey = 'quest_history';
  static const String _questChainsKey = 'quest_chains';
  
  // FEATURE 1: Extended quest categories with new content
  static const Map<String, List<Map<String, dynamic>>> extendedQuestTemplates = {
    'health': [
      {'title': 'Drink 8 glasses of water', 'description': 'Stay hydrated throughout the day', 'difficulty': 'easy', 'baseXP': 10, 'stats': {'health': 3, 'discipline': 1}},
      {'title': 'Take a 30-minute walk', 'description': 'Get some fresh air and exercise', 'difficulty': 'medium', 'baseXP': 20, 'stats': {'health': 4, 'discipline': 2}},
      {'title': 'Complete a full workout', 'description': 'Strength or cardio training session', 'difficulty': 'hard', 'baseXP': 30, 'stats': {'health': 5, 'discipline': 3}},
      {'title': 'Prepare a healthy meal', 'description': 'Cook something nutritious from scratch', 'difficulty': 'medium', 'baseXP': 18, 'stats': {'health': 3, 'creativity': 2}},
      {'title': 'Get 7+ hours of sleep', 'description': 'Prioritize quality rest and recovery', 'difficulty': 'easy', 'baseXP': 15, 'stats': {'health': 4, 'discipline': 2}},
    ],
    'productivity': [
      {'title': 'Organize your workspace', 'description': 'Clean and declutter your work area', 'difficulty': 'easy', 'baseXP': 12, 'stats': {'discipline': 3, 'creativity': 1}},
      {'title': 'Complete 3 important tasks', 'description': 'Focus on high-priority items', 'difficulty': 'medium', 'baseXP': 22, 'stats': {'discipline': 4, 'knowledge': 1}},
      {'title': '2 hours of deep focus work', 'description': 'Uninterrupted concentration time', 'difficulty': 'hard', 'baseXP': 32, 'stats': {'discipline': 5, 'knowledge': 2}},
      {'title': 'Plan tomorrow\'s schedule', 'description': 'Set up your day for success', 'difficulty': 'easy', 'baseXP': 8, 'stats': {'discipline': 2, 'knowledge': 1}},
      {'title': 'Learn a productivity technique', 'description': 'Research and try a new method', 'difficulty': 'medium', 'baseXP': 20, 'stats': {'knowledge': 3, 'discipline': 2}},
    ],
    'learning': [
      {'title': 'Read for 30 minutes', 'description': 'Expand your knowledge through reading', 'difficulty': 'easy', 'baseXP': 8, 'stats': {'knowledge': 3, 'discipline': 1}},
      {'title': 'Watch an educational video', 'description': 'Learn something new from online content', 'difficulty': 'easy', 'baseXP': 10, 'stats': {'knowledge': 2, 'creativity': 1}},
      {'title': 'Practice a new skill', 'description': 'Spend 1 hour developing abilities', 'difficulty': 'hard', 'baseXP': 35, 'stats': {'knowledge': 4, 'discipline': 3}},
      {'title': 'Take detailed notes', 'description': 'Document something you\'re learning', 'difficulty': 'medium', 'baseXP': 15, 'stats': {'knowledge': 2, 'discipline': 2}},
      {'title': 'Teach someone else', 'description': 'Share knowledge with others', 'difficulty': 'hard', 'baseXP': 28, 'stats': {'knowledge': 3, 'social': 3}},
    ],
    'mindfulness': [
      {'title': 'Meditate for 10 minutes', 'description': 'Practice mindfulness and presence', 'difficulty': 'medium', 'baseXP': 18, 'stats': {'discipline': 3, 'health': 2}},
      {'title': 'Write 3 things you\'re grateful for', 'description': 'Practice gratitude journaling', 'difficulty': 'easy', 'baseXP': 12, 'stats': {'discipline': 2, 'health': 2}},
      {'title': 'Practice deep breathing', 'description': '5 minutes of focused breathing', 'difficulty': 'easy', 'baseXP': 10, 'stats': {'health': 3, 'discipline': 1}},
      {'title': 'Digital detox for 2 hours', 'description': 'Take a break from screens', 'difficulty': 'hard', 'baseXP': 25, 'stats': {'discipline': 4, 'health': 2}},
      {'title': 'Mindful eating practice', 'description': 'Eat one meal without distractions', 'difficulty': 'medium', 'baseXP': 16, 'stats': {'discipline': 3, 'health': 1}},
    ],
    'creativity': [
      {'title': 'Draw or sketch for 20 minutes', 'description': 'Express yourself through art', 'difficulty': 'medium', 'baseXP': 20, 'stats': {'creativity': 4, 'discipline': 1}},
      {'title': 'Write creatively', 'description': 'Journal, poetry, or storytelling', 'difficulty': 'medium', 'baseXP': 18, 'stats': {'creativity': 3, 'knowledge': 2}},
      {'title': 'Try a new recipe', 'description': 'Experiment in the kitchen', 'difficulty': 'medium', 'baseXP': 22, 'stats': {'creativity': 3, 'health': 2}},
      {'title': 'Create something with your hands', 'description': 'Craft, build, or make something physical', 'difficulty': 'hard', 'baseXP': 30, 'stats': {'creativity': 5, 'discipline': 2}},
      {'title': 'Listen to new music', 'description': 'Explore different genres or artists', 'difficulty': 'easy', 'baseXP': 8, 'stats': {'creativity': 2, 'knowledge': 1}},
    ],
    'social': [
      {'title': 'Call a friend or family member', 'description': 'Connect with someone important', 'difficulty': 'easy', 'baseXP': 15, 'stats': {'social': 3, 'health': 1}},
      {'title': 'Send a thoughtful message', 'description': 'Reach out to brighten someone\'s day', 'difficulty': 'easy', 'baseXP': 10, 'stats': {'social': 2, 'creativity': 1}},
      {'title': 'Help someone with a task', 'description': 'Offer assistance to others', 'difficulty': 'medium', 'baseXP': 25, 'stats': {'social': 4, 'discipline': 2}},
      {'title': 'Have a meaningful conversation', 'description': 'Deep discussion with someone', 'difficulty': 'medium', 'baseXP': 20, 'stats': {'social': 3, 'knowledge': 2}},
      {'title': 'Practice active listening', 'description': 'Focus fully on understanding others', 'difficulty': 'hard', 'baseXP': 28, 'stats': {'social': 4, 'discipline': 3}},
    ],
    // FEATURE 2: New categories
    'financial': [
      {'title': 'Track daily expenses', 'description': 'Record all purchases and expenses', 'difficulty': 'easy', 'baseXP': 10, 'stats': {'discipline': 2, 'knowledge': 1}},
      {'title': 'Create weekly budget', 'description': 'Plan your spending for the week', 'difficulty': 'medium', 'baseXP': 20, 'stats': {'discipline': 3, 'knowledge': 2}},
      {'title': 'Research investment opportunity', 'description': 'Learn about a new investment option', 'difficulty': 'hard', 'baseXP': 30, 'stats': {'knowledge': 4, 'discipline': 2}},
      {'title': 'Review financial goals', 'description': 'Assess progress toward money goals', 'difficulty': 'medium', 'baseXP': 18, 'stats': {'knowledge': 2, 'discipline': 3}},
    ],
    'environment': [
      {'title': 'Use reusable items today', 'description': 'Avoid single-use plastics', 'difficulty': 'easy', 'baseXP': 8, 'stats': {'discipline': 2, 'health': 1}},
      {'title': 'Start or tend to composting', 'description': 'Reduce food waste naturally', 'difficulty': 'medium', 'baseXP': 22, 'stats': {'creativity': 3, 'discipline': 2}},
      {'title': 'Plant something green', 'description': 'Seeds, garden work, or houseplants', 'difficulty': 'medium', 'baseXP': 25, 'stats': {'creativity': 2, 'health': 2, 'discipline': 1}},
      {'title': 'Walk or bike instead of driving', 'description': 'Choose eco-friendly transport', 'difficulty': 'medium', 'baseXP': 20, 'stats': {'health': 3, 'discipline': 2}},
    ],
    'career': [
      {'title': 'Update professional profile', 'description': 'LinkedIn, resume, or portfolio', 'difficulty': 'easy', 'baseXP': 12, 'stats': {'discipline': 2, 'knowledge': 1}},
      {'title': 'Learn job-relevant skill', 'description': 'Practice career-advancing abilities', 'difficulty': 'medium', 'baseXP': 24, 'stats': {'knowledge': 3, 'discipline': 2}},
      {'title': 'Network professionally', 'description': 'Connect with industry contacts', 'difficulty': 'hard', 'baseXP': 32, 'stats': {'social': 3, 'knowledge': 2, 'discipline': 1}},
      {'title': 'Set career goal', 'description': 'Define next professional objective', 'difficulty': 'medium', 'baseXP': 18, 'stats': {'knowledge': 2, 'discipline': 3}},
    ],
  };
  
  // FEATURE 3: Seasonal quest generation
  static Map<String, dynamic>? generateSeasonalQuest() {
    final now = DateTime.now();
    final month = now.month;
    
    // Spring quests (March-May)
    if (month >= 3 && month <= 5) {
      final springQuests = [
        {'title': 'Spring cleaning challenge', 'description': 'Organize one area of your space', 'difficulty': 'medium', 'baseXP': 18, 'stats': {'discipline': 3, 'health': 1}, 'season': 'spring'},
        {'title': 'Start a new outdoor hobby', 'description': 'Try gardening, hiking, or outdoor sports', 'difficulty': 'hard', 'baseXP': 25, 'stats': {'health': 3, 'creativity': 2}, 'season': 'spring'},
        {'title': 'Plan summer goals', 'description': 'Set intentions for the warmer months', 'difficulty': 'easy', 'baseXP': 12, 'stats': {'knowledge': 2, 'discipline': 2}, 'season': 'spring'},
      ];
      return springQuests[Random().nextInt(springQuests.length)];
    }
    
    // Summer quests (June-August)
    if (month >= 6 && month <= 8) {
      final summerQuests = [
        {'title': 'Spend 30 min outdoors', 'description': 'Enjoy natural light and fresh air', 'difficulty': 'easy', 'baseXP': 12, 'stats': {'health': 3, 'discipline': 1}, 'season': 'summer'},
        {'title': 'Try water-based activity', 'description': 'Swimming, water sports, or beach time', 'difficulty': 'medium', 'baseXP': 20, 'stats': {'health': 4, 'creativity': 1}, 'season': 'summer'},
        {'title': 'Have a picnic or BBQ', 'description': 'Enjoy outdoor dining with others', 'difficulty': 'easy', 'baseXP': 15, 'stats': {'social': 3, 'creativity': 2}, 'season': 'summer'},
      ];
      return summerQuests[Random().nextInt(summerQuests.length)];
    }
    
    // Fall quests (September-November)
    if (month >= 9 && month <= 11) {
      final fallQuests = [
        {'title': 'Reflect on year\'s progress', 'description': 'Journal about accomplishments', 'difficulty': 'easy', 'baseXP': 15, 'stats': {'creativity': 2, 'knowledge': 2}, 'season': 'fall'},
        {'title': 'Try seasonal cooking', 'description': 'Cook with autumn ingredients', 'difficulty': 'medium', 'baseXP': 22, 'stats': {'creativity': 3, 'health': 2}, 'season': 'fall'},
        {'title': 'Prepare for winter', 'description': 'Organize, plan, or winterize something', 'difficulty': 'medium', 'baseXP': 18, 'stats': {'discipline': 3, 'knowledge': 1}, 'season': 'fall'},
      ];
      return fallQuests[Random().nextInt(fallQuests.length)];
    }
    
    // Winter quests (December-February)
    final winterQuests = [
      {'title': 'Practice gratitude', 'description': 'Write about things you appreciate', 'difficulty': 'easy', 'baseXP': 12, 'stats': {'discipline': 2, 'health': 2}, 'season': 'winter'},
      {'title': 'Do something kind', 'description': 'Help or support someone today', 'difficulty': 'easy', 'baseXP': 15, 'stats': {'social': 3, 'discipline': 1}, 'season': 'winter'},
      {'title': 'Learn something cozy', 'description': 'Indoor skill or hobby development', 'difficulty': 'medium', 'baseXP': 20, 'stats': {'knowledge': 3, 'creativity': 2}, 'season': 'winter'},
    ];
    return winterQuests[Random().nextInt(winterQuests.length)];
  }
  
  // FEATURE 4: Adaptive difficulty based on user performance
  static String calculateOptimalDifficulty(User user, List<Map<String, dynamic>> completionHistory) {
    final level = user.level;
    final streak = user.streak;
    final totalXP = user.xp;
    
    // Calculate recent completion rate (last 14 days)
    final twoWeeksAgo = DateTime.now().subtract(Duration(days: 14));
    final recentQuests = completionHistory.where((quest) {
      final completedAt = DateTime.tryParse(quest['completedAt'] ?? '');
      return completedAt != null && completedAt.isAfter(twoWeeksAgo);
    }).toList();
    
    final completionRate = recentQuests.isEmpty ? 0.5 : 
        recentQuests.where((q) => q['isCompleted'] == true).length / recentQuests.length;
    
    // Calculate engagement score (0-100)
    double engagementScore = 0.0;
    engagementScore += (level * 2).clamp(0, 30); // Level contribution
    engagementScore += (streak * 1.5).clamp(0, 25); // Streak contribution
    engagementScore += (totalXP / 50).clamp(0, 25); // XP contribution
    engagementScore += (completionRate * 20); // Recent performance
    
    // Determine optimal difficulty distribution
    if (engagementScore < 25) {
      return _selectDifficulty([70, 25, 5]); // 70% easy, 25% medium, 5% hard
    } else if (engagementScore < 50) {
      return _selectDifficulty([50, 35, 15]); // Balanced for growing users
    } else if (engagementScore < 75) {
      return _selectDifficulty([30, 50, 20]); // Standard distribution
    } else {
      return _selectDifficulty([15, 40, 45]); // Challenge for power users
    }
  }
  
  static String _selectDifficulty(List<int> weights) {
    final random = Random();
    final total = weights.reduce((a, b) => a + b);
    final randomValue = random.nextInt(total);
    
    int cumulative = 0;
    for (int i = 0; i < weights.length; i++) {
      cumulative += weights[i];
      if (randomValue < cumulative) {
        switch (i) {
          case 0: return 'easy';
          case 1: return 'medium';
          case 2: return 'hard';
        }
      }
    }
    return 'medium'; // fallback
  }
  
  // FEATURE 5: Enhanced daily quest generation with all new features
  Future<List<Quest>> generateEnhancedDailyQuests(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      // Load completion history for adaptive difficulty
      final historyJson = prefs.getString(_questHistoryKey) ?? '[]';
      final completionHistory = List<Map<String, dynamic>>.from(jsonDecode(historyJson));
      
      final quests = <Quest>[];
      final usedCategories = <String>[];
      final allCategories = extendedQuestTemplates.keys.toList()..shuffle();
      
      // Generate 3 regular quests with adaptive difficulty
      for (int i = 0; i < 3; i++) {
        final difficulty = calculateOptimalDifficulty(user, completionHistory);
        
        // Find available category
        final availableCategories = allCategories.where((cat) => !usedCategories.contains(cat)).toList();
        if (availableCategories.isEmpty) break;
        
        final category = availableCategories[Random().nextInt(availableCategories.length)];
        usedCategories.add(category);
        
        final categoryQuests = extendedQuestTemplates[category]!
            .where((q) => q['difficulty'] == difficulty)
            .toList();
        
        if (categoryQuests.isNotEmpty) {
          final template = categoryQuests[Random().nextInt(categoryQuests.length)];
          quests.add(_createQuestFromTemplate(template, category));
        }
      }
      
      // Add seasonal quest if applicable
      final seasonalQuest = generateSeasonalQuest();
      if (seasonalQuest != null && quests.length < 4) {
        quests.add(_createQuestFromTemplate(seasonalQuest, 'seasonal'));
      }
      
      return quests;
    } catch (e) {
      print('Error generating enhanced daily quests: $e');
      return [];
    }
  }
  
  Quest _createQuestFromTemplate(Map<String, dynamic> template, String category) {
    final random = Random();
    final baseXP = template['baseXP'] ?? 10;
    final variableXP = random.nextInt(8); // 0-7 bonus XP
    final finalXP = baseXP + variableXP;
    
    return Quest(
      id: 'quest_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(1000)}',
      title: template['title'] ?? '',
      description: template['description'] ?? '',
      category: category,
      difficulty: template['difficulty'] ?? 'medium',
      xpReward: finalXP,
      statBoosts: Map<String, int>.from(template['stats'] ?? {}),
      isCompleted: false,
      createdAt: DateTime.now(),
    );
  }
  
  // Enhanced quest completion with better tracking
  Future<bool> completeQuestEnhanced(String questId, User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final questsKey = 'quests_$today';
      
      final questsJson = prefs.getString(questsKey) ?? '[]';
      final quests = List<Map<String, dynamic>>.from(jsonDecode(questsJson));
      
      final questIndex = quests.indexWhere((q) => q['id'] == questId);
      if (questIndex == -1) return false;
      
      final quest = quests[questIndex];
      if (quest['isCompleted'] == true) return false; // Already completed
      
      // Mark as completed
      quest['isCompleted'] = true;
      quest['completedAt'] = DateTime.now().toIso8601String();
      quests[questIndex] = quest;
      
      // Save updated quests
      await prefs.setString(questsKey, jsonEncode(quests));
      
      // Add to completion history
      final historyJson = prefs.getString(_questHistoryKey) ?? '[]';
      final history = List<Map<String, dynamic>>.from(jsonDecode(historyJson));
      history.add(quest);
      
      // Keep last 100 completed quests for performance
      if (history.length > 100) {
        history.removeRange(0, history.length - 100);
      }
      
      await prefs.setString(_questHistoryKey, jsonEncode(history));
      
      return true;
    } catch (e) {
      print('Error completing quest: $e');
      return false;
    }
  }
  
  // Get user's completion statistics
  Future<Map<String, dynamic>> getCompletionStats(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_questHistoryKey) ?? '[]';
      final history = List<Map<String, dynamic>>.from(jsonDecode(historyJson));
      
      final completedQuests = history.where((q) => q['isCompleted'] == true).toList();
      final categoryStats = <String, int>{};
      final difficultyStats = <String, int>{};
      
      for (final quest in completedQuests) {
        final category = quest['category'] ?? 'unknown';
        final difficulty = quest['difficulty'] ?? 'medium';
        
        categoryStats[category] = (categoryStats[category] ?? 0) + 1;
        difficultyStats[difficulty] = (difficultyStats[difficulty] ?? 0) + 1;
      }
      
      return {
        'totalCompleted': completedQuests.length,
        'categoryBreakdown': categoryStats,
        'difficultyBreakdown': difficultyStats,
        'averageXPPerQuest': completedQuests.isEmpty ? 0 : 
            completedQuests.map((q) => q['xpReward'] ?? 0).reduce((a, b) => a + b) / completedQuests.length,
      };
    } catch (e) {
      print('Error getting completion stats: $e');
      return {};
    }
  }
}