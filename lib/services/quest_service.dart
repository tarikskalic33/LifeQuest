import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quest.dart';

class QuestService {
  static const String _questsKey = 'user_quests';
  static const String _lastGeneratedKey = 'last_generated_date';

  // Predefined quest templates
  static const Map<QuestCategory, List<Map<String, dynamic>>> _questTemplates = {
    QuestCategory.health: [
      {
        'title': 'Drink 8 glasses of water',
        'description': 'Stay hydrated throughout the day',
        'difficulty': QuestDifficulty.easy,
        'xp': 10,
        'stats': {'health': 2},
      },
      {
        'title': 'Take a 20-minute walk',
        'description': 'Get some fresh air and light exercise',
        'difficulty': QuestDifficulty.easy,
        'xp': 15,
        'stats': {'health': 3, 'discipline': 1},
      },
      {
        'title': 'Do 20 push-ups',
        'description': 'Build upper body strength',
        'difficulty': QuestDifficulty.medium,
        'xp': 20,
        'stats': {'health': 4, 'discipline': 2},
      },
      {
        'title': 'Complete a 30-minute workout',
        'description': 'Full body exercise session',
        'difficulty': QuestDifficulty.hard,
        'xp': 30,
        'stats': {'health': 6, 'discipline': 3},
      },
    ],
    QuestCategory.productivity: [
      {
        'title': 'Organize your workspace',
        'description': 'Clean and organize your desk area',
        'difficulty': QuestDifficulty.easy,
        'xp': 12,
        'stats': {'discipline': 2, 'creativity': 1},
      },
      {
        'title': 'Complete 3 important tasks',
        'description': 'Focus on your top priorities',
        'difficulty': QuestDifficulty.medium,
        'xp': 25,
        'stats': {'discipline': 4, 'productivity': 3},
      },
      {
        'title': 'Work for 2 hours without distractions',
        'description': 'Deep focus session',
        'difficulty': QuestDifficulty.hard,
        'xp': 35,
        'stats': {'discipline': 5, 'productivity': 4},
      },
    ],
    QuestCategory.learning: [
      {
        'title': 'Read for 15 minutes',
        'description': 'Expand your knowledge',
        'difficulty': QuestDifficulty.easy,
        'xp': 10,
        'stats': {'knowledge': 3},
      },
      {
        'title': 'Watch an educational video',
        'description': 'Learn something new',
        'difficulty': QuestDifficulty.easy,
        'xp': 8,
        'stats': {'knowledge': 2},
      },
      {
        'title': 'Practice a new skill for 30 minutes',
        'description': 'Develop your abilities',
        'difficulty': QuestDifficulty.medium,
        'xp': 20,
        'stats': {'knowledge': 4, 'discipline': 2},
      },
    ],
    QuestCategory.mindfulness: [
      {
        'title': 'Meditate for 10 minutes',
        'description': 'Practice mindfulness and relaxation',
        'difficulty': QuestDifficulty.easy,
        'xp': 15,
        'stats': {'discipline': 2, 'health': 1},
      },
      {
        'title': 'Write 3 things you\'re grateful for',
        'description': 'Practice gratitude',
        'difficulty': QuestDifficulty.easy,
        'xp': 8,
        'stats': {'discipline': 1, 'creativity': 1},
      },
      {
        'title': 'Practice deep breathing for 5 minutes',
        'description': 'Reduce stress and anxiety',
        'difficulty': QuestDifficulty.easy,
        'xp': 10,
        'stats': {'health': 2, 'discipline': 1},
      },
    ],
    QuestCategory.creativity: [
      {
        'title': 'Draw or sketch for 15 minutes',
        'description': 'Express your creativity',
        'difficulty': QuestDifficulty.easy,
        'xp': 12,
        'stats': {'creativity': 3},
      },
      {
        'title': 'Write in a journal',
        'description': 'Reflect on your day',
        'difficulty': QuestDifficulty.easy,
        'xp': 10,
        'stats': {'creativity': 2, 'discipline': 1},
      },
      {
        'title': 'Try a new recipe',
        'description': 'Experiment in the kitchen',
        'difficulty': QuestDifficulty.medium,
        'xp': 18,
        'stats': {'creativity': 4, 'health': 1},
      },
    ],
    QuestCategory.social: [
      {
        'title': 'Call a friend or family member',
        'description': 'Connect with someone you care about',
        'difficulty': QuestDifficulty.easy,
        'xp': 12,
        'stats': {'social': 3},
      },
      {
        'title': 'Send a thoughtful message',
        'description': 'Reach out to someone',
        'difficulty': QuestDifficulty.easy,
        'xp': 8,
        'stats': {'social': 2},
      },
      {
        'title': 'Help someone with a task',
        'description': 'Be kind and helpful',
        'difficulty': QuestDifficulty.medium,
        'xp': 20,
        'stats': {'social': 4, 'discipline': 1},
      },
    ],
  };

  // Generate daily quests
  Future<List<Quest>> generateDailyQuests({int count = 3}) async {
    final random = Random();
    final quests = <Quest>[];
    final usedTemplates = <Map<String, dynamic>>[];

    // Get all available templates
    final allTemplates = <Map<String, dynamic>>[];
    for (final category in QuestCategory.values) {
      final templates = _questTemplates[category] ?? [];
      for (final template in templates) {
        allTemplates.add({
          ...template,
          'category': category,
        });
      }
    }

    // Generate unique quests
    for (int i = 0; i < count && usedTemplates.length < allTemplates.length; i++) {
      Map<String, dynamic> template;
      do {
        template = allTemplates[random.nextInt(allTemplates.length)];
      } while (usedTemplates.contains(template));

      usedTemplates.add(template);

      final quest = Quest(
        id: 'daily_${DateTime.now().millisecondsSinceEpoch}_$i',
        title: template['title'],
        description: template['description'],
        type: QuestType.daily,
        category: template['category'],
        difficulty: template['difficulty'],
        xpReward: template['xp'],
        statBoosts: Map<String, int>.from(template['stats']),
        createdAt: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 1)),
      );

      quests.add(quest);
    }

    return quests;
  }

  // Get user's quests
  Future<List<Quest>> getUserQuests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final questsJson = prefs.getString(_questsKey) ?? '[]';
      final questsList = List<Map<String, dynamic>>.from(jsonDecode(questsJson));
      
      return questsList.map((json) => Quest.fromJson(json)).toList();
    } catch (e) {
      print('Error getting user quests: $e');
      return [];
    }
  }

  // Save user's quests
  Future<bool> saveUserQuests(List<Quest> quests) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final questsJson = jsonEncode(quests.map((q) => q.toJson()).toList());
      await prefs.setString(_questsKey, questsJson);
      return true;
    } catch (e) {
      print('Error saving user quests: $e');
      return false;
    }
  }

  // Get today's quests
  Future<List<Quest>> getTodaysQuests() async {
    final allQuests = await getUserQuests();
    final today = DateTime.now();
    
    return allQuests.where((quest) {
      if (quest.type != QuestType.daily) return false;
      if (quest.dueDate == null) return true;
      
      return quest.dueDate!.year == today.year &&
             quest.dueDate!.month == today.month &&
             quest.dueDate!.day >= today.day;
    }).toList();
  }

  // Complete a quest
  Future<bool> completeQuest(String questId) async {
    final quests = await getUserQuests();
    final questIndex = quests.indexWhere((q) => q.id == questId);
    
    if (questIndex == -1) return false;

    quests[questIndex] = quests[questIndex].copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
    );

    return await saveUserQuests(quests);
  }

  // Undo quest completion
  Future<bool> undoQuestCompletion(String questId) async {
    final quests = await getUserQuests();
    final questIndex = quests.indexWhere((q) => q.id == questId);
    
    if (questIndex == -1) return false;

    quests[questIndex] = quests[questIndex].copyWith(
      isCompleted: false,
      completedAt: null,
    );

    return await saveUserQuests(quests);
  }

  // Check if daily quests need to be generated
  Future<bool> shouldGenerateDailyQuests() async {
    final prefs = await SharedPreferences.getInstance();
    final lastGenerated = prefs.getString(_lastGeneratedKey);
    
    if (lastGenerated == null) return true;
    
    final lastDate = DateTime.parse(lastGenerated);
    final today = DateTime.now();
    
    return lastDate.day != today.day ||
           lastDate.month != today.month ||
           lastDate.year != today.year;
  }

  // Generate and save daily quests if needed
  Future<List<Quest>> ensureDailyQuests() async {
    if (await shouldGenerateDailyQuests()) {
      final newQuests = await generateDailyQuests();
      final existingQuests = await getUserQuests();
      
      // Remove old daily quests
      final nonDailyQuests = existingQuests.where((q) => q.type != QuestType.daily).toList();
      
      // Add new daily quests
      final allQuests = [...nonDailyQuests, ...newQuests];
      
      await saveUserQuests(allQuests);
      
      // Update last generated date
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastGeneratedKey, DateTime.now().toIso8601String());
      
      return newQuests;
    }
    
    return await getTodaysQuests();
  }

  // Add a custom quest
  Future<bool> addCustomQuest(Quest quest) async {
    final quests = await getUserQuests();
    quests.add(quest);
    return await saveUserQuests(quests);
  }

  // Remove a quest
  Future<bool> removeQuest(String questId) async {
    final quests = await getUserQuests();
    quests.removeWhere((q) => q.id == questId);
    return await saveUserQuests(quests);
  }
}

