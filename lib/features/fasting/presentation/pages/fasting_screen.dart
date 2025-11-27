import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_spacing.dart';
import '../notifiers/fasting_notifier.dart';
import '../widgets/fasting_history_chart.dart';
import '../widgets/fasting_timer_widget.dart';

class FastingScreen extends ConsumerWidget {
  const FastingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fastingState = ref.watch(fastingNotifierProvider);
    final progress =
        (fastingState.elapsed.inSeconds / fastingState.goal.inSeconds).clamp(
          0.0,
          1.0,
        );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFDF4FF), // Light Purple Start
              Color(0xFFF8F0FF), // Light Purple End
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "You're fasting!",
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4A148C),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(
                    Icons.rocket_launch,
                    color: Colors.orange,
                    size: 28,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Timer
              Center(
                child: FastingTimerWidget(
                  progress: progress,
                  elapsed: fastingState.elapsed,
                  goal: fastingState.goal,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Info Row (Start/End/Goal)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoColumn('Start', '20:00'),
                  _buildInfoColumn('End', '12:00'),
                  _buildInfoColumn('Goal', '16h'),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // End Fasting Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Confirm dialog
                    ref.read(fastingNotifierProvider.notifier).stopFasting();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8E24AA), // Strong Purple
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
              const SizedBox(height: 40),

              // Streak Badge
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Color(0xFF8E24AA),
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '16:8 Streak → ',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      '12 days',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF8E24AA),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // History Chart
              const Text(
                'Last 7 Days',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const FastingHistoryChart(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4A148C),
          ),
        ),
      ],
    );
  }
}
