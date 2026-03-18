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
const _kRingTrack = Color(0xFFE5E7EB);
const _kRingProgress = Color(0xFF36C275);

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
    const burnedCalories = 0;
    final remainingProtein =
        profile.proteinGrams - diaryDay.totalMacros.protein.toInt();
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
                  vertical: 2,
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

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  10,
                ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.9),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final ringSize = (constraints.maxWidth * 0.34).clamp(
                            98.0,
                            120.0,
                          );
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: _SideSummaryStat(
                                  label: 'Consumidas',
                                  value: consumed.value.toInt(),
                                  alignment: CrossAxisAlignment.center,
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: onDetailsTap,
                                child: SizedBox(
                                  width: ringSize,
                                  height: ringSize,
                                  child: _CalorieRing(
                                    consumed: consumed.value.toInt(),
                                    goal: goal.value.toInt(),
                                    diameter: ringSize,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _SideSummaryStat(
                                  label: 'Queimadas',
                                  value: burnedCalories,
                                  alignment: CrossAxisAlignment.center,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      _ProteinFocusLine(remainingProtein: remainingProtein),
                      const SizedBox(height: 10),
                      MacroBars(
                        carbs: diaryDay.totalMacros.carbs,
                        protein: diaryDay.totalMacros.protein,
                        fat: diaryDay.totalMacros.fat,
                        carbsGoal: profile.carbsGrams.toDouble(),
                        proteinGoal: profile.proteinGrams.toDouble(),
                        fatGoal: profile.fatGrams.toDouble(),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  8,
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
  final bool isHighlighted;

  const _MacroCard({
    required this.label,
    required this.value,
    required this.goal,
    required this.color,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final safeProgress = goal > 0 ? (value / goal).clamp(0.0, 1.0) : 0.0;
    final remaining = goal > 0 ? (goal - value).toInt() : 0;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isHighlighted ? color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHighlighted ? color.withValues(alpha: 0.35) : AppColors.border,
            width: isHighlighted ? 1.4 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isHighlighted ? color : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isHighlighted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Foco',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: safeProgress,
                backgroundColor: color.withValues(alpha: isHighlighted ? 0.22 : 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: isHighlighted ? 6 : 5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              goal > 0
                  ? '${value.toInt()}/${goal.toInt()}g'
                  : '${value.toInt()}g',
              style: TextStyle(
                fontSize: isHighlighted ? 12 : 11,
                fontWeight: FontWeight.w800,
                color: isHighlighted ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
            if (isHighlighted) ...[
              const SizedBox(height: 2),
              Text(
                remaining > 0 ? 'Faltam ${remaining}g' : 'Meta batida',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: remaining > 0 ? color : AppColors.success,
                ),
              ),
            ],
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
  final double diameter;

  const _CalorieRing({
    required this.consumed,
    required this.goal,
    required this.diameter,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = goal - consumed;
    final isOverGoal = remaining < 0;
    final headlineValue = isOverGoal ? remaining.abs() : remaining;
    final caption = isOverGoal ? 'kcal acima' : 'kcal restantes';
    final progress = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
    final numFontSize = (diameter * 0.24).clamp(30.0, 44.0);

    return CustomPaint(
      painter: _RingPainter(progress: progress),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              headlineValue.toString(),
              style: TextStyle(
                fontSize: numFontSize,
                fontWeight: FontWeight.w800,
                height: 1,
                color: _kDarkText,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              caption,
              style: const TextStyle(
                fontSize: 11,
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
    final strokeWidth = (size.shortestSide * 0.075).clamp(8.0, 12.0);
    final radius = (size.shortestSide - strokeWidth) / 2;

    // Track
    final trackPaint = Paint()
      ..color = _kRingTrack
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress
    final progressPaint = Paint()
      ..color = _kRingProgress
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

class _SideSummaryStat extends StatelessWidget {
  final String label;
  final int value;
  final CrossAxisAlignment alignment;

  const _SideSummaryStat({
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
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _kDarkText,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'kcal',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ProteinFocusLine extends StatelessWidget {
  final int remainingProtein;

  const _ProteinFocusLine({
    required this.remainingProtein,
  });

  @override
  Widget build(BuildContext context) {
    final proteinLabel = remainingProtein > 0
        ? 'Proteina: faltam $remainingProtein g para a meta'
        : 'Proteina: meta batida por hoje';
    final proteinColor = remainingProtein > 0
        ? AppColors.protein
        : _kDarkTextMid;

    return Text(
      proteinLabel,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: proteinColor,
      ),
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
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: _kDarkText),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _kDarkText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
