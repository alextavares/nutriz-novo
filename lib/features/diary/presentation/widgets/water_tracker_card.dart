import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/value_objects/water_volume.dart';

class WaterTrackerCard extends StatelessWidget {
  final WaterVolume currentVolume;
  final int goalMl;
  final Function(int) onAdd;

  const WaterTrackerCard({
    super.key,
    required this.currentVolume,
    required this.goalMl,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentVolume.valueMl / goalMl).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.water_drop_rounded,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Water Tracker',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3436),
                    ),
                  ),
                ],
              ),
              Text(
                '${currentVolume.valueMl.toInt()} / $goalMl ml',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Main Visual (Wave Progress)
          SizedBox(
            height: 120,
            child: Row(
              children: [
                // Big Water Bottle / Circle
                Expanded(
                  flex: 3,
                  child: Center(
                    child: _AnimatedWaterCircle(progress: progress),
                  ),
                ),
                // Quick Add Buttons
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _QuickAddButton(
                        amount: 250,
                        label: '+250ml',
                        onTap: () => onAdd(250),
                      ),
                      const SizedBox(height: 12),
                      _QuickAddButton(
                        amount: 500,
                        label: '+500ml',
                        onTap: () => onAdd(500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedWaterCircle extends StatelessWidget {
  final double progress;

  const _AnimatedWaterCircle({required this.progress});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: progress),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.withOpacity(0.05),
            border: Border.all(color: Colors.blue.withOpacity(0.2), width: 2),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Wave Fill (Simplified as a bottom-up fill for now, could be a real wave shader)
              ClipOval(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 100,
                    height: 100 * value,
                    color: Colors.blue.withOpacity(0.2),
                  ),
                ),
              ),
              // Percentage Text
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(value * 100).toInt()}%',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  final int amount;
  final String label;
  final VoidCallback onTap;

  const _QuickAddButton({
    required this.amount,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withOpacity(0.2)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}
