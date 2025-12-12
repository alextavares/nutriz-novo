import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

/// Widget animado para exibir resultado de calorias calculadas
class CalorieResultDisplay extends StatefulWidget {
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final VoidCallback? onAnimationComplete;

  const CalorieResultDisplay({
    super.key,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.onAnimationComplete,
  });

  @override
  State<CalorieResultDisplay> createState() => _CalorieResultDisplayState();
}

class _CalorieResultDisplayState extends State<CalorieResultDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _calorieAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _calorieAnimation = IntTween(
      begin: 0,
      end: widget.calories,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward().then((_) {
      widget.onAnimationComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Calorie ring
        SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background ring
                  CustomPaint(
                    size: const Size(220, 220),
                    painter: _CalorieRingPainter(
                      progress: 1.0,
                      color: theme.colorScheme.surfaceContainerHighest,
                      strokeWidth: 16,
                    ),
                  ),
                  // Animated progress ring
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(220, 220),
                        painter: _CalorieRingPainter(
                          progress: _controller.value,
                          color: theme.colorScheme.primary,
                          strokeWidth: 16,
                        ),
                      );
                    },
                  ),
                  // Center content
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: _calorieAnimation,
                        builder: (context, child) {
                          return Text(
                            '${_calorieAnimation.value}',
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                              fontSize: 48,
                            ),
                          );
                        },
                      ),
                      Text(
                        'kcal/dia',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
            .animate()
            .scale(begin: const Offset(0.8, 0.8), duration: 600.ms)
            .fadeIn(duration: 600.ms),
        const SizedBox(height: 32),
        // Description
        Text(
              'Seu orçamento diário de calorias',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            )
            .animate(delay: 500.ms)
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.2, duration: 400.ms),
        const SizedBox(height: 32),
        // Macro breakdown
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _MacroChip(
              label: 'Proteína',
              value: widget.protein,
              unit: 'g',
              color: Colors.red.shade400,
              delay: 600,
            ),
            _MacroChip(
              label: 'Carboidratos',
              value: widget.carbs,
              unit: 'g',
              color: Colors.amber.shade600,
              delay: 700,
            ),
            _MacroChip(
              label: 'Gordura',
              value: widget.fat,
              unit: 'g',
              color: Colors.blue.shade400,
              delay: 800,
            ),
          ],
        ),
      ],
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final int value;
  final String unit;
  final Color color;
  final int delay;

  const _MacroChip({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '$value$unit',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.3, duration: 400.ms);
  }
}

class _CalorieRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CalorieRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_CalorieRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// Widget para exibir estimativa de tempo para atingir objetivo
class TimeEstimateWidget extends StatelessWidget {
  final double currentWeight;
  final double targetWeight;
  final int weeksToGoal;
  final DateTime estimatedDate;

  const TimeEstimateWidget({
    super.key,
    required this.currentWeight,
    required this.targetWeight,
    required this.weeksToGoal,
    required this.estimatedDate,
  });

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getMotivationalMessage() {
    if (weeksToGoal <= 4) {
      return 'Você está quase lá! 💪';
    } else if (weeksToGoal <= 12) {
      return 'Um objetivo alcançável! 🎯';
    } else if (weeksToGoal <= 24) {
      return 'Uma jornada transformadora! 🌟';
    } else {
      return 'Grandes conquistas levam tempo! 🏆';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLosing = currentWeight > targetWeight;
    final progressColor = isLosing ? Colors.orange : Colors.blue;

    return Column(
      children: [
        // Timeline visualization
        Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // Weight progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _WeightBubble(
                        label: 'Atual',
                        weight: currentWeight,
                        isPrimary: false,
                        theme: theme,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: progressColor.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: progressColor,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                  .animate(onPlay: (c) => c.repeat())
                                  .moveX(
                                    begin: -40,
                                    end: 40,
                                    duration: 2.seconds,
                                    curve: Curves.easeInOut,
                                  ),
                            ],
                          ),
                        ),
                      ),
                      _WeightBubble(
                        label: 'Meta',
                        weight: targetWeight,
                        isPrimary: true,
                        theme: theme,
                        color: progressColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Time estimate
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: progressColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$weeksToGoal semanas',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: progressColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Data estimada: ${_formatDate(estimatedDate)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            )
            .animate()
            .fadeIn(duration: 500.ms)
            .slideY(begin: 0.1, duration: 500.ms),
        const SizedBox(height: 24),
        // Motivational message
        Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: progressColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getMotivationalMessage(),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: progressColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
            .animate(delay: 300.ms)
            .fadeIn(duration: 400.ms)
            .scale(begin: const Offset(0.9, 0.9), duration: 400.ms),
      ],
    );
  }
}

class _WeightBubble extends StatelessWidget {
  final String label;
  final double weight;
  final bool isPrimary;
  final ThemeData theme;
  final Color? color;

  const _WeightBubble({
    required this.label,
    required this.weight,
    required this.isPrimary,
    required this.theme,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = color ?? theme.colorScheme.primary;

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isPrimary
                ? bubbleColor.withValues(alpha: 0.15)
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: isPrimary ? Border.all(color: bubbleColor, width: 2) : null,
          ),
          child: Center(
            child: Text(
              weight.toStringAsFixed(1),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isPrimary
                    ? bubbleColor
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: isPrimary ? FontWeight.w500 : null,
          ),
        ),
      ],
    );
  }
}

/// Widget de loading animado para tela de cálculo
class CalculatingAnimation extends StatelessWidget {
  final String message;

  const CalculatingAnimation({
    super.key,
    this.message = 'Calculando seu plano personalizado...',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated rings
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _AnimatedRing(
                size: 120,
                duration: 2.seconds,
                color: theme.colorScheme.primary,
              ),
              _AnimatedRing(
                size: 90,
                duration: 1.5.seconds,
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
              ),
              _AnimatedRing(
                size: 60,
                duration: 1.seconds,
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fadeIn(duration: 1.seconds)
            .then()
            .fadeOut(duration: 1.seconds),
      ],
    );
  }
}

class _AnimatedRing extends StatelessWidget {
  final double size;
  final Duration duration;
  final Color color;

  const _AnimatedRing({
    required this.size,
    required this.duration,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
          ),
        )
        .animate(onPlay: (c) => c.repeat())
        .rotate(duration: duration)
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.1, 1.1),
          duration: duration ~/ 2,
        )
        .then()
        .scale(
          begin: const Offset(1.1, 1.1),
          end: const Offset(1, 1),
          duration: duration ~/ 2,
        );
  }
}
