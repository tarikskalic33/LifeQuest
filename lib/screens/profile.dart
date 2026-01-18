import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/quest_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF0B1021),
      ),
      body: Consumer2<AuthProvider, QuestProvider>(
        builder: (context, authProvider, questProvider, child) {
          final user = authProvider.user;
          
          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF7C5CFF)),
            );
          }

          final completedQuests = questProvider.getCompletedQuests();
          final totalQuests = questProvider.quests.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Card(
                  color: const Color(0xFF151B36),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFF7C5CFF),
                          child: Text(
                            user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.username,
                          style: const TextStyle(
                            color: Color(0xFFE6E9FF),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: const TextStyle(
                            color: Color(0xFF9AA3C7),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem('Level', '${user.level}', const Color(0xFF7C5CFF)),
                            _buildStatItem('XP', '${user.xp}', const Color(0xFF00E0A4)),
                            _buildStatItem('Streak', '${user.streak}', const Color(0xFFFF6B6B)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Mentor Information
                Card(
                  color: const Color(0xFF151B36),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI Mentor',
                          style: TextStyle(
                            color: Color(0xFFE6E9FF),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.psychology,
                              color: Color(0xFF7C5CFF),
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.mentorType,
                                    style: const TextStyle(
                                      color: Color(0xFFE6E9FF),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    'Your personal guide on this journey',
                                    style: TextStyle(
                                      color: Color(0xFF9AA3C7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Character Stats
                Card(
                  color: const Color(0xFF151B36),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Character Stats',
                          style: TextStyle(
                            color: Color(0xFFE6E9FF),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...user.stats.entries.map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _capitalizeFirst(entry.key),
                                    style: const TextStyle(
                                      color: Color(0xFF9AA3C7),
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '${entry.value}',
                                    style: const TextStyle(
                                      color: Color(0xFFE6E9FF),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: (entry.value / 100).clamp(0.0, 1.0),
                                backgroundColor: const Color(0xFF0B1021),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getStatColor(entry.key),
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Quest Statistics
                Card(
                  color: const Color(0xFF151B36),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quest Statistics',
                          style: TextStyle(
                            color: Color(0xFFE6E9FF),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem(
                              'Completed',
                              '${completedQuests.length}',
                              const Color(0xFF00E0A4),
                            ),
                            _buildStatItem(
                              'Total',
                              '$totalQuests',
                              const Color(0xFF7C5CFF),
                            ),
                            _buildStatItem(
                              'Success Rate',
                              totalQuests > 0 
                                  ? '${((completedQuests.length / totalQuests) * 100).round()}%'
                                  : '0%',
                              const Color(0xFFFFB800),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B6B),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () async {
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: const Color(0xFF151B36),
                          title: const Text(
                            'Logout',
                            style: TextStyle(color: Color(0xFFE6E9FF)),
                          ),
                          content: const Text(
                            'Are you sure you want to logout?',
                            style: TextStyle(color: Color(0xFF9AA3C7)),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Color(0xFF9AA3C7)),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                'Logout',
                                style: TextStyle(color: Color(0xFFFF6B6B)),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (shouldLogout == true) {
                        await authProvider.logout();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/onboarding',
                          (route) => false,
                        );
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      'Logout',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF9AA3C7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Color _getStatColor(String stat) {
    switch (stat.toLowerCase()) {
      case 'health':
        return const Color(0xFFFF6B6B);
      case 'discipline':
        return const Color(0xFF7C5CFF);
      case 'creativity':
        return const Color(0xFFFFB800);
      case 'knowledge':
        return const Color(0xFF00E0A4);
      case 'social':
        return const Color(0xFF00D4FF);
      default:
        return const Color(0xFF9AA3C7);
    }
  }
}

