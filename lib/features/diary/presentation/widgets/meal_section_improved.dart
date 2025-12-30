import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/meal.dart';

class MealSectionImproved extends StatelessWidget {
  final MealType mealType;
  final String title;
  final List<Meal> meals;
  final VoidCallback onAddPressed;
  final Function(String mealId)? onRemoveFood;
  final Function(String mealId, double newQuantity)? onUpdateQuantity;
  final Function(Meal meal, FoodItem foodItem)? onFoodTap;

  const MealSectionImproved({
    super.key,
    required this.mealType,
    required this.title,
    required this.meals,
    required this.onAddPressed,
    this.onRemoveFood,
    this.onUpdateQuantity,
    this.onFoodTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalCalories = meals.fold<double>(
      0,
      (sum, meal) => sum + meal.totalCalories.value,
    );

    // Determine goal based on meal type (placeholder logic)
    final goal = switch (mealType) {
      MealType.breakfast => 400,
      MealType.lunch => 600,
      MealType.dinner => 500,
      MealType.snack => 200,
    };

    final progress = (totalCalories / goal).clamp(0.0, 1.0);
    final foodCount = meals.fold<int>(
      0,
      (sum, meal) => sum + meal.foods.length,
    );

    // Check if meal has food items
    final hasFoodItems = foodCount > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(
          color: hasFoodItems
              ? _getMealColor(mealType).withValues(alpha: 0.22)
              : AppColors.border,
          width: hasFoodItems ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: hasFoodItems
                ? _getMealColor(mealType).withValues(alpha: 0.10)
                : AppColors.shadow,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Icon, Title, and Progress
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _getMealIcon(mealType),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (foodCount > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$foodCount ${foodCount == 1 ? 'item' : 'itens'}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${totalCalories.toInt()} / $goal',
                            style: AppTypography.caption.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'kcal',
                            style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _FloatingAddButton(onTap: onAddPressed),
              ],
            ),
          ),

          // Progress Bar
          if (hasFoodItems)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: AppColors.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getProgressColor(progress),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${(progress * 100).toInt()}%',
                      style: AppTypography.labelSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Food Items List
          if (!hasFoodItems) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: InkWell(
                onTap: onAddPressed,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline_rounded,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Toque em + para adicionar alimentos',
                          style: AppTypography.bodyMedium.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textHint,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          if (hasFoodItems) ...[
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1, color: AppColors.border),
            ),
            const SizedBox(height: 8),
            ...meals.expand(
              (meal) => meal.foods.map((foodItem) {
                return Dismissible(
                  key: Key('${meal.id}_${foodItem.food.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (_) {
                    onRemoveFood?.call(meal.id);
                  },
                  child: InkWell(
                    onTap: () => onFoodTap?.call(meal, foodItem),
                    borderRadius: BorderRadius.circular(16),
                    child: _SmartFoodItemRow(foodItem: foodItem),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.5) return AppColors.success;
    if (progress < 0.9) return AppColors.warning;
    return AppColors.error;
  }

  Color _getMealColor(MealType type) {
    return switch (type) {
      MealType.breakfast => const Color(0xFFFF9F43), // Orange
      MealType.lunch => const Color(0xFFFF6B6B), // Red/Pink
      MealType.dinner => const Color(0xFF5F27CD), // Purple
      MealType.snack => const Color(0xFF1DD1A1), // Green/Teal
    };
  }

  Widget _getMealIcon(MealType type) {
    final (iconData, color, bgColor) = switch (type) {
      MealType.breakfast => (
        Icons.wb_sunny_rounded,
        const Color(0xFFFF9F43),
        const Color(0xFFFFF3E0),
      ),
      MealType.lunch => (
        Icons.restaurant_rounded,
        const Color(0xFFFF6B6B),
        const Color(0xFFFFEBEE),
      ),
      MealType.dinner => (
        Icons.nights_stay_rounded,
        const Color(0xFF5F27CD),
        const Color(0xFFEDE7F6),
      ),
      MealType.snack => (
        Icons.local_cafe_rounded,
        const Color(0xFF1DD1A1),
        const Color(0xFFE0F2F1),
      ),
    };

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(iconData, color: color, size: 22),
    );
  }
}

class _FloatingAddButton extends StatelessWidget {
  final VoidCallback onTap;

  const _FloatingAddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _SmartFoodItemRow extends StatelessWidget {
  final FoodItem foodItem;

  const _SmartFoodItemRow({required this.foodItem});

  @override
  Widget build(BuildContext context) {
    final food = foodItem.food;
    final macros = food.macros;
    final total = macros.carbs + macros.protein + macros.fat;

    // Normalize macros for visuals
    final pC = total > 0 ? macros.carbs / total : 0.0;
    final pP = total > 0 ? macros.protein / total : 0.0;
    final pF = total > 0 ? macros.fat / total : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Food Icon/Image (Rounded Square)
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getFoodIcon(food.name),
              color: AppColors.textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name,
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${foodItem.quantity.toStringAsFixed(0)}x ${food.servingSize}${food.servingUnit}',
                  style: AppTypography.caption,
                ),
                const SizedBox(height: 6),
                // Macro Bar
                if (total > 0)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Row(
                      children: [
                        _BarSegment(
                          flex: (pP * 100).toInt(),
                          color: AppColors.protein,
                        ),
                        _BarSegment(
                          flex: (pC * 100).toInt(),
                          color: AppColors.carbs,
                        ),
                        _BarSegment(
                          flex: (pF * 100).toInt(),
                          color: AppColors.fat,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Calories
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${foodItem.totalCalories.value.toInt()}',
                style: AppTypography.titleMedium.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'kcal',
                style: AppTypography.caption.copyWith(
                  fontSize: 10,
                  color: AppColors.textHint,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getFoodIcon(String foodName) {
    final lowerName = foodName.toLowerCase();
    if (lowerName.contains('rice') || lowerName.contains('arroz')) {
      return Icons.rice_bowl_rounded;
    }
    if (lowerName.contains('chicken') || lowerName.contains('frango')) {
      return Icons.lunch_dining_rounded;
    }
    if (lowerName.contains('salad') || lowerName.contains('salada')) {
      return Icons.eco_rounded;
    }
    if (lowerName.contains('bread') ||
        lowerName.contains('pão') ||
        lowerName.contains('pao')) {
      return Icons.breakfast_dining_rounded;
    }
    if (lowerName.contains('coffee') || lowerName.contains('café')) {
      return Icons.local_cafe_rounded;
    }
    return Icons.restaurant_menu_rounded;
  }
}

class _BarSegment extends StatelessWidget {
  final int flex;
  final Color color;
  const _BarSegment({required this.flex, required this.color});
  @override
  Widget build(BuildContext context) {
    if (flex <= 0) return const SizedBox.shrink();
    return Flexible(
      flex: flex,
      child: Container(height: 3, color: color),
    );
  }
}
