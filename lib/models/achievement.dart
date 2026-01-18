enum AchievementType {
  questCompletion,
  streak,
  levelUp,
  statBoost,
  category,
  special,
}

enum AchievementRarity {
  common,
  rare,
  epic,
  legendary,
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementType type;
  final AchievementRarity rarity;
  final int targetValue;
  final Map<String, dynamic> criteria;
  final int xpReward;
  final DateTime? unlockedAt;
  final bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.rarity,
    required this.targetValue,
    required this.criteria,
    required this.xpReward,
    this.unlockedAt,
    this.isUnlocked = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'type': type.toString().split('.').last,
      'rarity': rarity.toString().split('.').last,
      'targetValue': targetValue,
      'criteria': criteria,
      'xpReward': xpReward,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'isUnlocked': isUnlocked,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      type: AchievementType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      rarity: AchievementRarity.values.firstWhere(
        (e) => e.toString().split('.').last == json['rarity'],
      ),
      targetValue: json['targetValue'],
      criteria: Map<String, dynamic>.from(json['criteria']),
      xpReward: json['xpReward'],
      unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt']) : null,
      isUnlocked: json['isUnlocked'] ?? false,
    );
  }

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    AchievementType? type,
    AchievementRarity? rarity,
    int? targetValue,
    Map<String, dynamic>? criteria,
    int? xpReward,
    DateTime? unlockedAt,
    bool? isUnlocked,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      rarity: rarity ?? this.rarity,
      targetValue: targetValue ?? this.targetValue,
      criteria: criteria ?? this.criteria,
      xpReward: xpReward ?? this.xpReward,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  String get rarityLabel {
    switch (rarity) {
      case AchievementRarity.common:
        return 'Common';
      case AchievementRarity.rare:
        return 'Rare';
      case AchievementRarity.epic:
        return 'Epic';
      case AchievementRarity.legendary:
        return 'Legendary';
    }
  }

  static List<Achievement> getDefaultAchievements() {
    return [
      // Quest Completion Achievements
      Achievement(
        id: 'first_quest',
        title: 'First Steps',
        description: 'Complete your first quest',
        icon: '🎯',
        type: AchievementType.questCompletion,
        rarity: AchievementRarity.common,
        targetValue: 1,
        criteria: {'questsCompleted': 1},
        xpReward: 50,
      ),
      Achievement(
        id: 'quest_master_10',
        title: 'Quest Apprentice',
        description: 'Complete 10 quests',
        icon: '⚔️',
        type: AchievementType.questCompletion,
        rarity: AchievementRarity.common,
        targetValue: 10,
        criteria: {'questsCompleted': 10},
        xpReward: 100,
      ),
      Achievement(
        id: 'quest_master_50',
        title: 'Quest Warrior',
        description: 'Complete 50 quests',
        icon: '🛡️',
        type: AchievementType.questCompletion,
        rarity: AchievementRarity.rare,
        targetValue: 50,
        criteria: {'questsCompleted': 50},
        xpReward: 250,
      ),
      Achievement(
        id: 'quest_master_100',
        title: 'Quest Legend',
        description: 'Complete 100 quests',
        icon: '👑',
        type: AchievementType.questCompletion,
        rarity: AchievementRarity.epic,
        targetValue: 100,
        criteria: {'questsCompleted': 100},
        xpReward: 500,
      ),

      // Streak Achievements
      Achievement(
        id: 'streak_3',
        title: 'Getting Started',
        description: 'Maintain a 3-day streak',
        icon: '🔥',
        type: AchievementType.streak,
        rarity: AchievementRarity.common,
        targetValue: 3,
        criteria: {'streak': 3},
        xpReward: 75,
      ),
      Achievement(
        id: 'streak_7',
        title: 'Week Warrior',
        description: 'Maintain a 7-day streak',
        icon: '🌟',
        type: AchievementType.streak,
        rarity: AchievementRarity.common,
        targetValue: 7,
        criteria: {'streak': 7},
        xpReward: 150,
      ),
      Achievement(
        id: 'streak_30',
        title: 'Monthly Master',
        description: 'Maintain a 30-day streak',
        icon: '💎',
        type: AchievementType.streak,
        rarity: AchievementRarity.rare,
        targetValue: 30,
        criteria: {'streak': 30},
        xpReward: 500,
      ),
      Achievement(
        id: 'streak_100',
        title: 'Consistency Champion',
        description: 'Maintain a 100-day streak',
        icon: '🏆',
        type: AchievementType.streak,
        rarity: AchievementRarity.legendary,
        targetValue: 100,
        criteria: {'streak': 100},
        xpReward: 1000,
      ),

      // Level Achievements
      Achievement(
        id: 'level_5',
        title: 'Rising Star',
        description: 'Reach Level 5',
        icon: '⭐',
        type: AchievementType.levelUp,
        rarity: AchievementRarity.common,
        targetValue: 5,
        criteria: {'level': 5},
        xpReward: 100,
      ),
      Achievement(
        id: 'level_10',
        title: 'Experienced Adventurer',
        description: 'Reach Level 10',
        icon: '🌠',
        type: AchievementType.levelUp,
        rarity: AchievementRarity.rare,
        targetValue: 10,
        criteria: {'level': 10},
        xpReward: 200,
      ),
      Achievement(
        id: 'level_25',
        title: 'Elite Warrior',
        description: 'Reach Level 25',
        icon: '💫',
        type: AchievementType.levelUp,
        rarity: AchievementRarity.epic,
        targetValue: 25,
        criteria: {'level': 25},
        xpReward: 500,
      ),

      // Category Achievements
      Achievement(
        id: 'health_master',
        title: 'Health Guardian',
        description: 'Complete 20 health quests',
        icon: '💪',
        type: AchievementType.category,
        rarity: AchievementRarity.rare,
        targetValue: 20,
        criteria: {'category': 'health', 'count': 20},
        xpReward: 300,
      ),
      Achievement(
        id: 'productivity_master',
        title: 'Productivity Guru',
        description: 'Complete 20 productivity quests',
        icon: '⚡',
        type: AchievementType.category,
        rarity: AchievementRarity.rare,
        targetValue: 20,
        criteria: {'category': 'productivity', 'count': 20},
        xpReward: 300,
      ),
      Achievement(
        id: 'learning_master',
        title: 'Knowledge Seeker',
        description: 'Complete 20 learning quests',
        icon: '📚',
        type: AchievementType.category,
        rarity: AchievementRarity.rare,
        targetValue: 20,
        criteria: {'category': 'learning', 'count': 20},
        xpReward: 300,
      ),

      // Special Achievements
      Achievement(
        id: 'perfect_day',
        title: 'Perfect Day',
        description: 'Complete all daily quests in one day',
        icon: '✨',
        type: AchievementType.special,
        rarity: AchievementRarity.epic,
        targetValue: 1,
        criteria: {'perfectDay': true},
        xpReward: 200,
      ),
      Achievement(
        id: 'early_bird',
        title: 'Early Bird',
        description: 'Complete a quest before 8 AM',
        icon: '🌅',
        type: AchievementType.special,
        rarity: AchievementRarity.common,
        targetValue: 1,
        criteria: {'earlyCompletion': true},
        xpReward: 50,
      ),
      Achievement(
        id: 'night_owl',
        title: 'Night Owl',
        description: 'Complete a quest after 10 PM',
        icon: '🦉',
        type: AchievementType.special,
        rarity: AchievementRarity.common,
        targetValue: 1,
        criteria: {'lateCompletion': true},
        xpReward: 50,
      ),
    ];
  }
}

class UserTitle {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementRarity rarity;
  final List<String> requiredAchievements;
  final bool isUnlocked;
  final bool isActive;

  UserTitle({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.rarity,
    required this.requiredAchievements,
    this.isUnlocked = false,
    this.isActive = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'rarity': rarity.toString().split('.').last,
      'requiredAchievements': requiredAchievements,
      'isUnlocked': isUnlocked,
      'isActive': isActive,
    };
  }

  factory UserTitle.fromJson(Map<String, dynamic> json) {
    return UserTitle(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      rarity: AchievementRarity.values.firstWhere(
        (e) => e.toString().split('.').last == json['rarity'],
      ),
      requiredAchievements: List<String>.from(json['requiredAchievements']),
      isUnlocked: json['isUnlocked'] ?? false,
      isActive: json['isActive'] ?? false,
    );
  }

  UserTitle copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    AchievementRarity? rarity,
    List<String>? requiredAchievements,
    bool? isUnlocked,
    bool? isActive,
  }) {
    return UserTitle(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      rarity: rarity ?? this.rarity,
      requiredAchievements: requiredAchievements ?? this.requiredAchievements,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isActive: isActive ?? this.isActive,
    );
  }

  static List<UserTitle> getDefaultTitles() {
    return [
      UserTitle(
        id: 'novice',
        title: 'Novice',
        description: 'Just starting the journey',
        icon: '🌱',
        rarity: AchievementRarity.common,
        requiredAchievements: [],
        isUnlocked: true,
        isActive: true,
      ),
      UserTitle(
        id: 'apprentice',
        title: 'Apprentice',
        description: 'Learning the ways',
        icon: '⚔️',
        rarity: AchievementRarity.common,
        requiredAchievements: ['first_quest', 'streak_3'],
      ),
      UserTitle(
        id: 'warrior',
        title: 'Warrior',
        description: 'Battle-tested and strong',
        icon: '🛡️',
        rarity: AchievementRarity.rare,
        requiredAchievements: ['quest_master_50', 'streak_7'],
      ),
      UserTitle(
        id: 'master',
        title: 'Master',
        description: 'Achieved mastery',
        icon: '👑',
        rarity: AchievementRarity.epic,
        requiredAchievements: ['quest_master_100', 'streak_30', 'level_10'],
      ),
      UserTitle(
        id: 'legend',
        title: 'Legend',
        description: 'A living legend',
        icon: '🏆',
        rarity: AchievementRarity.legendary,
        requiredAchievements: ['streak_100', 'level_25'],
      ),
    ];
  }
}

