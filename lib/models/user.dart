class User {
  final String id;
  final String email;
  final String username;
  final int level;
  final int xp;
  final int streak;
  final String mentorType;
  final Map<String, int> stats;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.level = 1,
    this.xp = 0,
    this.streak = 0,
    this.mentorType = 'The Mentor',
    Map<String, int>? stats,
  }) : stats = stats ?? {'discipline': 0, 'health': 0, 'creativity': 0, 'knowledge': 0};

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'level': level,
      'xp': xp,
      'streak': streak,
      'mentorType': mentorType,
      'stats': stats,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
      streak: json['streak'] ?? 0,
      mentorType: json['mentorType'] ?? 'The Mentor',
      stats: Map<String, int>.from(json['stats'] ?? {}),
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? username,
    int? level,
    int? xp,
    int? streak,
    String? mentorType,
    Map<String, int>? stats,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      mentorType: mentorType ?? this.mentorType,
      stats: stats ?? this.stats,
    );
  }
}

