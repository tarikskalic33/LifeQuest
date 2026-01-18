import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quest_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/mentor_provider.dart';
import '../providers/achievement_provider.dart';
import '../models/quest.dart';

class QuestsScreen extends StatelessWidget {
  const QuestsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Quests'),
        backgroundColor: const Color(0xFF0B1021),
        actions: [
          Consumer<QuestProvider>(
            builder: (context, questProvider, child) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: questProvider.isLoading 
                    ? null 
                    : () => questProvider.generateNewDailyQuests(),
                tooltip: 'Generate New Quests',
              );
            },
          ),
        ],
      ),
      body: Consumer2<QuestProvider, AuthProvider>(
        builder: (context, questProvider, authProvider, child) {
          if (questProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF7C5CFF)),
            );
          }

          final todaysQuests = questProvider.todaysQuests;

          if (todaysQuests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: Color(0xFF9AA3C7),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No quests available',
                    style: TextStyle(
                      color: Color(0xFFE6E9FF),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap the refresh button to generate new quests',
                    style: TextStyle(color: Color(0xFF9AA3C7)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C5CFF),
                    ),
                    onPressed: () => questProvider.generateNewDailyQuests(),
                    icon: const Icon(Icons.add),
                    label: const Text('Generate Quests'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Progress Summary
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF151B36),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF7C5CFF), width: 1),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${questProvider.todaysCompletedCount}/${todaysQuests.length}',
                              style: const TextStyle(
                                color: Color(0xFFE6E9FF),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Quests Completed',
                              style: TextStyle(color: Color(0xFF9AA3C7)),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '+${questProvider.todaysXP} XP',
                              style: const TextStyle(
                                color: Color(0xFF00E0A4),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Earned Today',
                              style: TextStyle(color: Color(0xFF9AA3C7)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: todaysQuests.isEmpty ? 0 : questProvider.todaysCompletedCount / todaysQuests.length,
                      backgroundColor: const Color(0xFF0B1021),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C5CFF)),
                    ),
                  ],
                ),
              ),
              // Quest List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: todaysQuests.length,
                  itemBuilder: (context, index) {
                    final quest = todaysQuests[index];
                    return QuestCard(
                      quest: quest,
                      onToggle: () async {
                        if (quest.isCompleted) {
                          await questProvider.undoQuestCompletion(quest.id);
                        } else {
                          final success = await questProvider.completeQuest(quest.id);
                          if (success) {
                            // Add XP to user
                            final oldLevel = authProvider.user!.level;
                            await authProvider.addXP(quest.xpReward);
                            final newLevel = authProvider.user!.level;
                            
                            // Update user stats
                            final currentStats = authProvider.user?.stats ?? {};
                            final newStats = Map<String, int>.from(currentStats);
                            quest.statBoosts.forEach((stat, boost) {
                              newStats[stat] = (newStats[stat] ?? 0) + boost;
                            });
                            await authProvider.updateStats(newStats);

                            // Send mentor messages
                            final mentorProvider = Provider.of<MentorProvider>(context, listen: false);
                            await mentorProvider.sendQuestCompletionMessage(authProvider.user!, quest);
                            
                            // Check for achievements
                            final achievementProvider = Provider.of<AchievementProvider>(context, listen: false);
                            final newAchievements = await achievementProvider.checkAchievements(
                              authProvider.user!, 
                              questProvider.getCompletedQuests(),
                            );
                            
                            // Send level up message if leveled up
                            if (newLevel > oldLevel) {
                              await mentorProvider.sendLevelUpMessage(authProvider.user!, newLevel);
                            }

                            // Show completion feedback
                            String message = 'Quest completed! +${quest.xpReward} XP';
                            if (newAchievements.isNotEmpty) {
                              message += '\n🏆 ${newAchievements.length} achievement(s) unlocked!';
                            }
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(message),
                                backgroundColor: const Color(0xFF00E0A4),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        }
                      },
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
}

class QuestCard extends StatelessWidget {
  final Quest quest;
  final VoidCallback onToggle;

  const QuestCard({
    Key? key,
    required this.quest,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF151B36),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  quest.categoryIcon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quest.title,
                        style: TextStyle(
                          color: const Color(0xFFE6E9FF),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: quest.isCompleted 
                              ? TextDecoration.lineThrough 
                              : TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        quest.description,
                        style: TextStyle(
                          color: const Color(0xFF9AA3C7),
                          fontSize: 14,
                          decoration: quest.isCompleted 
                              ? TextDecoration.lineThrough 
                              : TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(quest.category).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getDifficultyColor(quest.difficulty)),
                  ),
                  child: Text(
                    quest.difficultyLabel,
                    style: TextStyle(
                      color: _getDifficultyColor(quest.difficulty),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '+${quest.xpReward} XP',
                  style: const TextStyle(
                    color: Color(0xFF00E0A4),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: quest.isCompleted 
                        ? const Color(0xFF9AA3C7) 
                        : const Color(0xFF7C5CFF),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: onToggle,
                  child: Text(quest.isCompleted ? 'Undo' : 'Complete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(QuestDifficulty difficulty) {
    switch (difficulty) {
      case QuestDifficulty.easy:
        return const Color(0xFF00E0A4);
      case QuestDifficulty.medium:
        return const Color(0xFFFFB800);
      case QuestDifficulty.hard:
        return const Color(0xFFFF6B6B);
    }
  }

  Color _getCategoryColor(QuestCategory category) {
    switch (category) {
      case QuestCategory.health:
        return const Color(0xFF00E0A4);
      case QuestCategory.productivity:
        return const Color(0xFF7C5CFF);
      case QuestCategory.learning:
        return const Color(0xFFFFB800);
      case QuestCategory.mindfulness:
        return const Color(0xFF9AA3C7);
      case QuestCategory.creativity:
        return const Color(0xFFFF6B6B);
      case QuestCategory.social:
        return const Color(0xFF00D4FF);
    }
  }
}

