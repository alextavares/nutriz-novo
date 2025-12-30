import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/progress/animated_progress_ring.dart';
import '../../../../shared/widgets/section_header.dart';
import 'fasting_history_chart.dart';

class FastingTimerWidget extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Duration elapsed;
  final Duration goal;
  final DateTime? startTime;
  final VoidCallback? onStart;
  final VoidCallback? onStop;
  final VoidCallback? onEditStart;
  final VoidCallback? onEditEnd;

  const FastingTimerWidget({
    super.key,
    required this.progress,
    required this.elapsed,
    required this.goal,
    this.startTime,
    this.onStart,
    this.onStop,
    this.onEditStart,
    this.onEditEnd,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '--:--';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final ringSize = math.min(availableWidth * 0.85, 320.0);
        final isFasting = startTime != null;
        final statusLabel = isFasting ? 'Em jejum' : 'Pronto';

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // 1. The Big Animated Ring
              SizedBox(
                width: ringSize,
                height: ringSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Shadow for depth
                    Container(
                      width: ringSize,
                      height: ringSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            blurRadius: 20,
                            spreadRadius: 5,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                    ),
                    // Background Ring
                    SizedBox(
                      width: ringSize,
                      height: ringSize,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 22,
                        color: AppColors.surfaceVariant,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    // Animated Ring Painter
                    AnimatedProgressRing(
                      progress: progress,
                      size: ringSize,
                      strokeWidth: 22,
                      color: Colors.transparent,
                      backgroundColor: Colors.transparent,
                      gradient: const SweepGradient(
                        startAngle: -math.pi / 2,
                        endAngle: 3 * math.pi / 2,
                        colors: [AppColors.primaryDark, AppColors.primary],
                        tileMode: TileMode.clamp,
                      ),
                    ),

                    // Center Content
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Icon
                        Icon(
                          Icons.bolt_rounded,
                          size: 32,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 8),

                        // Giant Timer
                        Text(
                          _formatDuration(elapsed),
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            fontFeatures: const [FontFeature.tabularFigures()],
                            height: 1.0,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Label
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // 2. Stats Card
              Container(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Builder(
                  builder: (context) {
                    final start = startTime;
                    final end = start?.add(goal);
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          'Início',
                          _formatTime(start),
                          icon: Icons.play_arrow_rounded,
                          onEdit: onEditStart,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppColors.border,
                        ),
                        _buildStatItem(
                          'Fim',
                          _formatTime(end),
                          icon: Icons.stop_rounded,
                          onEdit: onEditEnd,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppColors.border,
                        ),
                        _buildStatItem(
                          'Meta',
                          '${goal.inHours}h',
                          icon: Icons.flag_rounded,
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // 3. Start/Stop Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isFasting ? onStop : onStart,
                  icon: Icon(
                    isFasting ? Icons.stop_rounded : Icons.play_arrow_rounded,
                    size: 20,
                  ),
                  label: Text(isFasting ? 'Encerrar jejum' : 'Iniciar jejum'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // 4. Streak & History
              const SectionHeader(title: 'Últimos 7 dias'),
              const SizedBox(height: AppSpacing.md),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: const SizedBox(height: 150, child: FastingHistoryChart()),
              ),

              const SizedBox(height: 220),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    String label,
    String value, {
    IconData? icon,
    VoidCallback? onEdit,
  }) {
    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Row(
              children: [
                if (icon != null)
                  Icon(icon, size: 14, color: AppColors.textHint),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (onEdit != null) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.edit, size: 12, color: AppColors.primary),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
