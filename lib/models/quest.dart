enum QuestType {
  daily,
  weekly,
  custom,
}

enum QuestCategory {
  health,
  productivity,
  learning,
  social,
  creativity,
  mindfulness,
}

enum QuestDifficulty {
  easy,
  medium,
  hard,
}

class Quest {
  final String id;
  final String title;
  final String description;
  final QuestType type;
  final QuestCategory category;
  final QuestDifficulty difficulty;
  final int xpReward;
  final Map<String, int> statBoosts;
  final DateTime createdAt;
  final DateTime? dueDate;
  bool isCompleted;
  DateTime? completedAt;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.difficulty,
    required this.xpReward,
    required this.statBoosts,
    required this.createdAt,
    this.dueDate,
    this.isCompleted = false,
    this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'category': category.toString().split('.').last,
      'difficulty': difficulty.toString().split('.').last,
      'xpReward': xpReward,
      'statBoosts': statBoosts,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: QuestType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      category: QuestCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
      ),
      difficulty: QuestDifficulty.values.firstWhere(
        (e) => e.toString().split('.').last == json['difficulty'],
      ),
      xpReward: json['xpReward'],
      statBoosts: Map<String, int>.from(json['statBoosts']),
      createdAt: DateTime.parse(json['createdAt']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    );
  }

  Quest copyWith({
    String? id,
    String? title,
    String? description,
    QuestType? type,
    QuestCategory? category,
    QuestDifficulty? difficulty,
    int? xpReward,
    Map<String, int>? statBoosts,
    DateTime? createdAt,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return Quest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      xpReward: xpReward ?? this.xpReward,
      statBoosts: statBoosts ?? this.statBoosts,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  String get categoryIcon {
    switch (category) {
      case QuestCategory.health:
        return '💪';
      case QuestCategory.productivity:
        return '⚡';
      case QuestCategory.learning:
        return '📚';
      case QuestCategory.social:
        return '👥';
      case QuestCategory.creativity:
        return '🎨';
      case QuestCategory.mindfulness:
        return '🧘';
    }
  }

  String get difficultyLabel {
    switch (difficulty) {
      case QuestDifficulty.easy:
        return 'Easy';
      case QuestDifficulty.medium:
        return 'Medium';
      case QuestDifficulty.hard:
        return 'Hard';
    }
  }
}

