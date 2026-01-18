import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/quest_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LifeQuest'),
        backgroundColor: const Color(0xFF0B1021),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await authProvider.logout();
                  Navigator.pushReplacementNamed(context, '/onboarding');
                },
                tooltip: 'Logout',
              );
            },
          ),
        ],
      ),
      body: Consumer2<AuthProvider, QuestProvider>(
        builder: (context, authProvider, questProvider, child) {
          final user = authProvider.user;
          
          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF7C5CFF)),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Message
                Text(
                  'Welcome back, ${user.username}!',
                  style: const TextStyle(
                    color: Color(0xFFE6E9FF),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ready for today\'s adventure?',
                  style: const TextStyle(
                    color: Color(0xFF9AA3C7),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),

                // Level and XP Card
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
                                  'Level ${user.level}',
                                  style: const TextStyle(
                                    color: Color(0xFFE6E9FF),
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${user.xp} XP',
                                  style: const TextStyle(
                                    color: Color(0xFF9AA3C7),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '🔥 ${user.streak}',
                                  style: const TextStyle(
                                    color: Color(0xFFFF6B6B),
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Day Streak',
                                  style: TextStyle(
                                    color: Color(0xFF9AA3C7),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // XP Progress Bar
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Progress to next level',
                                  style: TextStyle(
                                    color: Color(0xFF9AA3C7),
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${authProvider.getXPForNextLevel()} XP to go',
                                  style: const TextStyle(
                                    color: Color(0xFF9AA3C7),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: authProvider.getLevelProgress(),
                              backgroundColor: const Color(0xFF0B1021),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C5CFF)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Today's Quests Summary
                Card(
                  color: const Color(0xFF151B36),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Today\'s Quests',
                              style: TextStyle(
                                color: Color(0xFFE6E9FF),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${questProvider.todaysCompletedCount}/${questProvider.todaysQuests.length}',
                              style: const TextStyle(
                                color: Color(0xFF00E0A4),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (questProvider.todaysQuests.isNotEmpty)
                          LinearProgressIndicator(
                            value: questProvider.todaysQuests.isEmpty 
                                ? 0 
                                : questProvider.todaysCompletedCount / questProvider.todaysQuests.length,
                            backgroundColor: const Color(0xFF0B1021),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E0A4)),
                          ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7C5CFF),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () => Navigator.pushNamed(context, '/quests'),
                            icon: const Icon(Icons.assignment),
                            label: const Text('View Quests'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

