import 'package:flutter/material.dart';

class AnimatedProgressBar extends StatefulWidget {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double height;
  final Duration duration;
  final bool showGlow;

  const AnimatedProgressBar({
    Key? key,
    required this.progress,
    this.backgroundColor = const Color(0xFF0B1021),
    this.progressColor = const Color(0xFF7C5CFF),
    this.height = 8.0,
    this.duration = const Duration(milliseconds: 800),
    this.showGlow = false, // Disabled by default for performance
  }) : super(key: key);

  @override
  _AnimatedProgressBarState createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut, // Simpler curve for better performance
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.progress - widget.progress).abs() > 0.001) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ));
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary( // Isolate repaints for better performance
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return Container(
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(widget.height / 2),
            ),
            child: FractionallySizedBox(
              widthFactor: _progressAnimation.value,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.progressColor,
                  borderRadius: BorderRadius.circular(widget.height / 2),
                  boxShadow: widget.showGlow && _progressAnimation.value > 0.05
                      ? [
                          BoxShadow(
                            color: widget.progressColor.withValues(alpha: 0.4),
                            blurRadius: 6,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class XPProgressBar extends StatelessWidget {
  final int currentXP;
  final int xpForNextLevel;
  final int level;

  const XPProgressBar({
    Key? key,
    required this.currentXP,
    required this.xpForNextLevel,
    required this.level,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final xpForCurrentLevel = _getXPForLevel(level);
    final xpForNext = _getXPForLevel(level + 1);
    final xpInLevel = currentXP - xpForCurrentLevel;
    final xpNeeded = xpForNext - xpForCurrentLevel;
    final progress = xpNeeded > 0 ? (xpInLevel / xpNeeded).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Level $level',
              style: const TextStyle(
                color: Color(0xFFE6E9FF),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$xpInLevel/$xpNeeded XP',
              style: const TextStyle(
                color: Color(0xFF9AA3C7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedProgressBar(
          progress: progress,
          progressColor: const Color(0xFF7C5CFF),
          height: 12,
          showGlow: true, // Keep glow only for XP bar
        ),
      ],
    );
  }

  int _getXPForLevel(int level) {
    // XP required for each level (exponential growth)
    return (level * level * 100);
  }
}

class StatProgressBar extends StatelessWidget {
  final String statName;  final int statValue;
  final Color color;
  final int maxValue;

  const StatProgressBar({
    Key? key,
    required this.statName,
    required this.statValue,
    required this.color,
    this.maxValue = 100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = (statValue / maxValue).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _capitalizeFirst(statName),
              style: const TextStyle(
                color: Color(0xFF9AA3C7),
                fontSize: 14,
              ),
            ),
            Text(
              '$statValue',
              style: const TextStyle(
                color: Color(0xFFE6E9FF),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        AnimatedProgressBar(
          progress: progress,
          progressColor: color,
          height: 8,
          showGlow: false, // Disabled for performance
        ),
      ],
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
