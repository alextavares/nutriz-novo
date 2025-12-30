import 'dart:math' as math;

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
    final currentStage = fastingState.currentStage;

    final goalMinutes = fastingState.goal.inMinutes;
    final overallProgress = goalMinutes <= 0
        ? 0.0
        : (fastingState.elapsed.inMinutes / goalMinutes).clamp(0.0, 1.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: 220),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.xl,
              horizontal: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 220,
                  width: 220,
                  child: CustomPaint(
                    painter: FastingStagesPainter(
                      progress: overallProgress,
                      trackColor: AppColors.surfaceVariant,
                      progressColor: AppColors.primary,
                    ),
                    child: Center(
                      child: Container(
                        width: 74,
                        height: 74,
                        decoration: BoxDecoration(
                          color: currentStage.color.withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          currentStage.icon,
                          size: 34,
                          color: AppColors.textPrimary.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Etapa atual',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentStage.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  currentStage.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Queima de gordura',
                      _getTimeInStage(
                        fastingState.elapsed,
                        FastingStage.fatBurn,
                      ),
                      Icons.local_fire_department_rounded,
                    ),
                    _buildStatItem(
                      'Autofagia',
                      _getTimeInStage(
                        fastingState.elapsed,
                        FastingStage.autophagy,
                      ),
                      Icons.auto_awesome_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeInStage(Duration elapsed, FastingStage stage) {
    if (elapsed < stage.startDuration) {
      return '0h 0min';
    }
    final timeInStage = elapsed - stage.startDuration;
    final hours = timeInStage.inHours;
    final minutes = timeInStage.inMinutes.remainder(60);
    return '${hours}h ${minutes}min';
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FastingStagesPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  FastingStagesPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;

    const startAngle = -math.pi * 1.2;
    const sweepLength = math.pi * 1.4;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..color = trackColor
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepLength,
      false,
      trackPaint,
    );

    final progressSweep = sweepLength * progress;

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..color = progressColor
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progressSweep,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant FastingStagesPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}
