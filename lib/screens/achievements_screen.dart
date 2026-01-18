import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/achievement_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/quest_provider.dart';
import '../models/achievement.dart';
import '../models/user.dart';
import '../models/quest.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  _AchievementsScreenState createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: const Color(0xFF0B1021),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF7C5CFF),
          labelColor: const Color(0xFFE6E9FF),
          unselectedLabelColor: const Color(0xFF9AA3C7),
          tabs: const [
            Tab(text: 'Achievements'),
            Tab(text: 'Titles'),
            Tab(text: 'Progress'),
          ],
        ),
      ),
      body: Consumer3<AchievementProvider, AuthProvider, QuestProvider>(
        builder: (context, achievementProvider, authProvider, questProvider, child) {
          if (achievementProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF7C5CFF)),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildAchievementsTab(achievementProvider, authProvider, questProvider),
              _buildTitlesTab(achievementProvider),
              _buildProgressTab(achievementProvider, authProvider, questProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAchievementsTab(AchievementProvider achievementProvider, AuthProvider authProvider, QuestProvider questProvider) {
    final achievementsByRarity = achievementProvider.achievementsByRarity;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Card
          Card(
            color: const Color(0xFF151B36),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${achievementProvider.unlockedAchievements.length}/${achievementProvider.achievements.length}',
                            style: const TextStyle(
                              color: Color(0xFFE6E9FF),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Achievements Unlocked',
                            style: TextStyle(color: Color(0xFF9AA3C7)),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '+${achievementProvider.totalAchievementXP} XP',
                            style: const TextStyle(
                              color: Color(0xFF00E0A4),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'From Achievements',
                            style: TextStyle(color: Color(0xFF9AA3C7)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: achievementProvider.completionPercentage,
                    backgroundColor: const Color(0xFF0B1021),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C5CFF)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Achievements by Rarity
          ...AchievementRarity.values.map((rarity) {
            final achievements = achievementsByRarity[rarity] ?? [];
            if (achievements.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _getRarityColor(rarity),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _getRarityLabel(rarity),
                        style: TextStyle(
                          color: _getRarityColor(rarity),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${achievements.where((a) => a.isUnlocked).length}/${achievements.length})',
                        style: const TextStyle(
                          color: Color(0xFF9AA3C7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                ...achievements.map((achievement) => AchievementCard(
                  achievement: achievement,
                  user: authProvider.user!,
                  completedQuests: questProvider.getCompletedQuests(),
                )).toList(),
                const SizedBox(height: 16),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTitlesTab(AchievementProvider achievementProvider) {
    final unlockedTitles = achievementProvider.unlockedTitles;
    final lockedTitles = achievementProvider.titles.where((t) => !t.isUnlocked).toList();
    final activeTitle = achievementProvider.activeTitle;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Title Card
          if (activeTitle != null) ...[
            const Text(
              'Active Title',
              style: TextStyle(
                color: Color(0xFFE6E9FF),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TitleCard(
              title: activeTitle,
              isActive: true,
              onTap: null,
            ),
            const SizedBox(height: 24),
          ],

          // Unlocked Titles
          if (unlockedTitles.isNotEmpty) ...[
            const Text(
              'Unlocked Titles',
              style: TextStyle(
                color: Color(0xFFE6E9FF),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...unlockedTitles.where((t) => !t.isActive).map((title) => TitleCard(
              title: title,
              isActive: false,
              onTap: () async {
                final success = await achievementProvider.setActiveTitle(title.id);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Title "${title.title}" activated!'),
                      backgroundColor: const Color(0xFF00E0A4),
                    ),
                  );
                }
              },
            )).toList(),
            const SizedBox(height: 24),
          ],

          // Locked Titles
          if (lockedTitles.isNotEmpty) ...[
            const Text(
              'Locked Titles',
              style: TextStyle(
                color: Color(0xFFE6E9FF),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...lockedTitles.map((title) => TitleCard(
              title: title,
              isActive: false,
              onTap: null,
            )).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressTab(AchievementProvider achievementProvider, AuthProvider authProvider, QuestProvider questProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Achievements
          if (achievementProvider.recentAchievements.isNotEmpty) ...[
            const Text(
              'Recent Achievements',
              style: TextStyle(
                color: Color(0xFFE6E9FF),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...achievementProvider.recentAchievements.map((achievement) => AchievementCard(
              achievement: achievement,
              user: authProvider.user!,
              completedQuests: questProvider.getCompletedQuests(),
            )).toList(),
            const SizedBox(height: 24),
          ],

          // Next Achievements
          const Text(
            'Next to Unlock',
            style: TextStyle(
              color: Color(0xFFE6E9FF),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<Achievement>>(
            future: achievementProvider.getNextAchievements(
              authProvider.user!,
              questProvider.getCompletedQuests(),
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF7C5CFF)));
              }

              final nextAchievements = snapshot.data ?? [];
              if (nextAchievements.isEmpty) {
                return const Text(
                  'All achievements unlocked!',
                  style: TextStyle(color: Color(0xFF9AA3C7)),
                );
              }

              return Column(
                children: nextAchievements.map((achievement) => AchievementCard(
                  achievement: achievement,
                  user: authProvider.user!,
                  completedQuests: questProvider.getCompletedQuests(),
                  showProgress: true,
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getRarityColor(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return const Color(0xFF9AA3C7);
      case AchievementRarity.rare:
        return const Color(0xFF00E0A4);
      case AchievementRarity.epic:
        return const Color(0xFF7C5CFF);
      case AchievementRarity.legendary:
        return const Color(0xFFFFB800);
    }
  }

  String _getRarityLabel(AchievementRarity rarity) {
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
}

class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final User user;
  final List<Quest> completedQuests;
  final bool showProgress;

  const AchievementCard({
    Key? key,
    required this.achievement,
    required this.user,
    required this.completedQuests,
    this.showProgress = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: achievement.isUnlocked ? const Color(0xFF1A2142) : const Color(0xFF151B36),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  achievement.icon,
                  style: TextStyle(
                    fontSize: 32,
                    color: achievement.isUnlocked ? null : Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              achievement.title,
                              style: TextStyle(
                                color: achievement.isUnlocked ? const Color(0xFFE6E9FF) : const Color(0xFF9AA3C7),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getRarityColor(achievement.rarity).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _getRarityColor(achievement.rarity)),
                            ),
                            child: Text(
                              achievement.rarityLabel.toUpperCase(),
                              style: TextStyle(
                                color: _getRarityColor(achievement.rarity),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        achievement.description,
                        style: const TextStyle(
                          color: Color(0xFF9AA3C7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '+${achievement.xpReward} XP',
                            style: const TextStyle(
                              color: Color(0xFF00E0A4),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (achievement.isUnlocked && achievement.unlockedAt != null) ...[
                            const SizedBox(width: 16),
                            Text(
                              'Unlocked ${_formatDate(achievement.unlockedAt!)}',
                              style: const TextStyle(
                                color: Color(0xFF9AA3C7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (showProgress && !achievement.isUnlocked) ...[
              const SizedBox(height: 12),
              FutureBuilder<double>(
                future: Provider.of<AchievementProvider>(context, listen: false)
                    .getAchievementProgress(achievement.id, user, completedQuests),
                builder: (context, snapshot) {
                  final progress = snapshot.data ?? 0.0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Progress',
                            style: TextStyle(
                              color: Color(0xFF9AA3C7),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${(progress * 100).round()}%',
                            style: const TextStyle(
                              color: Color(0xFF9AA3C7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        backgroundColor: const Color(0xFF0B1021),
                        valueColor: AlwaysStoppedAnimation<Color>(_getRarityColor(achievement.rarity)),
                      ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getRarityColor(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return const Color(0xFF9AA3C7);
      case AchievementRarity.rare:
        return const Color(0xFF00E0A4);
      case AchievementRarity.epic:
        return const Color(0xFF7C5CFF);
      case AchievementRarity.legendary:
        return const Color(0xFFFFB800);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class TitleCard extends StatelessWidget {
  final UserTitle title;
  final bool isActive;
  final VoidCallback? onTap;

  const TitleCard({
    Key? key,
    required this.title,
    required this.isActive,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isActive ? const Color(0xFF1A2142) : const Color(0xFF151B36),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: title.isUnlocked ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                title.icon,
                style: TextStyle(
                  fontSize: 32,
                  color: title.isUnlocked ? null : Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title.title,
                            style: TextStyle(
                              color: title.isUnlocked ? const Color(0xFFE6E9FF) : const Color(0xFF9AA3C7),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E0A4).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF00E0A4)),
                            ),
                            child: const Text(
                              'ACTIVE',
                              style: TextStyle(
                                color: Color(0xFF00E0A4),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title.description,
                      style: const TextStyle(
                        color: Color(0xFF9AA3C7),
                        fontSize: 14,
                      ),
                    ),
                    if (!title.isUnlocked && title.requiredAchievements.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Requires: ${title.requiredAchievements.length} achievements',
                        style: const TextStyle(
                          color: Color(0xFF9AA3C7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (title.isUnlocked && !isActive && onTap != null)
                const Icon(
                  Icons.radio_button_unchecked,
                  color: Color(0xFF9AA3C7),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

