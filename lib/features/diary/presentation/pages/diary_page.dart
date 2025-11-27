import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

import '../../../../shared/widgets/gamification/streak_flame.dart';
import '../../domain/entities/meal.dart';
import '../providers/diary_providers.dart';
import '../widgets/daily_summary_header.dart';
import '../widgets/meal_section.dart';
import '../widgets/water_section.dart';

class DiaryPage extends ConsumerWidget {
  const DiaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diaryState = ref.watch(diaryNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light grey background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        titleSpacing: AppSpacing.md,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Row(
              children: [
                const Icon(Icons.diamond, color: Colors.blue, size: 20),
                const SizedBox(width: 4),
                Text(
                  '0',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Streak Flame
                const StreakFlame(
                  streakDays: 1,
                ), // TODO: Connect to real streak
                const SizedBox(width: AppSpacing.md),
                const Icon(
                  Icons.calendar_today,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
              ],
            ),
          ),
        ],
      ),
      body: diaryState.diaryDay.when(
        data: (day) => ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          children: [
            // Main Title
            Text(
              'Today',
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            Text(
              'Week 163',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Summary Card
            DailySummaryHeader(diaryDay: day),
            const SizedBox(height: AppSpacing.lg),

            // Nutrition Section Header
            _buildSectionHeader('Nutrition', 'More', () {}),
            const SizedBox(height: AppSpacing.sm),

            // Meals
            MealSection(
              title: 'Café da Manhã',
              meals: day.getMealsByType(MealType.breakfast),
              onAddPressed: () {
                context.push('/food-search/${MealType.breakfast.name}');
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            MealSection(
              title: 'Almoço',
              meals: day.getMealsByType(MealType.lunch),
              onAddPressed: () {
                context.push('/food-search/${MealType.lunch.name}');
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            MealSection(
              title: 'Jantar',
              meals: day.getMealsByType(MealType.dinner),
              onAddPressed: () {
                context.push('/food-search/${MealType.dinner.name}');
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            MealSection(
              title: 'Lanches',
              meals: day.getMealsByType(MealType.snack),
              onAddPressed: () {
                context.push('/food-search/${MealType.snack.name}');
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Water Section
            WaterSection(currentVolume: day.waterIntake),
            const SizedBox(height: 80),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Erro: $err')),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String actionText,
    VoidCallback onAction,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            actionText,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
