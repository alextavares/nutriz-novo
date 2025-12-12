import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../../../core/constants/app_spacing.dart';
import '../../domain/models/fasting_stage.dart';
import '../notifiers/fasting_notifier.dart';

class FastingBodyStatusScreen extends ConsumerWidget {
  const FastingBodyStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fastingState = ref.watch(fastingNotifierProvider);
    final currentStage = fastingState.currentStage;

    // Calculate progress through the current 24h cycle (or goal)
    // For visualization, we'll cap it at 1.0
    final double overallProgress = (fastingState.elapsed.inMinutes / (24 * 60))
        .clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Body Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      "${fastingState.goal.inHours}:${(fastingState.goal.inMinutes % 60).toString().padLeft(2, '0')}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.edit, size: 14, color: Colors.teal),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Main White Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.xl,
              horizontal: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Circular Arc Painter
                SizedBox(
                  height: 220,
                  width: 220,
                  child: CustomPaint(
                    painter: FastingStagesPainter(progress: overallProgress),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            currentStage.icon,
                            size: 32,
                            color: const Color(
                              0xFF8D6E63,
                            ), // Matching brownish theme
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Text Content
                const Text(
                  'Current Stage',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentStage.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Check back while fasting to see the stages your body is going through.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Bottom Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'Fat burn',
                      _getTimeInStage(
                        fastingState.elapsed,
                        FastingStage.fatBurn,
                      ),
                      Icons.local_fire_department_rounded,
                    ),
                    _buildStatItem(
                      'Autophagy',
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
      return '0 hr 0 min';
    }
    final timeInStage = elapsed - stage.startDuration;
    return '${timeInStage.inHours} hr ${timeInStage.inMinutes % 60} min';
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
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

  FastingStagesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;

    // Draw background track (Partial Circle)
    // Starting from -220 degrees to +40 degrees (leaving bottom open)
    const startAngle = -math.pi * 1.2;
    const sweepLength = math.pi * 1.4;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..color =
          const Color(0xFFF5F5F5) // Very light grey
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepLength,
      false,
      trackPaint,
    );

    // Draw Progress
    final progressSweep = sweepLength * progress;

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..color =
          const Color(0xFF8D6E63) // Brownish
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
    return oldDelegate.progress != progress;
  }
}
