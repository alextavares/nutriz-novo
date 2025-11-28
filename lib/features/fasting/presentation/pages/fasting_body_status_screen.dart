import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/models/fasting_stage.dart';
import '../notifiers/fasting_notifier.dart';
import 'dart:math' as math;

class FastingBodyStatusScreen extends ConsumerWidget {
  const FastingBodyStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fastingState = ref.watch(fastingNotifierProvider);
    final currentStage = fastingState.currentStage;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row (Fasting Stages + Goal)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Fasting Stages",
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A148C),
                ),
              ),
              Row(
                children: [
                  Text(
                    "${fastingState.goal.inHours}:${(fastingState.goal.inMinutes % 60).toString().padLeft(2, '0')}",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.edit, size: 16, color: Colors.blue),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Main Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Circular Gauge
                SizedBox(
                  height: 250,
                  child: CustomPaint(
                    painter: FastingStagesPainter(
                      elapsed: fastingState.elapsed,
                      currentStage: currentStage,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            currentStage.icon,
                            size: 48,
                            color: currentStage.color,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Stage Text
                Text(
                  "Your current fasting stage:",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentStage.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D4037), // Brownish
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      "Fat burn",
                      _getTimeInStage(
                        fastingState.elapsed,
                        FastingStage.fatBurn,
                      ),
                      Icons.local_fire_department,
                    ),
                    _buildStatItem(
                      "Autophagy",
                      _getTimeInStage(
                        fastingState.elapsed,
                        FastingStage.autophagy,
                      ),
                      Icons.cleaning_services,
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
      return "0 hr 0 min";
    }
    final timeInStage = elapsed - stage.startDuration;
    return "${timeInStage.inHours} hr ${timeInStage.inMinutes % 60} min";
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Icon(icon, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
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
  final Duration elapsed;
  final FastingStage currentStage;

  FastingStagesPainter({required this.elapsed, required this.currentStage});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;

    // Draw background circle
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..color = Colors.grey[200]!;

    canvas.drawCircle(center, radius, paint);

    // Draw progress arc
    // Assume 24 hours for full circle for visualization
    final progress = (elapsed.inMinutes / (24 * 60)).clamp(0.0, 1.0);
    final sweepAngle = 2 * math.pi * progress;

    paint.color = const Color(0xFF8D6E63); // Brownish color from image
    paint.strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
