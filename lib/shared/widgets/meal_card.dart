import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'nutriz_card.dart';

class MealCard extends StatelessWidget {
  final String title;
  final int calories;
  final VoidCallback onTap;

  const MealCard({
    super.key,
    required this.title,
    required this.calories,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NutrizCard(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          Text(
            '$calories kcal',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
