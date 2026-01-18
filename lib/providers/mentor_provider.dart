import 'package:flutter/foundation.dart';
import '../models/mentor.dart';
import '../models/user.dart';
import '../models/quest.dart';
import '../services/mentor_service.dart';

class MentorProvider with ChangeNotifier {
  final MentorService _mentorService = MentorService();
  List<MentorMessage> _messages = [];
  bool _isLoading = false;
  int _unreadCount = 0;

  List<MentorMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  int get unreadCount => _unreadCount;

  // Initialize mentor
  Future<void> initMentor() async {
    _isLoading = true;
    notifyListeners();

    try {
      await loadMessages();
      await updateUnreadCount();
    } catch (e) {
      print('Error initializing mentor: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load all messages
  Future<void> loadMessages() async {
    try {
      _messages = await _mentorService.getMentorMessages();
      notifyListeners();
    } catch (e) {
      print('Error loading mentor messages: $e');
    }
  }

  // Update unread count
  Future<void> updateUnreadCount() async {
    try {
      _unreadCount = await _mentorService.getUnreadMessageCount();
      notifyListeners();
    } catch (e) {
      print('Error updating unread count: $e');
    }
  }

  // Send daily interaction
  Future<MentorMessage?> sendDailyInteraction(User user) async {
    try {
      final message = await _mentorService.sendDailyInteraction(user);
      if (message != null) {
        _messages.insert(0, message);
        _unreadCount++;
        notifyListeners();
      }
      return message;
    } catch (e) {
      print('Error sending daily interaction: $e');
      return null;
    }
  }

  // Send quest completion message
  Future<void> sendQuestCompletionMessage(User user, Quest quest) async {
    try {
      final message = await _mentorService.generateQuestCompletionMessage(user, quest);
      await _mentorService.addMentorMessage(message);
      
      _messages.insert(0, message);
      _unreadCount++;
      notifyListeners();
    } catch (e) {
      print('Error sending quest completion message: $e');
    }
  }

  // Send level up message
  Future<void> sendLevelUpMessage(User user, int newLevel) async {
    try {
      final message = await _mentorService.generateLevelUpMessage(user, newLevel);
      await _mentorService.addMentorMessage(message);
      
      _messages.insert(0, message);
      _unreadCount++;
      notifyListeners();
    } catch (e) {
      print('Error sending level up message: $e');
    }
  }

  // Send streak encouragement
  Future<void> sendStreakEncouragement(User user) async {
    try {
      final message = await _mentorService.generateStreakEncouragement(user);
      await _mentorService.addMentorMessage(message);
      
      _messages.insert(0, message);
      _unreadCount++;
      notifyListeners();
    } catch (e) {
      print('Error sending streak encouragement: $e');
    }
  }

  // Send guidance message
  Future<void> sendGuidance(User user, List<Quest> recentQuests) async {
    try {
      final message = await _mentorService.generateGuidance(user, recentQuests);
      await _mentorService.addMentorMessage(message);
      
      _messages.insert(0, message);
      _unreadCount++;
      notifyListeners();
    } catch (e) {
      print('Error sending guidance: $e');
    }
  }

  // Send challenge message
  Future<void> sendChallenge(User user) async {
    try {
      final message = await _mentorService.generateChallenge(user);
      await _mentorService.addMentorMessage(message);
      
      _messages.insert(0, message);
      _unreadCount++;
      notifyListeners();
    } catch (e) {
      print('Error sending challenge: $e');
    }
  }

  // Send motivation message
  Future<void> sendMotivation(User user) async {
    try {
      final message = await _mentorService.generateMotivation(user);
      await _mentorService.addMentorMessage(message);
      
      _messages.insert(0, message);
      _unreadCount++;
      notifyListeners();
    } catch (e) {
      print('Error sending motivation: $e');
    }
  }

  // Mark message as read
  Future<void> markMessageAsRead(String messageId) async {
    try {
      final success = await _mentorService.markMessageAsRead(messageId);
      if (success) {
        final messageIndex = _messages.indexWhere((m) => m.id == messageId);
        if (messageIndex != -1 && !_messages[messageIndex].isRead) {
          _messages[messageIndex] = _messages[messageIndex].copyWith(isRead: true);
          _unreadCount = (_unreadCount - 1).clamp(0, _unreadCount);
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error marking message as read: $e');
    }
  }

  // Mark all messages as read
  Future<void> markAllMessagesAsRead() async {
    try {
      for (final message in _messages.where((m) => !m.isRead)) {
        await markMessageAsRead(message.id);
      }
    } catch (e) {
      print('Error marking all messages as read: $e');
    }
  }

  // Get mentor by user's mentor type
  Mentor getMentorForUser(User user) {
    final archetype = _getMentorArchetype(user.mentorType);
    return Mentor.getMentorByArchetype(archetype);
  }

  // Get latest message
  MentorMessage? getLatestMessage() {
    return _messages.isNotEmpty ? _messages.first : null;
  }

  // Get messages by type
  List<MentorMessage> getMessagesByType(MentorMessageType type) {
    return _messages.where((m) => m.type == type).toList();
  }

  // Get today's messages
  List<MentorMessage> getTodaysMessages() {
    final today = DateTime.now();
    return _messages.where((m) {
      return m.timestamp.year == today.year &&
             m.timestamp.month == today.month &&
             m.timestamp.day == today.day;
    }).toList();
  }

  // Helper method to convert mentor type string to archetype
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

  // Clear all messages (for testing or reset)
  Future<void> clearAllMessages() async {
    try {
      await _mentorService.saveMentorMessages([]);
      _messages.clear();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      print('Error clearing messages: $e');
    }
  }
}

