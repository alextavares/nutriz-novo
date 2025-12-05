import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import 'animated_progress_ring.dart';

class MacroRingsRow extends StatelessWidget {
  final double carbs;
  final double protein;
  final double fat;
  final double carbsGoal;
  final double proteinGoal;
  final double fatGoal;

  const MacroRingsRow({
    super.key,
    required this.carbs,
    required this.protein,
    required this.fat,
    this.carbsGoal = 210,
    this.proteinGoal = 140,
    this.fatGoal = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _MacroRingItem(
          label: 'Carbs',
          value: carbs,
          goal: carbsGoal,
          color: AppColors.carbs,
        ),
        _MacroRingItem(
          label: 'Protein',
          value: protein,
          goal: proteinGoal,
          color: AppColors.protein,
        ),
        _MacroRingItem(
          label: 'Fat',
          value: fat,
          goal: fatGoal,
          color: AppColors.fat,
        ),
      ],
    );
  }
}

class _MacroRingItem extends StatelessWidget {
  final String label;
  final double value;
  final double goal;
  final Color color;

  const _MacroRingItem({
    required this.label,
    required this.value,
    required this.goal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (value / goal).clamp(0.0, 1.0);
    const size = 60.0;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            AnimatedProgressRing(
              progress: progress,
              size: size,
              strokeWidth: 5,
              color: color,
              backgroundColor: color.withOpacity(0.15),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '${value.toInt()}/${goal.toInt()}g',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}
