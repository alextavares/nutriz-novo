import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class MacroBars extends StatelessWidget {
  final double carbs;
  final double protein;
  final double fat;
  final double carbsGoal;
  final double proteinGoal;
  final double fatGoal;
  final String carbsLabel;
  final String proteinLabel;
  final String fatLabel;

  const MacroBars({
    super.key,
    required this.carbs,
    required this.protein,
    required this.fat,
    this.carbsGoal = 210,
    this.proteinGoal = 140,
    this.fatGoal = 60,
    this.carbsLabel = 'Carbo',
    this.proteinLabel = 'Proteína',
    this.fatLabel = 'Gordura',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: _MacroBarItem(
            label: carbsLabel,
            value: carbs,
            goal: carbsGoal,
            color: AppColors.carbs,
            theme: theme,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MacroBarItem(
            label: proteinLabel,
            value: protein,
            goal: proteinGoal,
            color: AppColors.protein,
            theme: theme,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MacroBarItem(
            label: fatLabel,
            value: fat,
            goal: fatGoal,
            color: AppColors.fat,
            theme: theme,
          ),
        ),
      ],
    );
  }
}

class _MacroBarItem extends StatelessWidget {
  final String label;
  final double value;
  final double goal;
  final Color color;
  final ThemeData theme;

  const _MacroBarItem({
    required this.label,
    required this.value,
    required this.goal,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final safeProgress = goal > 0 ? (value / goal).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: safeProgress,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          goal > 0 ? '${value.toInt()}/${goal.toInt()} g' : '${value.toInt()} g',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary.withValues(alpha: 0.82),
          ),
        ),
      ],
    );
  }
}
