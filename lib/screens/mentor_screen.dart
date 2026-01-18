import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mentor_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/quest_provider.dart';
import '../models/mentor.dart';

class MentorScreen extends StatefulWidget {
  const MentorScreen({Key? key}) : super(key: key);

  @override
  _MentorScreenState createState() => _MentorScreenState();
}

class _MentorScreenState extends State<MentorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mentorProvider = Provider.of<MentorProvider>(context, listen: false);
      mentorProvider.markAllMessagesAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Mentor'),
        backgroundColor: const Color(0xFF0B1021),
        actions: [
          Consumer<MentorProvider>(
            builder: (context, mentorProvider, child) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => mentorProvider.loadMessages(),
                tooltip: 'Refresh Messages',
              );
            },
          ),
        ],
      ),
      body: Consumer3<MentorProvider, AuthProvider, QuestProvider>(
        builder: (context, mentorProvider, authProvider, questProvider, child) {
          final user = authProvider.user;
          
          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF7C5CFF)),
            );
          }

          final mentor = mentorProvider.getMentorForUser(user);
          final messages = mentorProvider.messages;

          return Column(
            children: [
              // Mentor Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFF151B36),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      mentor.avatar,
                      style: const TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      mentor.name,
                      style: const TextStyle(
                        color: Color(0xFFE6E9FF),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mentor.description,
                      style: const TextStyle(
                        color: Color(0xFF9AA3C7),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          'Motivate Me',
                          Icons.psychology,
                          const Color(0xFF7C5CFF),
                          () => mentorProvider.sendMotivation(user),
                        ),
                        _buildActionButton(
                          'Challenge',
                          Icons.fitness_center,
                          const Color(0xFFFF6B6B),
                          () => mentorProvider.sendChallenge(user),
                        ),
                        _buildActionButton(
                          'Guidance',
                          Icons.lightbulb,
                          const Color(0xFFFFB800),
                          () => mentorProvider.sendGuidance(user, questProvider.quests),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Messages List
              Expanded(
                child: mentorProvider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Color(0xFF7C5CFF)),
                      )
                    : messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  mentor.avatar,
                                  style: const TextStyle(fontSize: 48),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No messages yet',
                                  style: TextStyle(
                                    color: Color(0xFFE6E9FF),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Your mentor will send you messages based on your progress',
                                  style: TextStyle(color: Color(0xFF9AA3C7)),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF7C5CFF),
                                  ),
                                  onPressed: () => mentorProvider.sendMotivation(user),
                                  icon: const Icon(Icons.psychology),
                                  label: const Text('Get Motivation'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              return MentorMessageCard(
                                message: message,
                                mentor: mentor,
                                onTap: () => mentorProvider.markMessageAsRead(message.id),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
          ),
          onPressed: onPressed,
          child: Icon(icon, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF9AA3C7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class MentorMessageCard extends StatelessWidget {
  final MentorMessage message;
  final Mentor mentor;
  final VoidCallback? onTap;

  const MentorMessageCard({
    Key? key,
    required this.message,
    required this.mentor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: message.isRead ? const Color(0xFF151B36) : const Color(0xFF1A2142),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    mentor.avatar,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              mentor.name,
                              style: const TextStyle(
                                color: Color(0xFFE6E9FF),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getMessageTypeColor(message.type).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _getMessageTypeColor(message.type)),
                              ),
                              child: Text(
                                _getMessageTypeLabel(message.type),
                                style: TextStyle(
                                  color: _getMessageTypeColor(message.type),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTimestamp(message.timestamp),
                          style: const TextStyle(
                            color: Color(0xFF9AA3C7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!message.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF7C5CFF),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                message.message,
                style: const TextStyle(
                  color: Color(0xFFE6E9FF),
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getMessageTypeColor(MentorMessageType type) {
    switch (type) {
      case MentorMessageType.greeting:
        return const Color(0xFF00E0A4);
      case MentorMessageType.motivation:
        return const Color(0xFF7C5CFF);
      case MentorMessageType.questCompletion:
        return const Color(0xFF00E0A4);
      case MentorMessageType.levelUp:
        return const Color(0xFFFFB800);
      case MentorMessageType.streakEncouragement:
        return const Color(0xFFFF6B6B);
      case MentorMessageType.guidance:
        return const Color(0xFFFFB800);
      case MentorMessageType.celebration:
        return const Color(0xFF00E0A4);
      case MentorMessageType.challenge:
        return const Color(0xFFFF6B6B);
    }
  }

  String _getMessageTypeLabel(MentorMessageType type) {
    switch (type) {
      case MentorMessageType.greeting:
        return 'GREETING';
      case MentorMessageType.motivation:
        return 'MOTIVATION';
      case MentorMessageType.questCompletion:
        return 'QUEST COMPLETE';
      case MentorMessageType.levelUp:
        return 'LEVEL UP';
      case MentorMessageType.streakEncouragement:
        return 'STREAK';
      case MentorMessageType.guidance:
        return 'GUIDANCE';
      case MentorMessageType.celebration:
        return 'CELEBRATION';
      case MentorMessageType.challenge:
        return 'CHALLENGE';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}

