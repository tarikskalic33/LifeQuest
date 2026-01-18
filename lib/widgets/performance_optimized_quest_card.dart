import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quest.dart';
import '../providers/quest_provider.dart';
import '../providers/enhanced_auth_provider.dart';
import '../providers/achievement_provider.dart';

/// Performance-optimized QuestCard with enhanced UX and animations
class PerformanceOptimizedQuestCard extends StatefulWidget {
  final Quest quest;
  final VoidCallback? onCompleted;
  
  const PerformanceOptimizedQuestCard({
    Key? key,
    required this.quest,
    this.onCompleted,
  }) : super(key: key);

  @override
  State<PerformanceOptimizedQuestCard> createState() => _PerformanceOptimizedQuestCardState();
}

class _PerformanceOptimizedQuestCardState extends State<PerformanceOptimizedQuestCard> 
    with TickerProviderStateMixin {
  
  late AnimationController _completionController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _isCompleting = false;
  bool _showCompletionEffect = false;

  @override
  void initState() {
    super.initState();
    
    // PERFORMANCE OPTIMIZATION: Efficient animation setup
    _completionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _completionController,
      curve: Curves.elasticOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Start subtle pulse animation for incomplete quests
    if (!widget.quest.isCompleted) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _completionController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _completeQuest() async {
    if (_isCompleting || widget.quest.isCompleted) return;
    
    setState(() {
      _isCompleting = true;
    });

    try {
      // PERFORMANCE OPTIMIZATION: Optimistic UI update
      _showCompletionAnimation();
      
      final authProvider = Provider.of<EnhancedAuthProvider>(context, listen: false);
      final questProvider = Provider.of<QuestProvider>(context, listen: false);
      final achievementProvider = Provider.of<AchievementProvider>(context, listen: false);
      
      // Complete quest with enhanced tracking
      final success = await questProvider.completeQuest(widget.quest.id);
      
      if (success && authProvider.user != null) {
        // Add XP with source tracking
        await authProvider.addXP(
          widget.quest.xpReward, 
          source: '${widget.quest.category} quest: ${widget.quest.title}'
        );
        
        // Update stats with category tracking
        await authProvider.updateStats(
          widget.quest.statBoosts, 
          category: widget.quest.category
        );
        
        // Check for new achievements
        final newAchievements = await achievementProvider.checkAchievements(
          authProvider.user!,
          questProvider.completedQuests,
        );
        
        // Show achievement notifications
        if (newAchievements.isNotEmpty) {
          _showAchievementNotifications(newAchievements);
        }
        
        // Refresh session activity
        authProvider.refreshActivity();
        
        // Callback for parent widget
        widget.onCompleted?.call();
        
        print('✅ Quest completed: ${widget.quest.title} (+${widget.quest.xpReward} XP)');
      } else {
        print('❌ Quest completion failed');
        _showErrorFeedback();
      }
    } catch (e) {
      print('❌ Quest completion error: $e');
      _showErrorFeedback();
    } finally {
      if (mounted) {
        setState(() {
          _isCompleting = false;
        });
      }
    }
  }

  void _showCompletionAnimation() {
    setState(() {
      _showCompletionEffect = true;
    });
    
    _pulseController.stop();
    _completionController.forward();
    
    // Hide completion effect after animation
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showCompletionEffect = false;
        });
      }
    });
  }

  void _showAchievementNotifications(List<dynamic> achievements) {
    for (final achievement in achievements) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '🏆 Achievement Unlocked: ${achievement.title}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.purple.shade700,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showErrorFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('❌ Failed to complete quest. Please try again.'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Color get _cardColor {
    if (widget.quest.isCompleted) {
      return Colors.green.withOpacity(0.1);
    }
    
    switch (widget.quest.difficulty) {
      case 'easy':
        return Colors.blue.withOpacity(0.1);
      case 'medium':
        return Colors.orange.withOpacity(0.1);
      case 'hard':
        return Colors.red.withOpacity(0.1);
      default:
        return Colors.purple.withOpacity(0.1);
    }
  }

  IconData get _difficultyIcon {
    switch (widget.quest.difficulty) {
      case 'easy':
        return Icons.circle;
      case 'medium':
        return Icons.change_history;
      case 'hard':
        return Icons.square;
      default:
        return Icons.star;
    }
  }

  Color get _difficultyColor {
    switch (widget.quest.difficulty) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.purple;
    }
  }

  String get _categoryEmoji {
    switch (widget.quest.category) {
      case 'health':
        return '💪';
      case 'productivity':
        return '⚡';
      case 'learning':
        return '📚';
      case 'mindfulness':
        return '🧘';
      case 'creativity':
        return '🎨';
      case 'social':
        return '👥';
      case 'financial':
        return '💰';
      case 'environment':
        return '🌱';
      case 'career':
        return '💼';
      case 'seasonal':
        return '🌟';
      default:
        return '🎯';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: widget.quest.isCompleted 
              ? _scaleAnimation.value 
              : _pulseAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _cardColor,
                  _cardColor.withOpacity(0.3),
                ],
              ),
              border: Border.all(
                color: widget.quest.isCompleted
                    ? Colors.green
                    : _difficultyColor.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                if (_showCompletionEffect)
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row
                        Row(
                          children: [
                            // Category emoji
                            Text(
                              _categoryEmoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 12),
                            
                            // Title and difficulty
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.quest.title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: widget.quest.isCompleted
                                          ? Colors.green.shade700
                                          : Colors.white,
                                      decoration: widget.quest.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        _difficultyIcon,
                                        size: 16,
                                        color: _difficultyColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.quest.difficulty.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: _difficultyColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            // XP reward
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.purple.shade300,
                                ),
                              ),
                              child: Text(
                                '+${widget.quest.xpReward} XP',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple.shade200,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Description
                        Text(
                          widget.quest.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade300,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Stats and action row
                        Row(
                          children: [
                            // Stat boosts
                            Expanded(
                              child: Wrap(
                                spacing: 8,
                                children: widget.quest.statBoosts.entries.map((entry) {
                                  return Chip(
                                    label: Text(
                                      '${entry.key} +${entry.value}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: Colors.blue.withOpacity(0.3),
                                    side: BorderSide(
                                      color: Colors.blue.shade300,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            
                            // Action button
                            if (!widget.quest.isCompleted)
                              ElevatedButton(
                                onPressed: _isCompleting ? null : _completeQuest,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isCompleting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : const Text(
                                        'Complete',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                              )
                            else
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 32,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Completion overlay effect
                  if (_showCompletionEffect)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.green.withOpacity(0.1),
                              Colors.green.withOpacity(0.3),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.stars,
                            size: 60,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}