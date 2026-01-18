import 'package:flutter/material.dart';

class StatDisplay extends StatelessWidget {
  final String label;
  final int value;
  final int maxValue;
  final Color? color;
  final IconData? icon;
  final bool showProgress;

  const StatDisplay({
    Key? key,
    required this.label,
    required this.value,
    this.maxValue = 100,
    this.color,
    this.icon,
    this.showProgress = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = value / maxValue;
    final displayColor = color ?? Theme.of(context).primaryColor;

    return Column(
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: displayColor),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '$value${showProgress ? '/$maxValue' : ''}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: displayColor,
              ),
            ),
          ],
        ),
        if (showProgress) ...[
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: displayColor.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(displayColor),
          ),
        ],
      ],
    );
  }
}

class StatsGrid extends StatelessWidget {
  final Map<String, int> stats;
  final Map<String, IconData>? icons;
  final Map<String, Color>? colors;

  const StatsGrid({
    Key? key,
    required this.stats,
    this.icons,
    this.colors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statEntries = stats.entries.toList();
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: statEntries.length,
      itemBuilder: (context, index) {
        final entry = statEntries[index];
        final statName = entry.key;
        final statValue = entry.value;
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: StatDisplay(
              label: _formatStatName(statName),
              value: statValue,
              icon: icons?[statName],
              color: colors?[statName],
              showProgress: false,
            ),
          ),
        );
      },
    );
  }

  String _formatStatName(String statName) {
    return statName.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

// Animated stat counter
class AnimatedStatCounter extends StatefulWidget {
  final int value;
  final Duration duration;
  final TextStyle? textStyle;

  const AnimatedStatCounter({
    Key? key,
    required this.value,
    this.duration = const Duration(milliseconds: 1000),
    this.textStyle,
  }) : super(key: key);

  @override
  State<AnimatedStatCounter> createState() => _AnimatedStatCounterState();
}

class _AnimatedStatCounterState extends State<AnimatedStatCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = IntTween(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedStatCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = IntTween(
        begin: _animation.value,
        end: widget.value,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          _animation.value.toString(),
          style: widget.textStyle,
        );
      },
    );
  }
}