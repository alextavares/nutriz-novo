import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/diary_day.dart';
import '../../../../core/value_objects/calories.dart';
import '../../../fasting/presentation/notifiers/fasting_notifier.dart';

class BentoDailySummary extends ConsumerWidget {
  final DiaryDay diaryDay;
  final int? calorieGoal;

  const BentoDailySummary({
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
    final remaining = (goal.value - consumed.value).toInt();
    final progress = (consumed.value / goal.value).clamp(0.0, 1.0);

    final isFasting = ref.watch(
      fastingNotifierProvider.select((s) => s.isFasting),
    );
    final fastingState = ref.watch(fastingNotifierProvider);

    return SizedBox(
      height: 240,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Main Block: Calories & Macros
          Expanded(
            flex: 10,
            child: _MainCalorieCard(
              consumed: consumed.value.toInt(),
              goal: goal.value.toInt(),
              remaining: remaining,
              progress: progress,
              diaryDay: diaryDay,
            ),
          ),
          const SizedBox(width: 12),
          // Side Blocks: Water & Fasting
          Expanded(
            flex: 7, // Adjust ratio for visual balance
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _WaterCard(
                    // Placeholder connect to water provider later if needed
                    // For now using diaryDay date or generic
                    onTap: () {
                      // Trigger water add or nav
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _FastingCard(
                    isFasting: isFasting,
                    startTime: fastingState.startTime,
                    onTap: () => context.push('/fasting'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MainCalorieCard extends StatelessWidget {
  final int consumed;
  final int goal;
  final int remaining;
  final double progress;
  final DiaryDay diaryDay;

  const _MainCalorieCard({
    required this.consumed,
    required this.goal,
    required this.remaining,
    required this.progress,
    required this.diaryDay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.push('/nutrition-detail', extra: diaryDay),
        borderRadius: BorderRadius.circular(32),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Vitalidade',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: AppColors.textHint,
                  ),
                ],
              ),
              const Spacer(),
              // Organic Donut Chart
              SizedBox(
                height: 130,
                width: 130,
                child: CustomPaint(
                  painter: _OrganicRingPainter(progress: progress),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$remaining',
                          style: AppTypography.displayLarge.copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: remaining < 0
                                ? AppColors.secondary
                                : AppColors.textPrimary,
                            height: 1,
                          ),
                        ),
                        Text(
                          'kcal left',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Macro Mini Bars
              _MacroRow(diaryDay: diaryDay),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1);
  }
}

class _MacroRow extends StatelessWidget {
  final DiaryDay diaryDay;
  const _MacroRow({required this.diaryDay});

  @override
  Widget build(BuildContext context) {
    // Simplified display
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _MacroPill(
          label: 'Prot',
          color: AppColors.protein,
          value: '${diaryDay.totalMacros.protein.toInt()}g',
        ),
        _MacroPill(
          label: 'Carb',
          color: AppColors.carbs,
          value: '${diaryDay.totalMacros.carbs.toInt()}g',
        ),
        _MacroPill(
          label: 'Gord',
          color: AppColors.fat,
          value: '${diaryDay.totalMacros.fat.toInt()}g',
        ),
      ],
    );
  }
}

class _MacroPill extends StatelessWidget {
  final String label;
  final Color color;
  final String value;

  const _MacroPill({
    required this.label,
    required this.color,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        ),
      ],
    );
  }
}

class _WaterCard extends StatelessWidget {
  final VoidCallback onTap;

  const _WaterCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD), // Light Blue
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Wave background (Simulated with gradient for now)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.accent.withOpacity(0.3),
                          AppColors.accent.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.water_drop_rounded,
                    color: AppColors.accent,
                    size: 24,
                  ),
                  const Spacer(),
                  Text(
                    '1.2L',
                    style: AppTypography.headlineLarge.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accent,
                    ),
                  ),
                  const Text(
                    'Hidratação',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.1);
  }
}

class _FastingCard extends StatelessWidget {
  final bool isFasting;
  final DateTime? startTime;
  final VoidCallback onTap;

  const _FastingCard({
    required this.isFasting,
    required this.startTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isFasting
            ? AppColors.secondary.withOpacity(0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isFasting
                    ? Icons.local_fire_department_rounded
                    : Icons.timer_off_rounded,
                color: isFasting ? AppColors.secondary : AppColors.textHint,
                size: 24,
              ),
              const Spacer(),
              Text(
                isFasting ? 'Jejum On' : 'Descanso',
                style: AppTypography.titleLarge.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isFasting
                      ? AppColors.secondary
                      : AppColors.textSecondary,
                ),
              ),
              Text(
                isFasting ? 'Queimando' : 'Iniciar',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.1);
  }
}

class _OrganicRingPainter extends CustomPainter {
  final double progress;

  _OrganicRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = 16.0;
    final radius = (size.width - strokeWidth) / 2;

    // Rail (Neumorphic style - pressed in)
    final railPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final shadowPaint =
        Paint() // Inner shadow simulation
          ..color = Colors.black.withOpacity(0.05)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, railPaint);
    canvas.drawCircle(center, radius, shadowPaint); // Optional depth

    // Gradient Progress
    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.success, Color(0xFFC5D8A4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      progress * 2 * math.pi,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
