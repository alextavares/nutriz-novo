import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/models/fasting_stage.dart';
import '../notifiers/fasting_notifier.dart';

class FastingBodyStatusScreen extends ConsumerWidget {
  const FastingBodyStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fastingState = ref.watch(fastingNotifierProvider);
    final elapsed = fastingState.elapsed;
    final isFasting = fastingState.startTime != null;
    final currentStage = fastingState.currentStage;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 4, bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Current Stage Hero Card ────────────────────────────────────
          _CurrentStageCard(
            currentStage: currentStage,
            elapsed: elapsed,
            isFasting: isFasting,
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Timeline ───────────────────────────────────────────────────
          const Text(
            'Linha do Tempo',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          ...FastingStage.values.asMap().entries.map((entry) {
            final i = entry.key;
            final stage = entry.value;
            final isLast = i == FastingStage.values.length - 1;
            final isReached = elapsed >= stage.startDuration;
            final isActive = stage == currentStage && isFasting;
            final timeInStage = isReached
                ? elapsed - stage.startDuration
                : null;

            return _StageRow(
              stage: stage,
              isReached: isReached,
              isActive: isActive,
              isLast: isLast,
              timeInStage: timeInStage,
            );
          }),
        ],
      ),
    );
  }
}

class _CurrentStageCard extends StatelessWidget {
  final FastingStage currentStage;
  final Duration elapsed;
  final bool isFasting;

  const _CurrentStageCard({
    required this.currentStage,
    required this.elapsed,
    required this.isFasting,
  });

  @override
  Widget build(BuildContext context) {
    final nextStageIndex = FastingStage.values.indexOf(currentStage) + 1;
    final hasNext = nextStageIndex < FastingStage.values.length;
    final nextStage = hasNext ? FastingStage.values[nextStageIndex] : null;
    final timeToNext = nextStage != null
        ? nextStage.startDuration - elapsed
        : null;

    String _formatCountdown(Duration d) {
      if (d.isNegative) return '0min';
      final h = d.inHours;
      final m = d.inMinutes.remainder(60);
      if (h > 0) return '${h}h ${m}min';
      return '${m}min';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            currentStage.color.withValues(alpha: 0.7),
            currentStage.color.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: currentStage.color.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  currentStage.icon,
                  size: 24,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFasting ? 'Etapa atual' : 'Você está em',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      currentStage.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              // Hours badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${currentStage.startDuration.inHours}h+',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            currentStage.description,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
          if (nextStage != null && timeToNext != null && isFasting) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${nextStage.title} em ${_formatCountdown(timeToNext)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StageRow extends StatelessWidget {
  final FastingStage stage;
  final bool isReached;
  final bool isActive;
  final bool isLast;
  final Duration? timeInStage;

  const _StageRow({
    required this.stage,
    required this.isReached,
    required this.isActive,
    required this.isLast,
    this.timeInStage,
  });

  String _formatTime(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0 && m > 0) return '${h}h ${m}min';
    if (h > 0) return '${h}h';
    return '${m}min';
  }

  @override
  Widget build(BuildContext context) {
    final dotColor = isReached ? AppColors.primary : AppColors.border;
    final lineColor = isReached
        ? AppColors.primary.withValues(alpha: 0.3)
        : AppColors.border;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline column
          SizedBox(
            width: 32,
            child: Column(
              children: [
                // Dot
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary
                        : isReached
                        ? AppColors.primary.withValues(alpha: 0.7)
                        : AppColors.surfaceVariant,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: dotColor,
                      width: isActive ? 2.5 : 1.5,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: isReached
                      ? Icon(
                          isActive ? stage.icon : Icons.check_rounded,
                          size: isActive ? 12 : 13,
                          color: Colors.white,
                        )
                      : null,
                ),
                // Vertical line to next stage
                if (!isLast)
                  Expanded(
                    child: Center(child: Container(width: 2, color: lineColor)),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? stage.color.withValues(alpha: 0.25)
                      : isReached
                      ? AppColors.surface
                      : AppColors.surfaceVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: isActive
                        ? stage.color.withValues(alpha: 0.6)
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Stage name + hour label
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  stage.title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: isReached
                                        ? AppColors.textPrimary
                                        : AppColors.textHint,
                                  ),
                                ),
                              ),
                              Text(
                                '${stage.startDuration.inHours}h',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isReached
                                      ? AppColors.primary
                                      : AppColors.textHint,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            stage.description,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isReached
                                  ? AppColors.textSecondary
                                  : AppColors.textHint,
                              height: 1.3,
                            ),
                          ),
                          // Time in stage badge
                          if (timeInStage != null && isActive) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '${_formatTime(timeInStage!)} nesta etapa',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (!isReached)
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 14,
                        color: AppColors.textHint,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
