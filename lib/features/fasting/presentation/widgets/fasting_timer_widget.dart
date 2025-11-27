import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'fasting_fox_animation.dart';

class FastingTimerWidget extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Duration elapsed;
  final Duration goal;

  const FastingTimerWidget({
    super.key,
    required this.progress,
    required this.elapsed,
    required this.goal,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use the smallest dimension to ensure a perfect square
        final size = constraints.biggest.shortestSide;
        // Ensure we have a valid size, defaulting to 300 if unbounded
        final effectiveSize = size.isFinite ? size : 300.0;

        return Center(
          child: SizedBox(
            width: effectiveSize,
            height: effectiveSize,
            child: CustomPaint(
              painter: _FastingRingPainter(
                progress: progress,
                strokeWidth: 15.0,
                backgroundColor: Colors.white.withValues(alpha: 0.5),
                gradient: const SweepGradient(
                  startAngle: -math.pi / 2,
                  endAngle: 3 * math.pi / 2,
                  colors: [
                    Color(0xFF9C27B0), // Purple
                    Color(0xFFE91E63), // Pink
                  ],
                  tileMode: TileMode.clamp,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const FastingFoxAnimation(),
                    SizedBox(height: effectiveSize * 0.05),
                    Text(
                      _formatDuration(elapsed),
                      style: GoogleFonts.inter(
                        fontSize: effectiveSize * 0.13, // Responsive font size
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4A148C), // Deep Purple Text
                        fontFeatures: [const FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      'Fasting Time',
                      style: GoogleFonts.inter(
                        fontSize: effectiveSize * 0.045, // Responsive font size
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FastingRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Gradient gradient;

  _FastingRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // CRITICAL: Radius must be half the size MINUS half the stroke width
    // to ensure the stroke stays entirely within the bounds.
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    // Draw Background Ring
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw Progress Ring
    final rect = Rect.fromCircle(center: center, radius: radius);
    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Start from top (-pi/2)
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _FastingRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.gradient != gradient;
  }
}
