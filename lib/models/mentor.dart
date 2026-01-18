enum MentorArchetype {
  theMentor,
  theWarrior,
  theScholar,
  theHealer,
  theExplorer,
}

class MentorMessage {
  final String id;
  final String message;
  final MentorMessageType type;
  final DateTime timestamp;
  final bool isRead;

  MentorMessage({
    required this.id,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory MentorMessage.fromJson(Map<String, dynamic> json) {
    return MentorMessage(
      id: json['id'],
      message: json['message'],
      type: MentorMessageType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
    );
  }

  MentorMessage copyWith({
    String? id,
    String? message,
    MentorMessageType? type,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return MentorMessage(
      id: id ?? this.id,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

enum MentorMessageType {
  greeting,
  motivation,
  questCompletion,
  levelUp,
  streakEncouragement,
  guidance,
  celebration,
  challenge,
}

class Mentor {
  final MentorArchetype archetype;
  final String name;
  final String description;
  final String avatar;
  final List<String> greetings;
  final List<String> motivations;
  final List<String> celebrations;
  final List<String> challenges;

  Mentor({
    required this.archetype,
    required this.name,
    required this.description,
    required this.avatar,
    required this.greetings,
    required this.motivations,
    required this.celebrations,
    required this.challenges,
  });

  static Mentor getMentorByArchetype(MentorArchetype archetype) {
    switch (archetype) {
      case MentorArchetype.theMentor:
        return Mentor(
          archetype: MentorArchetype.theMentor,
          name: 'The Mentor',
          description: 'A wise guide who helps you discover your inner strength',
          avatar: '🧙‍♂️',
          greetings: [
            'Welcome back, young adventurer. Ready to continue your journey?',
            'Another day, another opportunity to grow stronger.',
            'I sense great potential in you today. Let\'s unlock it together.',
            'The path to greatness begins with a single step. Shall we take it?',
          ],
          motivations: [
            'Remember, every master was once a beginner. Keep pushing forward.',
            'Your potential is limitless. Don\'t let doubt hold you back.',
            'The strongest steel is forged in the hottest fire. Embrace the challenge.',
            'Progress, not perfection, is the goal. You\'re doing great.',
          ],
          celebrations: [
            'Excellent work! You\'re becoming stronger with each quest completed.',
            'I knew you had it in you! Your dedication is truly inspiring.',
            'Well done, adventurer. You\'ve earned this victory.',
            'Your growth is remarkable. Keep up this fantastic momentum!',
          ],
          challenges: [
            'I believe you\'re ready for something more challenging. Are you?',
            'Your comfort zone is expanding. Time to push it further.',
            'Great power comes with great responsibility. Are you ready?',
            'The next level awaits. Will you rise to meet it?',
          ],
        );

      case MentorArchetype.theWarrior:
        return Mentor(
          archetype: MentorArchetype.theWarrior,
          name: 'The Warrior',
          description: 'A fierce champion who pushes you to overcome any obstacle',
          avatar: '⚔️',
          greetings: [
            'Rise, warrior! Today we conquer new challenges!',
            'The battlefield of self-improvement awaits. Are you ready?',
            'Another day to prove your strength. Let\'s dominate!',
            'Victory favors the prepared. Let\'s gear up for success!',
          ],
          motivations: [
            'Warriors don\'t quit. They adapt, overcome, and conquer!',
            'Pain is temporary, but victory is eternal. Push through!',
            'Every setback is a setup for a comeback. Fight on!',
            'Champions are made in the moments when they want to quit but don\'t.',
          ],
          celebrations: [
            'VICTORY! You\'ve proven your warrior spirit once again!',
            'Outstanding! You fought through and emerged victorious!',
            'That\'s the spirit of a true champion! Well fought!',
            'Another battle won! Your strength grows with each victory!',
          ],
          challenges: [
            'Think you can handle a real challenge? Let\'s find out!',
            'Time to separate the warriors from the wannabes. You in?',
            'Your next opponent is tougher. But so are you. Ready?',
            'Legends are born from facing impossible odds. Your time is now!',
          ],
        );

      case MentorArchetype.theScholar:
        return Mentor(
          archetype: MentorArchetype.theScholar,
          name: 'The Scholar',
          description: 'A learned sage who values knowledge and continuous learning',
          avatar: '📚',
          greetings: [
            'Good day, fellow seeker of knowledge. What shall we learn today?',
            'The library of life has infinite books. Which one calls to you?',
            'Curiosity is the engine of achievement. Let\'s fuel yours today.',
            'Every day is a chance to expand your understanding. Shall we begin?',
          ],
          motivations: [
            'Knowledge is power, and you\'re becoming more powerful each day.',
            'The wise know that learning never ends. You\'re on the right path.',
            'Each question you ask makes you wiser. Keep questioning.',
            'Understanding comes through practice. You\'re building it steadily.',
          ],
          celebrations: [
            'Brilliant! Your dedication to growth is truly admirable.',
            'Excellent progress! Your mind is expanding beautifully.',
            'Well reasoned and well executed! You\'re becoming quite wise.',
            'Splendid work! Knowledge gained is never knowledge wasted.',
          ],
          challenges: [
            'I have a puzzle that might intrigue your growing intellect.',
            'Your mind is ready for more complex challenges. Interested?',
            'There\'s a deeper level of understanding waiting. Shall we explore?',
            'Advanced concepts await those brave enough to tackle them.',
          ],
        );

      case MentorArchetype.theHealer:
        return Mentor(
          archetype: MentorArchetype.theHealer,
          name: 'The Healer',
          description: 'A compassionate guide focused on wellness and balance',
          avatar: '🌿',
          greetings: [
            'Peace be with you, dear soul. How can we nurture your growth today?',
            'Welcome back. Let\'s tend to your well-being together.',
            'Another opportunity to heal, grow, and flourish. I\'m here for you.',
            'Your journey to wellness continues. I\'m honored to guide you.',
          ],
          motivations: [
            'Healing happens one small step at a time. You\'re doing beautifully.',
            'Be gentle with yourself. Growth requires patience and self-compassion.',
            'Your well-being matters. Every effort you make is valuable.',
            'Balance is key to lasting change. You\'re finding yours.',
          ],
          celebrations: [
            'Your progress brings me such joy. You\'re truly flourishing!',
            'Beautiful work! You\'re nurturing positive change within yourself.',
            'I\'m so proud of your commitment to your well-being.',
            'Wonderful! You\'re creating harmony in your life.',
          ],
          challenges: [
            'Your spirit is ready for deeper healing. Shall we explore together?',
            'There\'s more balance to be found. Are you open to the journey?',
            'Your growth has prepared you for greater wellness. Ready?',
            'A new level of self-care awaits. Will you embrace it?',
          ],
        );

      case MentorArchetype.theExplorer:
        return Mentor(
          archetype: MentorArchetype.theExplorer,
          name: 'The Explorer',
          description: 'An adventurous spirit who encourages discovery and creativity',
          avatar: '🗺️',
          greetings: [
            'Adventure awaits, fellow explorer! What new territories shall we map?',
            'The horizon calls to us. Ready for another expedition?',
            'Every day is a new adventure waiting to unfold. Let\'s discover!',
            'The unknown beckons. Shall we answer its call together?',
          ],
          motivations: [
            'Every journey begins with curiosity. Yours is leading you far!',
            'Uncharted territories await those brave enough to explore.',
            'Discovery requires courage. You have it in abundance.',
            'The best adventures happen outside your comfort zone.',
          ],
          celebrations: [
            'Incredible discovery! You\'ve mapped new territory in your growth!',
            'What an adventure! You\'ve conquered unknown challenges!',
            'Brilliant exploration! You\'ve found treasures within yourself!',
            'Outstanding journey! You\'ve expanded your world beautifully!',
          ],
          challenges: [
            'I\'ve spotted uncharted territory perfect for your next expedition.',
            'There are mysteries waiting to be solved. Care to investigate?',
            'Your explorer\'s spirit is ready for a grand adventure. Interested?',
            'New frontiers await those bold enough to venture forth.',
          ],
        );
    }
  }

  String getRandomMessage(List<String> messages) {
    if (messages.isEmpty) return 'Keep going, you\'re doing great!';
    final random = DateTime.now().millisecondsSinceEpoch % messages.length;
    return messages[random];
  }

  String getGreeting() => getRandomMessage(greetings);
  String getMotivation() => getRandomMessage(motivations);
  String getCelebration() => getRandomMessage(celebrations);
  String getChallenge() => getRandomMessage(challenges);
}

