import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/widgets/gamification/streak_flame.dart';
import '../../../../shared/widgets/progress/animated_progress_ring.dart';
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
                    AnimatedProgressRing(
                      progress: progress,
                      size: ringSize,
                      strokeWidth: 22,
                      color: Colors.transparent,
                      backgroundColor: const Color(0xFFE1BEE7).withOpacity(0.3),
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
                    shadowColor: const Color(0xFF8E24AA).withOpacity(0.4),
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
                      color: Colors.purple.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StreakFlame(streakDays: 12),
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
