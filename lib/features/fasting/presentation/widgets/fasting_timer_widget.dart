import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../shared/widgets/gamification/streak_flame.dart';
import '../../../../shared/widgets/progress/animated_progress_ring.dart';
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

  // Modern Yazio-like Palette
  static const Color _primaryColor = Color(0xFF00BFA5); // Teal/Turquoise
  static const Color _secondaryColor = Color(0xFF1DE9B6); // Lighter Teal

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
                            color: _primaryColor.withValues(alpha: 0.1),
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
                        color: Colors.grey[100],
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
                        colors: [_secondaryColor, _primaryColor],
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
                          color: _primaryColor,
                        ),
                        const SizedBox(height: 8),

                        // Giant Timer
                        Text(
                          _formatDuration(elapsed),
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
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
                            color: _primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Fasting',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _primaryColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // 2. Stats Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
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
                          'Start',
                          _formatTime(start),
                          icon: Icons.play_arrow_rounded,
                          onEdit: onEditStart,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey[200],
                        ),
                        _buildStatItem(
                          'End',
                          _formatTime(end),
                          icon: Icons.stop_rounded,
                          onEdit: onEditEnd,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey[200],
                        ),
                        _buildStatItem(
                          'Goal',
                          '${goal.inHours}h',
                          icon: Icons.flag_rounded,
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              // 3. End Fasting Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ElevatedButton(
                  onPressed: onStop,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    shadowColor: _primaryColor.withValues(alpha: 0.3),
                  ),
                  child: const Text(
                    'End Fasting',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 4. Streak & History
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Last 7 Days',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(height: 150, child: FastingHistoryChart()),
                  ],
                ),
              ),

              const SizedBox(height: 40),
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
                if (icon != null) Icon(icon, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (onEdit != null) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.edit, size: 12, color: _primaryColor),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
