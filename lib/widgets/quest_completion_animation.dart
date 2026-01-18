import 'package:flutter/material.dart';
import 'dart:math' as math;

class QuestCompletionAnimation extends StatefulWidget {
  final Widget child;
  final bool isCompleted;
  final VoidCallback? onAnimationComplete;

  const QuestCompletionAnimation({
    Key? key,
    required this.child,
    required this.isCompleted,
    this.onAnimationComplete,
  }) : super(key: key);

  @override
  _QuestCompletionAnimationState createState() => _QuestCompletionAnimationState();
}

class _QuestCompletionAnimationState extends State<QuestCompletionAnimation>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _sparkleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _sparkleAnimation;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeOut,
    ));

    if (widget.isCompleted) {
      _playAnimation();
    }
  }

  @override
  void didUpdateWidget(QuestCompletionAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isCompleted && widget.isCompleted) {
      _playAnimation();
    }
  }

  void _playAnimation() async {
    await _scaleController.forward();
    await _scaleController.reverse();
    _sparkleController.forward();
    
    if (widget.onAnimationComplete != null) {
      widget.onAnimationComplete!();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _sparkleAnimation]),
      builder: (context, child) {
        return Stack(
          children: [
            // Main content with scale animation
            Transform.scale(
              scale: _scaleAnimation.value,
              child: widget.child,
            ),
            // Sparkle effects
            if (widget.isCompleted && _sparkleAnimation.value > 0)
              ...List.generate(8, (index) {
                final angle = (index * math.pi * 2) / 8;
                final distance = 50 * _sparkleAnimation.value;
                final x = math.cos(angle) * distance;
                final y = math.sin(angle) * distance;
                
                return Positioned(
                  left: x + 50,
                  top: y + 50,
                  child: Transform.scale(
                    scale: (1 - _sparkleAnimation.value) * 0.5,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB800).withValues(
                          alpha: (1 - _sparkleAnimation.value) * 0.8,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFB800).withValues(alpha: 0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}

class LevelUpAnimation extends StatefulWidget {
  final Widget child;
  final bool showAnimation;
  final int level;

  const LevelUpAnimation({
    Key? key,
    required this.child,
    required this.showAnimation,
    required this.level,
  }) : super(key: key);

  @override
  _LevelUpAnimationState createState() => _LevelUpAnimationState();
}

class _LevelUpAnimationState extends State<LevelUpAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: math.pi * 2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.showAnimation) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(LevelUpAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.showAnimation && widget.showAnimation) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.showAnimation)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.7 * (1 - _opacityAnimation.value)),
                  child: Center(
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: Opacity(
                          opacity: 1 - _opacityAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              gradient: const RadialGradient(
                                colors: [
                                  Color(0xFF7C5CFF),
                                  Color(0xFFFFB800),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF7C5CFF).withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '🎉',
                                  style: TextStyle(fontSize: 48),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'LEVEL UP!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Level ${widget.level}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class AchievementUnlockAnimation extends StatefulWidget {
  final Widget child;
  final bool showAnimation;
  final String achievementTitle;
  final String achievementIcon;

  const AchievementUnlockAnimation({
    Key? key,
    required this.child,
    required this.showAnimation,
    required this.achievementTitle,
    required this.achievementIcon,
  }) : super(key: key);

  @override
  _AchievementUnlockAnimationState createState() => _AchievementUnlockAnimationState();
}

class _AchievementUnlockAnimationState extends State<AchievementUnlockAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.bounceOut),
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    ));

    if (widget.showAnimation) {
      _controller.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 2000), () {
          if (mounted) {
            _controller.reverse();
          }
        });
      });
    }
  }

  @override
  void didUpdateWidget(AchievementUnlockAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.showAnimation && widget.showAnimation) {
      _controller.reset();
      _controller.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 2000), () {
          if (mounted) {
            _controller.reverse();
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.showAnimation)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Positioned(
                top: 50,
                left: 16,
                right: 16,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFFB800),
                            Color(0xFFFF8C00),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFB800).withValues(alpha: 0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(
                            widget.achievementIcon,
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Achievement Unlocked!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  widget.achievementTitle,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

