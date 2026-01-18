import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_openai/dart_openai.dart';
import '../models/mentor.dart';
import '../models/user.dart';
import '../models/quest.dart';

class MentorService {
  static const String _messagesKey = 'mentor_messages';
  static const String _lastInteractionKey = 'last_mentor_interaction';
  static const String _openaiApiKeyKey = 'openai_api_key';
  
  bool _openaiInitialized = false;

  // Initialize OpenAI with API key from SharedPreferences
  Future<bool> initializeOpenAI() async {
    if (_openaiInitialized) return true;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final apiKey = prefs.getString(_openaiApiKeyKey);
      
      if (apiKey != null && apiKey.isNotEmpty) {
        OpenAI.apiKey = apiKey;
        _openaiInitialized = true;
        print('OpenAI initialized successfully');
        return true;
      }
      
      print('No OpenAI API key found - using fallback messages');
      return false;
    } catch (e) {
      print('Error initializing OpenAI: $e');
      return false;
    }
  }

  // Save OpenAI API key
  Future<bool> saveOpenAIApiKey(String apiKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_openaiApiKeyKey, apiKey);
      OpenAI.apiKey = apiKey;
      _openaiInitialized = true;
      return true;
    } catch (e) {
      print('Error saving OpenAI API key: $e');
      return false;
    }
  }

  // Get mentor messages
  Future<List<MentorMessage>> getMentorMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString(_messagesKey) ?? '[]';
      final messagesList = List<Map<String, dynamic>>.from(jsonDecode(messagesJson));
      
      return messagesList.map((json) => MentorMessage.fromJson(json)).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      print('Error getting mentor messages: $e');
      return [];
    }
  }

  // Save mentor messages
  Future<bool> saveMentorMessages(List<MentorMessage> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = jsonEncode(messages.map((m) => m.toJson()).toList());
      await prefs.setString(_messagesKey, messagesJson);
      return true;
    } catch (e) {
      print('Error saving mentor messages: $e');
      return false;
    }
  }

  // Add a new mentor message
  Future<bool> addMentorMessage(MentorMessage message) async {
    final messages = await getMentorMessages();
    messages.insert(0, message);
    
    // Keep only the last 50 messages to avoid storage bloat
    if (messages.length > 50) {
      messages.removeRange(50, messages.length);
    }
    
    return await saveMentorMessages(messages);
  }

  // Mark message as read
  Future<bool> markMessageAsRead(String messageId) async {
    final messages = await getMentorMessages();
    final messageIndex = messages.indexWhere((m) => m.id == messageId);
    
    if (messageIndex == -1) return false;
    
    messages[messageIndex] = messages[messageIndex].copyWith(isRead: true);
    return await saveMentorMessages(messages);
  }

  // Get unread message count
  Future<int> getUnreadMessageCount() async {
    final messages = await getMentorMessages();
    return messages.where((m) => !m.isRead).length;
  }

  // Generate AI-powered message using OpenAI
  Future<String?> _generateAIMessage(String prompt, User user) async {
    await initializeOpenAI();
    
    if (!_openaiInitialized) return null;

    try {
      final mentor = Mentor.getMentorByArchetype(_getMentorArchetype(user.mentorType));
      final systemPrompt = '''
You are ${mentor.name}, a ${mentor.archetype.toString().split('.').last} mentor in the LifeQuest app.
Personality: ${mentor.description}

User Profile:
- Level: ${user.level}
- Current Streak: ${user.streak} days
- Health: ${user.stats['health']}/100
- Productivity: ${user.stats['productivity']}/100
- Learning: ${user.stats['learning']}/100
- Mindfulness: ${user.stats['mindfulness']}/100
- Creativity: ${user.stats['creativity']}/100
- Social: ${user.stats['social']}/100

Your responses should be:
1. Brief (1-3 sentences)2. Personalized to the user's current level and stats
3. Encouraging and motivational
4. In character with your personality
5. Focused on actionable advice when relevant

Keep it conversational and inspiring!
''';

      final response = await OpenAI.instance.chat.create(
        model: "gpt-4o-mini",
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(systemPrompt)],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt)],
          ),
        ],
        temperature: 0.8,
        maxTokens: 150,
      );

      return response.choices.first.message.content?.first.text;
    } catch (e) {
      print('Error generating AI message: $e');
      return null;
    }
  }

  // Generate greeting message
  Future<MentorMessage> generateGreeting(User user) async {
    final mentor = Mentor.getMentorByArchetype(_getMentorArchetype(user.mentorType));
    
    // Try AI generation first
    final aiMessage = await _generateAIMessage(
      'Generate a warm greeting for the user who just logged in today. Welcome them back and acknowledge their progress.',
      user,
    );
    
    final message = aiMessage ?? mentor.getGreeting();
    
    return MentorMessage(
      id: 'greeting_${DateTime.now().millisecondsSinceEpoch}',
      message: message,
      type: MentorMessageType.greeting,
      timestamp: DateTime.now(),
    );
  }

  // Generate motivation message
  Future<MentorMessage> generateMotivation(User user) async {
    final mentor = Mentor.getMentorByArchetype(_getMentorArchetype(user.mentorType));
    
    // Try AI generation first
    final aiMessage = await _generateAIMessage(
      'Generate a motivational message to inspire the user to work on their goals today. Be specific and personal.',
      user,
    );
    
    final message = aiMessage ?? mentor.getMotivation();
    
    return MentorMessage(
      id: 'motivation_${DateTime.now().millisecondsSinceEpoch}',
      message: message,
      type: MentorMessageType.motivation,
      timestamp: DateTime.now(),
    );
  }

  // Generate quest completion message
  Future<MentorMessage> generateQuestCompletionMessage(User user, Quest quest) async {
    final mentor = Mentor.getMentorByArchetype(_getMentorArchetype(user.mentorType));
    
    // Try AI generation first
    final aiMessage = await _generateAIMessage(
      'The user just completed a quest: "${quest.title}" in the ${quest.category.toString().split('.').last} category. '
      'Celebrate their achievement with enthusiasm!',
      user,
    );
    
    final celebration = mentor.getCelebration();
    final contextualMessage = aiMessage ?? _getContextualQuestMessage(quest, celebration);
    
    return MentorMessage(
      id: 'quest_completion_${DateTime.now().millisecondsSinceEpoch}',
      message: contextualMessage,
      type: MentorMessageType.questCompletion,
      timestamp: DateTime.now(),
    );
  }

  // Generate level up message
  Future<MentorMessage> generateLevelUpMessage(User user, int newLevel) async {
    final mentor = Mentor.getMentorByArchetype(_getMentorArchetype(user.mentorType));
    
    // Try AI generation first
    final aiMessage = await _generateAIMessage(
      'The user just reached Level $newLevel! Celebrate this major milestone with excitement and acknowledge their dedication.',
      user,
    );
    
    final celebration = mentor.getCelebration();
    final levelUpMessage = aiMessage ?? 'Congratulations! You\'ve reached Level $newLevel! $celebration';
    
    return MentorMessage(
      id: 'level_up_${DateTime.now().millisecondsSinceEpoch}',
      message: levelUpMessage,
      type: MentorMessageType.levelUp,
      timestamp: DateTime.now(),
    );
  }

  // Generate streak encouragement
  Future<MentorMessage> generateStreakEncouragement(User user) async {
    final mentor = Mentor.getMentorByArchetype(_getMentorArchetype(user.mentorType));
    
    // Try AI generation first
    String aiPrompt;
    if (user.streak == 0) {
      aiPrompt = 'The user hasn\'t started a streak yet. Encourage them to begin their journey today!';
    } else if (user.streak < 7) {
      aiPrompt = 'The user has a ${user.streak}-day streak. Encourage them to keep building momentum!';
    } else if (user.streak < 30) {
      aiPrompt = 'The user has an impressive ${user.streak}-day streak! Celebrate their dedication and encourage continued consistency.';
    } else {
      aiPrompt = 'The user has an incredible ${user.streak}-day streak! This is legendary dedication. Celebrate enthusiastically!';
    }
    
    final aiMessage = await _generateAIMessage(aiPrompt, user);
    
    String message;
    if (aiMessage != null) {
      message = aiMessage;
    } else {
      if (user.streak == 0) {
        message = 'Every journey begins with a single step. Today could be the start of an amazing streak!';
      } else if (user.streak < 7) {
        message = 'You\'re building momentum! ${user.streak} days strong. Keep the streak alive!';
      } else if (user.streak < 30) {
        message = 'Incredible dedication! ${user.streak} days in a row shows real commitment. ${mentor.getMotivation()}';
      } else {
        message = 'Absolutely legendary! ${user.streak} days of consistency is truly inspiring! ${mentor.getCelebration()}';
      }
    }
    
    return MentorMessage(
      id: 'streak_${DateTime.now().millisecondsSinceEpoch}',
      message: message,
      type: MentorMessageType.streakEncouragement,
      timestamp: DateTime.now(),
    );
  }

  // Generate guidance based on user progress
  Future<MentorMessage> generateGuidance(User user, List<Quest> recentQuests) async {
    final mentor = Mentor.getMentorByArchetype(_getMentorArchetype(user.mentorType));
    
    // Analyze user's quest completion patterns
    final completedQuests = recentQuests.where((q) => q.isCompleted).toList();
    final categoryCount = <QuestCategory, int>{};
    
    for (final quest in completedQuests) {
      categoryCount[quest.category] = (categoryCount[quest.category] ?? 0) + 1;
    }
    
    // Build context for AI
    String questAnalysis = 'Recent quest completions:\n';
    if (categoryCount.isEmpty) {
      questAnalysis += 'No quests completed recently';
    } else {
      categoryCount.forEach((category, count) {
        questAnalysis += '- ${category.toString().split('.').last}: $count quests\n';
      });
    }
    
    // Try AI generation first
    final aiMessage = await _generateAIMessage(
      'Analyze the user\'s recent progress and provide personalized guidance:\n\n$questAnalysis\n\n'
      'Give specific advice on which areas to focus on or praise their balanced approach.',
      user,
    );
    
    final guidance = aiMessage ?? _getPersonalizedGuidance(user, recentQuests, mentor);
    
    return MentorMessage(
      id: 'guidance_${DateTime.now().millisecondsSinceEpoch}',
      message: guidance,
      type: MentorMessageType.guidance,
      timestamp: DateTime.now(),
    );
  }

  // Generate challenge message
  Future<MentorMessage> generateChallenge(User user) async {
    final mentor = Mentor.getMentorByArchetype(_getMentorArchetype(user.mentorType));
    
    // Try AI generation first
    final aiMessage = await _generateAIMessage(
      'Create a personalized challenge for the user to push them outside their comfort zone. '
      'Make it specific and achievable within a day.',
      user,
    );
    
    final challenge = aiMessage ?? mentor.getChallenge();
    
    return MentorMessage(
      id: 'challenge_${DateTime.now().millisecondsSinceEpoch}',
      message: challenge,
      type: MentorMessageType.challenge,
      timestamp: DateTime.now(),
    );
  }
  // Check if daily interaction is needed
  Future<bool> shouldSendDailyMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final lastInteraction = prefs.getString(_lastInteractionKey);
    
    if (lastInteraction == null) return true;
    
    final lastDate = DateTime.parse(lastInteraction);
    final today = DateTime.now();
    
    return lastDate.day != today.day ||
           lastDate.month != today.month ||
           lastDate.year != today.year;
  }

  // Send daily mentor interaction
  Future<MentorMessage?> sendDailyInteraction(User user) async {
    if (!await shouldSendDailyMessage()) return null;
    
    final random = Random();
    final messageType = random.nextInt(3);
    
    MentorMessage message;
    switch (messageType) {
      case 0:
        message = await generateGreeting(user);
        break;
      case 1:
        message = await generateMotivation(user);
        break;
      default:
        message = await generateStreakEncouragement(user);
        break;
    }
    
    await addMentorMessage(message);
    
    // Update last interaction date
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastInteractionKey, DateTime.now().toIso8601String());
    
    return message;
  }

  // Helper methods
  MentorArchetype _getMentorArchetype(String mentorType) {
    switch (mentorType.toLowerCase()) {
      case 'the warrior':
        return MentorArchetype.theWarrior;
      case 'the scholar':
        return MentorArchetype.theScholar;
      case 'the healer':
        return MentorArchetype.theHealer;
      case 'the explorer':
        return MentorArchetype.theExplorer;
      default:
        return MentorArchetype.theMentor;
    }
  }

  String _getContextualQuestMessage(Quest quest, String baseCelebration) {
    final categoryMessages = {
      QuestCategory.health: 'Your body is your temple, and you\'re taking great care of it!',
      QuestCategory.productivity: 'Productivity is the bridge between dreams and reality. Well built!',
      QuestCategory.learning: 'Knowledge is the only treasure that grows when shared. Keep learning!',
      QuestCategory.mindfulness: 'Inner peace is the foundation of all achievement. Beautiful work!',
      QuestCategory.creativity: 'Creativity is intelligence having fun. You\'re brilliant!',
      QuestCategory.social: 'Connection is what gives life meaning. You\'re building something beautiful!',
    };
    
    final contextMessage = categoryMessages[quest.category] ?? baseCelebration;
    return '$baseCelebration $contextMessage';
  }

  String _getPersonalizedGuidance(User user, List<Quest> recentQuests, Mentor mentor) {
    // Analyze user's quest completion patterns
    final completedQuests = recentQuests.where((q) => q.isCompleted).toList();
    final categoryCount = <QuestCategory, int>{};
    
    for (final quest in completedQuests) {
      categoryCount[quest.category] = (categoryCount[quest.category] ?? 0) + 1;
    }
    
    // Find the most and least active categories
    if (categoryCount.isEmpty) {
      return 'I notice you haven\'t completed many quests lately. ${mentor.getMotivation()} Remember, small steps lead to big changes!';
    }
    
    final mostActive = categoryCount.entries.reduce((a, b) => a.value > b.value ? a : b);
    final leastActive = QuestCategory.values.where((cat) => (categoryCount[cat] ?? 0) == 0).toList();
    
    if (leastActive.isNotEmpty) {
      final category = leastActive.first;
      final categoryName = category.toString().split('.').last;
      return 'I see you\'re excelling in ${mostActive.key.toString().split('.').last}! Consider exploring $categoryName quests to create more balance in your growth.';
    }
    
    return 'Your progress across all areas is impressive! ${mentor.getMotivation()} Keep up this well-rounded approach to growth.';
  }
}
