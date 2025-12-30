import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/value_objects/calories.dart';
import '../../../../shared/widgets/progress/macro_bars.dart';
import '../../domain/entities/diary_day.dart';
import '../../../profile/presentation/notifiers/profile_notifier.dart';
import '../../../fasting/presentation/notifiers/fasting_notifier.dart';

class DailySummaryHeaderImproved extends ConsumerWidget {
  final DiaryDay diaryDay;
  final int? calorieGoal;
  final bool deEmphasizeFastingCta;

  const DailySummaryHeaderImproved({
    super.key,
    required this.diaryDay,
    this.calorieGoal,
    this.deEmphasizeFastingCta = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileNotifierProvider);
    final goal = calorieGoal != null
        ? Calories(calorieGoal!.toDouble())
        : (diaryDay.calorieGoal ?? const Calories(2000));
    final consumed = diaryDay.totalCalories;
    final burned = 0; // TODO: Connect to real data
    final isFasting =
        ref.watch(fastingNotifierProvider.select((state) => state.isFasting));
    final showCompactFastingCta = deEmphasizeFastingCta && !isFasting;

    return LayoutBuilder(
      builder: (context, constraints) {
        final ringSize = (constraints.maxWidth * 0.48).clamp(150.0, 180.0);
        final showSideStats = constraints.maxWidth >= 340;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.none,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                // Calorie Ring + stats beside (Yazio-like)
                if (showSideStats)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _StatColumn(
                            value: consumed.value.toInt(),
                            label: 'Consumidas',
                            icon: Icons.restaurant_rounded,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () =>
                            context.push('/nutrition-detail', extra: diaryDay),
                        child: SizedBox(
                          width: ringSize,
                          height: ringSize,
                          child: _EnhancedCalorieRing(
                            consumed: consumed.value.toInt(),
                            goal: goal.value.toInt(),
                            burned: burned,
                            diameter: ringSize,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _StatColumn(
                            value: burned,
                            label: 'Queimadas',
                            icon: Icons.local_fire_department_rounded,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  )
                else ...[
                  GestureDetector(
                    onTap: () =>
                        context.push('/nutrition-detail', extra: diaryDay),
                    child: SizedBox(
                      width: ringSize,
                      height: ringSize,
                      child: _EnhancedCalorieRing(
                        consumed: consumed.value.toInt(),
                        goal: goal.value.toInt(),
                        burned: burned,
                        diameter: ringSize,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatColumn(
                        value: consumed.value.toInt(),
                        label: 'Consumidas',
                        icon: Icons.restaurant_rounded,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 24),
                      _StatColumn(
                        value: burned,
                        label: 'Queimadas',
                        icon: Icons.local_fire_department_rounded,
                        color: AppColors.secondary,
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),

                // Macro Bars (compact)
                MacroBars(
                  carbs: diaryDay.totalMacros.carbs,
                  protein: diaryDay.totalMacros.protein,
                  fat: diaryDay.totalMacros.fat,
                  carbsGoal: profile.carbsGrams.toDouble(),
                  proteinGoal: profile.proteinGrams.toDouble(),
                  fatGoal: profile.fatGrams.toDouble(),
                ),
                const SizedBox(height: 12),

                // Fasting chip (compact CTA)
                if (showCompactFastingCta)
                  Align(
                    alignment: Alignment.center,
                    child: TextButton.icon(
                      onPressed: () => context.push('/fasting'),
                      icon: Icon(
                        Icons.timer_rounded,
                        size: 18,
                        color: AppColors.textPrimary.withValues(alpha: 0.55),
                      ),
                      label: Text(
                        'Iniciar jejum',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.textPrimary.withValues(alpha: 0.55),
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        backgroundColor: Colors.black.withValues(alpha: 0.035),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  )
                else
                  _FastingChip(
                    isFasting: isFasting,
                    onTap: () => context.push('/fasting'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EnhancedCalorieRing extends StatelessWidget {
  final int consumed;
  final int goal;
  final int burned;
  final double diameter;

  const _EnhancedCalorieRing({
    required this.consumed,
    required this.goal,
    required this.burned,
    required this.diameter,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = goal - consumed + burned;
    final progress = (consumed / goal).clamp(0.0, 1.0);
    final numberFontSize = (diameter * 0.27).clamp(40.0, 52.0);

    return CustomPaint(
      painter: _CalorieRingPainter(progress: progress),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              remaining.toString(),
              style: AppTypography.displayLarge.copyWith(
                fontSize: numberFontSize,
                fontWeight: FontWeight.w900,
                height: 1,
                color: remaining >= 0 ? AppColors.textPrimary : AppColors.error,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Restantes',
              style: AppTypography.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
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
    final strokeWidth = (size.shortestSide * 0.1).clamp(14.0, 20.0);
    final radius = (size.shortestSide - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = AppColors.surfaceVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.primary, AppColors.primaryLight],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      progress * 2 * math.pi, // Sweep angle
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: 4),
                    Text(
                      value.toString(),
                      style: AppTypography.titleMedium.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FastingChip extends StatelessWidget {
  final bool isFasting;
  final VoidCallback onTap;

  const _FastingChip({required this.isFasting, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bg = isFasting
        ? AppColors.secondaryLight.withValues(alpha: 0.28)
        : AppColors.surfaceVariant;
    final fg = isFasting ? AppColors.secondary : AppColors.primary;
    final icon = isFasting
        ? Icons.local_fire_department_rounded
        : Icons.timer_rounded;
    final label = isFasting ? 'Agora: Jejum' : 'Iniciar jejum';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: fg, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTypography.labelLarge.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
