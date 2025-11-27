import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/achievement.dart';

class AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final bool compact;

  const AchievementBadge({
    super.key,
    required this.achievement,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.isUnlocked;
    final color = isUnlocked ? AppColors.primary : AppColors.textHint;

    if (compact) {
      return Tooltip(
        message: achievement.title,
        child: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          radius: 20,
          child: Icon(
            Icons.emoji_events, // Placeholder icon
            color: color,
            size: 20,
          ),
        ),
      );
    }

    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          radius: 30,
          child: Icon(
            Icons.emoji_events, // Placeholder icon
            color: color,
            size: 30,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          achievement.title,
          style: AppTypography.caption.copyWith(
            color: isUnlocked ? AppColors.textPrimary : AppColors.textHint,
            fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
