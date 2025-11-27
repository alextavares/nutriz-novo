import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/meal.dart';

class MealSection extends StatelessWidget {
  final String title;
  final List<Meal> meals;
  final VoidCallback onAddPressed;

  const MealSection({
    super.key,
    required this.title,
    required this.meals,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final totalCalories = meals.fold<double>(
      0,
      (sum, meal) => sum + meal.totalCalories.value,
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              _getMealIcon(title),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.headlineMedium.copyWith(
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '${totalCalories.toInt()} / 0 Cal', // 0 is placeholder goal
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onAddPressed,
                icon: const Icon(
                  Icons.add_circle,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
            ],
          ),
          if (meals.isNotEmpty) ...[
            const Divider(height: AppSpacing.lg),
            ...meals.expand(
              (meal) => meal.foods.map((foodItem) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              foodItem.food.name,
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${foodItem.quantity}x ${foodItem.food.servingSize}${foodItem.food.servingUnit}',
                              style: AppTypography.caption,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${foodItem.totalCalories.value.toInt()}',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _getMealIcon(String title) {
    IconData iconData;
    Color color;

    if (title.contains('Café')) {
      iconData = Icons.wb_sunny_outlined;
      color = Colors.orange;
    } else if (title.contains('Almoço')) {
      iconData = Icons.restaurant;
      color = Colors.red;
    } else if (title.contains('Jantar')) {
      iconData = Icons.nights_stay_outlined;
      color = Colors.indigo;
    } else {
      iconData = Icons.local_cafe_outlined;
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: color, size: 24),
    );
  }
}
