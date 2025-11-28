import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'fasting_fox_animation.dart';
import 'fasting_history_chart.dart';

class FastingTimerWidget extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Duration elapsed;
  final Duration goal;
  final DateTime? startTime;
  final VoidCallback? onStop;
  final VoidCallback? onEditStart;
  final VoidCallback? onEditEnd;

  const FastingTimerWidget({
    super.key,
    required this.progress,
    required this.elapsed,
    required this.goal,
    this.startTime,
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
        // Calculate available width for the ring
        final availableWidth = constraints.maxWidth;
        // Ring size should be responsive but not overwhelming
        final ringSize = math.min(availableWidth * 0.85, 350.0);

        return SingleChildScrollView(
          child: Column(
            children: [
              // 1. The Big Animated Ring
              SizedBox(
                width: ringSize,
                height: ringSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Animated Ring Painter
                    AnimatedFastingRing(progress: progress, size: ringSize),

                    // Center Content
                    // Center Content
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Fox/Bunny Icon (Kawaii)
                        SizedBox(
                          height: ringSize * 0.18,
                          width: ringSize * 0.18,
                          child: const FastingFoxAnimation(),
                        ),
                        const SizedBox(height: 20),

                        // Giant Timer
                        Text(
                          _formatDuration(elapsed),
                          style: GoogleFonts.inter(
                            fontSize: ringSize * 0.16, // Responsive font size
                            fontWeight: FontWeight.w800, // ExtraBold
                            color: const Color(0xFF4A148C), // Deep Purple
                            fontFeatures: [const FontFeature.tabularFigures()],
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Label
                        Text(
                          'Fasting Time',
                          style: GoogleFonts.inter(
                            fontSize: ringSize * 0.045,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 2. Stats Row (Start / End / Goal)
              Builder(
                builder: (context) {
                  final start = startTime;
                  final end = start?.add(goal);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn(
                        'Start',
                        _formatTime(start),
                        onEdit: onEditStart,
                      ),
                      _buildStatColumn(
                        'End',
                        _formatTime(end),
                        onEdit: onEditEnd,
                      ),
                      _buildStatColumn('Goal', '${goal.inHours}h'),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),

              // 3. End Fasting Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ElevatedButton(
                  onPressed: onStop,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8E24AA), // Strong Purple
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                    shadowColor: const Color(0xFF8E24AA).withValues(alpha: 0.4),
                  ),
                  child: Text(
                    'END FASTING',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 4. Streak Pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Color(0xFFFF6B35), // Orange Fire
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '16:8 Streak → ',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFF6B35), Color(0xFF8E24AA)],
                      ).createShader(bounds),
                      child: Text(
                        '12 days',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Masked by shader
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 5. Chart at the bottom
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last 7 Days',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(height: 150, child: FastingHistoryChart()),
                  ],
                ),
              ),

              const SizedBox(height: 40), // Bottom padding
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatColumn(String label, String value, {VoidCallback? onEdit}) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey[500],
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D0C57), // Darker purple text
          ),
        ),
        if (onEdit != null) ...[
          const SizedBox(height: 4),
          InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Edit',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF8E24AA),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.edit, size: 12, color: Color(0xFF8E24AA)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// =======================================
// Animated Ring Component
// =======================================
class AnimatedFastingRing extends StatelessWidget {
  final double progress;
  final double size;

  const AnimatedFastingRing({
    required this.progress,
    required this.size,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return CustomPaint(
          size: Size(size, size),
          painter: _FastingRingPainter(
            progress: value.clamp(0.0, 1.0),
            strokeWidth: 22, // Thick premium stroke
          ),
        );
      },
    );
  }
}

// =======================================
// Custom Painter for the Ring
// =======================================
class _FastingRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  _FastingRingPainter({required this.progress, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // CRITICAL: Radius calculation to prevent clipping
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    // 1. Background Ring (Soft Purple/Pink)
    final bgPaint = Paint()
      ..color = const Color(0xFFE1BEE7)
          .withValues(alpha: 0.3) // Very light purple
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // 2. Progress Ring (Gradient Purple -> Pink)
    final progressPaint = Paint()
      ..shader = const SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: [
          Color(0xFF9C27B0), // Purple
          Color(0xFFE91E63), // Pink
        ],
        tileMode: TileMode.clamp,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw arc starting from top (-pi/2)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _FastingRingPainter old) =>
      old.progress != progress || old.strokeWidth != strokeWidth;
}
