import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/meal.dart';

class MealSectionImproved extends StatelessWidget {
  final String title;
  final List<Meal> meals;
  final VoidCallback onAddPressed;
  final Function(String mealId)? onRemoveFood;
  final Function(String mealId, double newQuantity)? onUpdateQuantity;
  final Function(Meal meal, FoodItem foodItem)? onFoodTap;

  const MealSectionImproved({
    super.key,
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
    var goal = 0;
    if (title.contains('Breakfast') || title.contains('Café')) goal = 400;
    if (title.contains('Lunch') || title.contains('Almoço')) goal = 600;
    if (title.contains('Dinner') || title.contains('Jantar')) goal = 500;
    if (title.contains('Snack') || title.contains('Lanche')) goal = 200;

    final progress = goal > 0 ? (totalCalories / goal).clamp(0.0, 1.0) : 0.0;
    final foodCount = meals.fold<int>(
      0,
      (sum, meal) => sum + meal.foods.length,
    );

    // Check if meal has food items
    final hasFoodItems = foodCount > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: hasFoodItems
            ? Border.all(color: _getMealColor(title).withValues(alpha: 0.3), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: hasFoodItems
                ? _getMealColor(title).withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.03),
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
                _getMealIcon(title),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
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
                                '$foodCount ${foodCount == 1 ? 'item' : 'items'}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
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
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Cal',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[500],
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
          if (meals.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.grey[100],
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
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Food Items List
          if (meals.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1, color: Color(0xFFF0F0F0)),
            ),
            const SizedBox(height: 8),
            ...meals.expand(
              (meal) => meal.foods.map((foodItem) {
                return Dismissible(
                  key: Key(meal.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red[400],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (_) {
                    onRemoveFood?.call(meal.id);
                  },
                  child: InkWell(
                    onTap: () => onFoodTap?.call(meal, foodItem),
                    borderRadius: BorderRadius.circular(12),
                    child: _FoodItemRow(
                      name: foodItem.food.name,
                      quantity: foodItem.quantity,
                      servingSize: foodItem.food.servingSize,
                      servingUnit: foodItem.food.servingUnit,
                      calories: foodItem.totalCalories.value.toInt(),
                    ),
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
    if (progress < 0.5) return Colors.green;
    if (progress < 0.9) return Colors.orange;
    return Colors.red;
  }

  Color _getMealColor(String title) {
    if (title.contains('Café') || title.contains('Breakfast')) {
      return const Color(0xFFFF9F43); // Orange
    } else if (title.contains('Almoço') || title.contains('Lunch')) {
      return const Color(0xFFFF6B6B); // Red/Pink
    } else if (title.contains('Jantar') || title.contains('Dinner')) {
      return const Color(0xFF5F27CD); // Purple
    } else {
      return const Color(0xFF1DD1A1); // Green/Teal
    }
  }

  Widget _getMealIcon(String title) {
    IconData iconData;
    Color color;
    Color bgColor;

    if (title.contains('Café') || title.contains('Breakfast')) {
      iconData = Icons.wb_sunny_rounded;
      color = const Color(0xFFFF9F43);
      bgColor = const Color(0xFFFFF3E0);
    } else if (title.contains('Almoço') || title.contains('Lunch')) {
      iconData = Icons.restaurant_rounded;
      color = const Color(0xFFFF6B6B);
      bgColor = const Color(0xFFFFEBEE);
    } else if (title.contains('Jantar') || title.contains('Dinner')) {
      iconData = Icons.nights_stay_rounded;
      color = const Color(0xFF5F27CD);
      bgColor = const Color(0xFFEDE7F6);
    } else {
      iconData = Icons.local_cafe_rounded;
      color = const Color(0xFF1DD1A1);
      bgColor = const Color(0xFFE0F2F1);
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconData, color: color, size: 20),
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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
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

class _FoodItemRow extends StatelessWidget {
  final String name;
  final double quantity;
  final double servingSize;
  final String servingUnit;
  final int calories;

  const _FoodItemRow({
    required this.name,
    required this.quantity,
    required this.servingSize,
    required this.servingUnit,
    required this.calories,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Food Icon/Image
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[200]!, width: 1),
            ),
            child: Icon(_getFoodIcon(name), color: Colors.grey[400], size: 20),
          ),
          const SizedBox(width: 12),
          // Food Name and Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${quantity.toStringAsFixed(0)}x $servingSize$servingUnit',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Calories
          Text(
            '$calories',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3436),
            ),
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
    if (lowerName.contains('bread') || lowerName.contains('pão')) {
      return Icons.bakery_dining_rounded;
    }
    return Icons.restaurant_menu_rounded;
  }
}
