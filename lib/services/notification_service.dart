import 'package:flutter/foundation.dart';

class NotificationService extends ChangeNotifier {
  final List<AppNotification> _notifications = [];
  
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  
  void addNotification(String title, String message, {NotificationType type = NotificationType.info}) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
    );
    
    _notifications.insert(0, notification);
    
    // Keep only the last 50 notifications
    if (_notifications.length > 50) {
      _notifications.removeRange(50, _notifications.length);
    }
    
    notifyListeners();
  }
  
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }
  
  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }
  
  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }
  
  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }
  
  // Predefined notification types
  void notifyQuestCompleted(String questTitle, int xpGained) {
    addNotification(
      'Quest Completed! 🎉',
      'You completed "$questTitle" and earned $xpGained XP!',
      type: NotificationType.success,
    );
  }
  
  void notifyLevelUp(int newLevel) {
    addNotification(
      'Level Up! 🚀',
      'Congratulations! You reached level $newLevel!',
      type: NotificationType.success,
    );
  }
  
  void notifyAchievementUnlocked(String achievementTitle) {
    addNotification(
      'Achievement Unlocked! 🏆',
      'You unlocked "$achievementTitle"!',
      type: NotificationType.achievement,
    );
  }
  
  void notifyStreakMilestone(int streakDays) {
    addNotification(
      'Streak Milestone! 🔥',
      'Amazing! You\'re on a $streakDays-day streak!',
      type: NotificationType.success,
    );
  }
  
  void notifyMentorMessage(String mentorName, String message) {
    addNotification(
      'Message from $mentorName 💬',
      message,
      type: NotificationType.info,
    );
  }
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  
  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });
  
  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

enum NotificationType {
  info,
  success,
  warning,
  error,
  achievement,
}