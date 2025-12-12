import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/value_objects/calories.dart';
import '../../../../shared/widgets/progress/macro_rings_row.dart';
import '../../domain/entities/diary_day.dart';

class DailySummaryHeaderImproved extends ConsumerWidget {
  final DiaryDay diaryDay;
  final int? calorieGoal;

  const DailySummaryHeaderImproved({
    super.key,
    required this.diaryDay,
    this.calorieGoal,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = calorieGoal != null
        ? Calories(calorieGoal!.toDouble())
        : (diaryDay.calorieGoal ?? const Calories(2000));
    final consumed = diaryDay.totalCalories;
    final remaining = goal.value - consumed.value;
    final burned = 0; // TODO: Connect to real data

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.none,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Large Calorie Ring
            GestureDetector(
              onTap: () => context.push('/nutrition-detail', extra: diaryDay),
              child: SizedBox(
                width: 200,
                height: 200,
                child: _EnhancedCalorieRing(
                  consumed: consumed.value.toInt(),
                  goal: goal.value.toInt(),
                  burned: burned,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Eaten and Burned Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatColumn(
                  value: consumed.value.toInt(),
                  label: 'Eaten',
                  icon: Icons.restaurant_rounded,
                  color: Colors.green,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey[300],
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                ),
                _StatColumn(
                  value: burned,
                  label: 'Burned',
                  icon: Icons.local_fire_department_rounded,
                  color: Colors.deepOrange,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Macro Rings Row
            MacroRingsRow(
              carbs: diaryDay.totalMacros.carbs,
              protein: diaryDay.totalMacros.protein,
              fat: diaryDay.totalMacros.fat,
            ),
            const SizedBox(height: 16),

            // Fasting Banner
            GestureDetector(
              onTap: () => context.push('/fasting'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.deepOrange,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Now: Fasting',
                      style: TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnhancedCalorieRing extends StatelessWidget {
  final int consumed;
  final int goal;
  final int burned;

  const _EnhancedCalorieRing({
    required this.consumed,
    required this.goal,
    required this.burned,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = goal - consumed + burned;
    final progress = (consumed / goal).clamp(0.0, 1.0);

    return CustomPaint(
      painter: _CalorieRingPainter(progress: progress),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              remaining.toString(),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.black, // Logic handled in build
                height: 1,
              ).copyWith(color: remaining >= 0 ? Colors.black : Colors.red),
            ),
            const SizedBox(height: 4),
            Text(
              'Remaining',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalorieRingPainter extends CustomPainter {
  final double progress;

  _CalorieRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 15;
    final strokeWidth = 20.0;

    // Background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFF4CAF50), const Color(0xFF81C784)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -90 * (3.14159 / 180), // Start from top
      progress * 2 * 3.14159, // Sweep angle
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CalorieRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _StatColumn extends StatelessWidget {
  final int value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatColumn({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
