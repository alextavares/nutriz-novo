import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/value_objects/calories.dart';
import '../../../../shared/widgets/progress/calorie_ring.dart';
import '../../../../shared/widgets/progress/macro_bars.dart';
import '../../domain/entities/diary_day.dart';

class DailySummaryHeader extends ConsumerWidget {
  final DiaryDay diaryDay;

  const DailySummaryHeader({super.key, required this.diaryDay});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = diaryDay.calorieGoal ?? const Calories(2000);
    final consumed = diaryDay.totalCalories;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // IMPORTANTE: Clip.none permite que o anel não seja cortado
      clipBehavior: Clip.none,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            // Calorie Ring - com AspectRatio para manter proporção
            AspectRatio(
              aspectRatio: 1,
              child: CalorieRing(
                consumed: consumed.value.toInt(),
                goal: goal.value.toInt(),
                burned: 0,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Macro Bars
            MacroBars(
              carbs: diaryDay.totalMacros.carbs,
              protein: diaryDay.totalMacros.protein,
              fat: diaryDay.totalMacros.fat,
            ),
            const SizedBox(height: AppSpacing.md),

            // Fasting Banner
            GestureDetector(
              onTap: () => context.push('/fasting'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                  horizontal: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.deepOrange,
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Now: Fasting',
                      style: GoogleFonts.inter(
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
