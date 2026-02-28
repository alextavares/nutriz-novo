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
    final isFasting = startTime != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final ringSize = math.min(constraints.maxWidth * 0.85, 300.0);

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 12),

              // ── Big animated ring ──────────────────────────────────────
              SizedBox(
                width: ringSize,
                height: ringSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow shadow under ring
                    Container(
                      width: ringSize,
                      height: ringSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.18),
                            blurRadius: 40,
                            spreadRadius: 8,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                    ),
                    // Track
                    SizedBox(
                      width: ringSize,
                      height: ringSize,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 20,
                        color: AppColors.surfaceVariant,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    // Gradient progress arc
                    AnimatedProgressRing(
                      progress: isFasting ? progress : 0,
                      size: ringSize,
                      strokeWidth: 20,
                      color: Colors.transparent,
                      backgroundColor: Colors.transparent,
                      gradient: const SweepGradient(
                        startAngle: -math.pi / 2,
                        endAngle: 3 * math.pi / 2,
                        colors: [AppColors.primaryLight, AppColors.primaryDark],
                        tileMode: TileMode.clamp,
                      ),
                    ),

                    // Center content
                    if (isFasting)
                      _ActiveCenter(elapsed: elapsed, progress: progress)
                    else
                      _IdleCenter(onStart: onStart, goal: goal),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── Stats card ────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
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
                          color: AppColors.primary,
                          onEdit: onEditStart,
                        ),
                        _divider(),
                        _buildStatItem(
                          'Fim',
                          _formatTime(end),
                          icon: Icons.stop_rounded,
                          color: AppColors.secondary,
                          onEdit: onEditEnd,
                        ),
                        _divider(),
                        _buildStatItem(
                          'Meta',
                          '${goal.inHours}h',
                          icon: Icons.flag_rounded,
                          color: AppColors.accent,
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // ── Start / Stop button ───────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: FilledButton.icon(
                    onPressed: isFasting ? onStop : onStart,
                    icon: Icon(
                      isFasting
                          ? Icons.stop_circle_outlined
                          : Icons.play_circle_outlined,
                      size: 22,
                    ),
                    label: Text(isFasting ? 'Encerrar jejum' : 'Iniciar jejum'),
                    style: FilledButton.styleFrom(
                      backgroundColor: isFasting
                          ? AppColors.error
                          : AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusLg,
                        ),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── History chart ─────────────────────────────────────────
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
                child: const SizedBox(
                  height: 150,
                  child: FastingHistoryChart(),
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  Widget _divider() => Container(width: 1, height: 40, color: AppColors.border);

  Widget _buildStatItem(
    String label,
    String value, {
    required IconData icon,
    required Color color,
    VoidCallback? onEdit,
  }) {
    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (onEdit != null) ...[
                  const SizedBox(width: 3),
                  const Icon(
                    Icons.edit_rounded,
                    size: 10,
                    color: AppColors.primary,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
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

/// Center of the ring when actively fasting
class _ActiveCenter extends StatelessWidget {
  final Duration elapsed;
  final double progress;

  const _ActiveCenter({required this.elapsed, required this.progress});

  String _format(Duration d) {
    String p(int n) => n.toString().padLeft(2, '0');
    return '${p(d.inHours)}:${p(d.inMinutes.remainder(60))}:${p(d.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).toInt();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Lightning bolt icon
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.bolt_rounded,
            size: 26,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _format(elapsed),
          style: const TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            fontFeatures: [FontFeature.tabularFigures()],
            height: 1.0,
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$pct% concluído',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }
}

/// Center of the ring when NOT fasting
class _IdleCenter extends StatelessWidget {
  final VoidCallback? onStart;
  final Duration goal;

  const _IdleCenter({required this.onStart, required this.goal});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Suggest starting at 20:00 if before that, or right now
    final suggestedStart = now.hour < 20
        ? DateTime(now.year, now.month, now.day, 20, 0)
        : now;
    final suggestedEnd = suggestedStart.add(goal);
    String _fmt(DateTime t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.bedtime_rounded,
            size: 28,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Pronto para\ncomeçar',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${_fmt(suggestedStart)} → ${_fmt(suggestedEnd)}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
