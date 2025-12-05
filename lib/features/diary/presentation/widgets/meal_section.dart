import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/meal.dart';

class MealSection extends StatelessWidget {
  final String title;
  final List<Meal> meals;
  final VoidCallback onAddPressed;
  final Function(String mealId)? onRemoveFood;

  const MealSection({
    super.key,
    required this.title,
    required this.meals,
    required this.onAddPressed,
    this.onRemoveFood,
  });

  @override
  Widget build(BuildContext context) {
    final totalCalories = meals.fold<double>(
      0,
      (sum, meal) => sum + meal.totalCalories.value,
    );

    // Determine goal based on meal type (placeholder logic)
    int goal = 0;
    if (title.contains('Breakfast') || title.contains('Café')) goal = 400;
    if (title.contains('Lunch') || title.contains('Almoço')) goal = 600;
    if (title.contains('Dinner') || title.contains('Jantar')) goal = 500;
    if (title.contains('Snack') || title.contains('Lanche')) goal = 200;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
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
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${totalCalories.toInt()} / $goal kcal',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              _AddButton(onTap: onAddPressed),
            ],
          ),

          if (meals.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 20),
            ...meals.map((meal) {
              return meal.foods.map((foodItem) {
                return Dismissible(
                  key: Key(meal.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 16),
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
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Food Image Placeholder (or real image if available)
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.restaurant_menu_rounded,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                foodItem.food.name,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2D3436),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${foodItem.quantity}x ${foodItem.food.servingSize}${foodItem.food.servingUnit}',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${foodItem.totalCalories.value.toInt()}',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2D3436),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList();
            }).expand((list) => list),
          ],
        ],
      ),
    );
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(iconData, color: color, size: 22),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.add_rounded,
          color: AppColors.primary,
          size: 24,
        ),
      ),
    );
  }
}
