import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/diary_day.dart';

class NutritionDetailScreen extends StatelessWidget {
  final DiaryDay diaryDay;

  const NutritionDetailScreen({super.key, required this.diaryDay});

  @override
  Widget build(BuildContext context) {
    final goal = diaryDay.calorieGoal?.value.toInt() ?? 2000;
    final consumed = diaryDay.totalCalories.value.toInt();
    final macros = diaryDay.totalMacros;

    // Hardcoded goals for now (can be passed or calculated later)
    const carbsGoal = 210.0;
    const proteinGoal = 140.0;
    const fatGoal = 56.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Today',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Goal'),
            const SizedBox(height: AppSpacing.sm),
            _buildGoalCard(
              consumed: consumed,
              goal: goal,
              carbs: macros.carbs,
              carbsGoal: carbsGoal,
              protein: macros.protein,
              proteinGoal: proteinGoal,
              fat: macros.fat,
              fatGoal: fatGoal,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildSectionTitle('Meals'),
            const SizedBox(height: AppSpacing.sm),
            _buildMealsCard(),
            const SizedBox(height: AppSpacing.lg),
            _buildSectionTitle('Nutrition Facts'),
            const SizedBox(height: AppSpacing.sm),
            _buildPlaceholderCard('Bar Chart Placeholder'),
            const SizedBox(height: AppSpacing.lg),
            _buildSectionTitle('Minerals'),
            const SizedBox(height: AppSpacing.sm),
            _buildNutrientList([
              'Arsenic',
              'Biotin',
              'Boron',
              'Calcium',
              'Chloride',
              'Choline',
            ]),
            const SizedBox(height: AppSpacing.lg),
            _buildSectionTitle('Vitamins'),
            const SizedBox(height: AppSpacing.sm),
            _buildNutrientList([
              'Vitamin A',
              'Vitamin B1',
              'Vitamin B12',
              'Vitamin C',
              'Vitamin D',
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildGoalCard({
    required int consumed,
    required int goal,
    required double carbs,
    required double carbsGoal,
    required double protein,
    required double proteinGoal,
    required double fat,
    required double fatGoal,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProgressBar(
            'Calories',
            consumed.toDouble(),
            goal.toDouble(),
            'Cal',
            AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildProgressBar('Carbs', carbs, carbsGoal, 'g', AppColors.carbs),
          const SizedBox(height: AppSpacing.md),
          _buildProgressBar(
            'Protein',
            protein,
            proteinGoal,
            'g',
            AppColors.protein,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildProgressBar('Fat', fat, fatGoal, 'g', AppColors.fat),
        ],
      ),
    );
  }

  Widget _buildProgressBar(
    String label,
    double value,
    double goal,
    String unit,
    Color color,
  ) {
    final progress = (value / goal).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${value.toInt()} / ${goal.toInt()} $unit',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[100],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildMealsCard() {
    // Placeholder for meals breakdown
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildMealRow('Breakfast', 0, 0, 0, 0),
          const Divider(),
          _buildMealRow('Lunch', 0, 0, 0, 0),
          const Divider(),
          _buildMealRow('Dinner', 0, 0, 0, 0),
          const Divider(),
          _buildMealRow('Snacks', 0, 0, 0, 0),
        ],
      ),
    );
  }

  Widget _buildMealRow(String name, int cals, int carbs, int protein, int fat) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          Text('$cals Cal', style: GoogleFonts.inter(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildPlaceholderCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Center(
        child: Text(text, style: GoogleFonts.inter(color: Colors.grey)),
      ),
    );
  }

  Widget _buildNutrientList(List<String> nutrients) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: nutrients
            .map(
              (nutrient) => Column(
                children: [
                  ListTile(
                    title: Text(nutrient, style: GoogleFonts.inter()),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE082),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'PRO',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (nutrient != nutrients.last)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
