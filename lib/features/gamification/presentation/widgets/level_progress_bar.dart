import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';

class LevelProgressBar extends StatelessWidget {
  final int currentLevel;
  final int currentXp;
  final int xpToNextLevel;

  const LevelProgressBar({
    super.key,
    required this.currentLevel,
    required this.currentXp,
    required this.xpToNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentXp / xpToNextLevel).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Nível $currentLevel',
              style: AppTypography.labelLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$currentXp / $xpToNextLevel XP',
              style: AppTypography.caption,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.surfaceVariant,
            color: AppColors.primary,
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
