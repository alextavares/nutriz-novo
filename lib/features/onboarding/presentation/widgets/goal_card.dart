import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Card para seleção de objetivo ou opção no onboarding
class GoalCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? selectedColor;

  const GoalCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = selectedColor ?? theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.15)
              : theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with gradient background
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isSelected
                      ? [primaryColor, primaryColor.withValues(alpha: 0.7)]
                      : [
                          theme.colorScheme.surfaceContainerHighest,
                          theme.colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.8,
                          ),
                        ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 36,
                color: isSelected
                    ? Colors.white
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? primaryColor : theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Card horizontal para seleção de nível de atividade (com suporte a Emoji ou Icon)
class ActivityLevelCard extends StatelessWidget {
  final IconData? icon;
  final String? emoji; // New: Emoji support
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const ActivityLevelCard({
    super.key,
    this.icon,
    this.emoji,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  }) : assert(icon != null || emoji != null, 'Provide either icon or emoji');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.15)
              : theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Icon or Emoji
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isSelected
                      ? [primaryColor, primaryColor.withValues(alpha: 0.7)]
                      : [
                          theme.colorScheme.surfaceContainerHighest,
                          theme.colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.8,
                          ),
                        ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: emoji != null
                    ? Text(emoji!, style: const TextStyle(fontSize: 28))
                    : Icon(
                        icon,
                        size: 28,
                        color: isSelected
                            ? Colors.white
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? primaryColor
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            // Check indicator
            if (isSelected)
              Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 18,
                      color: Colors.white,
                    ),
                  )
                  .animate()
                  .scale(begin: const Offset(0, 0), duration: 200.ms)
                  .fadeIn(duration: 200.ms),
          ],
        ),
      ),
    );
  }
}
