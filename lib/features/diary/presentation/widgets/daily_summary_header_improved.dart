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

// Dark text color for use on the gradient (better contrast than white)
const _kDarkText = Color(0xFF143D22);
const _kDarkTextMid = Color(0xFF1E5930);
const _kDarkTextLight = Color(0xFF2D7A45);

class DailySummaryHeaderImproved extends ConsumerWidget {
  final DiaryDay diaryDay;
  final int? calorieGoal;
  final bool deEmphasizeFastingCta;
  final String? dateLabel;
  final VoidCallback? onPreviousDay;
  final VoidCallback? onNextDay;
  final VoidCallback? onDetailsTap;
  final Widget? profileIcon;

  const DailySummaryHeaderImproved({
    super.key,
    required this.diaryDay,
    this.calorieGoal,
    this.deEmphasizeFastingCta = false,
    this.dateLabel,
    this.onPreviousDay,
    this.onNextDay,
    this.onDetailsTap,
    this.profileIcon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileNotifierProvider);
    final goal = calorieGoal != null
        ? Calories(calorieGoal!.toDouble())
        : (diaryDay.calorieGoal ?? const Calories(2000));
    final consumed = diaryDay.totalCalories;
    const burned = 0;
    final isFasting = ref.watch(
      fastingNotifierProvider.select((s) => s.isFasting),
    );
    final showCompactFastingCta = deEmphasizeFastingCta && !isFasting;

    return Column(
      children: [
        // ── Gradient header ──────────────────────────────────────────────
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF27AE60), // Medium green top
                Color(0xFFA8E063), // Lime-yellow bottom
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              // Safe area + top bar
              SizedBox(height: MediaQuery.of(context).padding.top),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    // Date navigation (center)
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: onPreviousDay,
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.chevron_left_rounded,
                                color: _kDarkText,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 13,
                            color: _kDarkText,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            dateLabel ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: _kDarkText,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(width: 2),
                          GestureDetector(
                            onTap: onNextDay,
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.chevron_right_rounded,
                                color: _kDarkText,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Profile icon right
                    profileIcon ?? const SizedBox(width: 40),
                  ],
                ),
              ),

              // Ring + flanking stats
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 4,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final ringSize = (constraints.maxWidth * 0.50).clamp(
                      140.0,
                      175.0,
                    );
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _StatColumn(
                            label: 'Consumidas',
                            value: consumed.value.toInt(),
                            alignment: CrossAxisAlignment.end,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: onDetailsTap,
                          child: SizedBox(
                            width: ringSize,
                            height: ringSize,
                            child: _CalorieRing(
                              consumed: consumed.value.toInt(),
                              goal: goal.value.toInt(),
                              burned: burned,
                              diameter: ringSize,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StatColumn(
                            label: 'Queimadas',
                            value: burned,
                            alignment: CrossAxisAlignment.start,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Fasting chip inside gradient
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: showCompactFastingCta
                    ? _FastingAction(
                        isFasting: false,
                        onTap: () => context.push('/fasting'),
                      )
                    : _FastingAction(
                        isFasting: isFasting,
                        onTap: () => context.push('/fasting'),
                      ),
              ),
            ],
          ),
        ),

        // ── Macro cards (white, below gradient) ──────────────────────────
        Container(
          color: AppColors.surfaceVariant,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            0,
          ),
          child: Row(
            children: [
              _MacroCard(
                label: 'Carbo',
                value: diaryDay.totalMacros.carbs,
                goal: profile.carbsGrams.toDouble(),
                color: AppColors.carbs,
              ),
              const SizedBox(width: AppSpacing.sm),
              _MacroCard(
                label: 'Proteína',
                value: diaryDay.totalMacros.protein,
                goal: profile.proteinGrams.toDouble(),
                color: AppColors.protein,
              ),
              const SizedBox(width: AppSpacing.sm),
              _MacroCard(
                label: 'Gordura',
                value: diaryDay.totalMacros.fat,
                goal: profile.fatGrams.toDouble(),
                color: AppColors.fat,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Individual white macro card
class _MacroCard extends StatelessWidget {
  final String label;
  final double value;
  final double goal;
  final Color color;

  const _MacroCard({
    required this.label,
    required this.value,
    required this.goal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final safeProgress = goal > 0 ? (value / goal).clamp(0.0, 1.0) : 0.0;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: safeProgress,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              goal > 0
                  ? '${value.toInt()}/${goal.toInt()}g'
                  : '${value.toInt()}g',
              style: const TextStyle(
                fontSize: 11,
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

/// Calorie ring with dark text for contrast on the green gradient
class _CalorieRing extends StatelessWidget {
  final int consumed;
  final int goal;
  final int burned;
  final double diameter;

  const _CalorieRing({
    required this.consumed,
    required this.goal,
    required this.burned,
    required this.diameter,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = goal - consumed + burned;
    final progress = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
    final numFontSize = (diameter * 0.26).clamp(36.0, 52.0);

    return CustomPaint(
      painter: _RingPainter(progress: progress),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              remaining.toString(),
              style: TextStyle(
                fontSize: numFontSize,
                fontWeight: FontWeight.w900,
                height: 1,
                color: _kDarkText,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Restantes',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _kDarkTextMid,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = (size.shortestSide * 0.09).clamp(10.0, 16.0);
    final radius = (size.shortestSide - strokeWidth) / 2;

    // Track
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress
    final progressPaint = Paint()
      ..color = Colors.white
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
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

class _StatColumn extends StatelessWidget {
  final String label;
  final int value;
  final CrossAxisAlignment alignment;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _kDarkTextLight,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: _kDarkText,
          ),
        ),
      ],
    );
  }
}

class _FastingAction extends StatelessWidget {
  final bool isFasting;
  final VoidCallback onTap;

  const _FastingAction({required this.isFasting, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final icon = isFasting
        ? Icons.local_fire_department_rounded
        : Icons.timer_rounded;
    final label = isFasting ? 'Agora: Jejum' : 'Iniciar jejum';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: _kDarkText),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: _kDarkText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
