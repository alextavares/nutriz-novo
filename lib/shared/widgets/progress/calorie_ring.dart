import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'animated_progress_ring.dart';

class CalorieRing extends StatelessWidget {
  final int consumed;
  final int goal;
  final int burned;

  const CalorieRing({
    super.key,
    required this.consumed,
    required this.goal,
    required this.burned,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = (goal - consumed).clamp(0, 9999);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest.shortestSide.isFinite
            ? constraints.biggest.shortestSide
            : 350.0;

        return SizedBox(
          width: size,
          height: size + 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedProgressRing(
                progress: (consumed + burned) / goal.clamp(1, double.infinity),
                size: size,
                strokeWidth: 22,
                color: Colors.transparent,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF8A65), Color(0xFFFF3B30)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedCounter(
                    value: remaining,
                    fontSize: size * 0.18,
                    fontWeight: FontWeight.w900,
                  ),
                  Text(
                    'Remaining',
                    style: GoogleFonts.inter(
                      fontSize: size * 0.05,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _EatenBurnedColumn(
                        label: 'Eaten',
                        value: consumed,
                        color: const Color(0xFFFF6B35),
                        size: size,
                        icon: Icons.local_dining_rounded,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          '•',
                          style: TextStyle(
                            fontSize: size * 0.06,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                      _EatenBurnedColumn(
                        label: 'Burned',
                        value: burned,
                        color: const Color(0xFFFF3B30),
                        size: size,
                        icon: Icons.local_fire_department_rounded,
                      ),
                    ],
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

class AnimatedCounter extends StatelessWidget {
  final int value;
  final double fontSize;
  final FontWeight fontWeight;

  const AnimatedCounter({
    required this.value,
    required this.fontSize,
    required this.fontWeight,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (context, val, _) {
        return Text(
          val.toString(),
          style: GoogleFonts.inter(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: const Color(0xFF1A1A1A),
            height: 1,
          ),
        );
      },
    );
  }
}

class _EatenBurnedColumn extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final double size;
  final IconData? icon;

  const _EatenBurnedColumn({
    required this.label,
    required this.value,
    required this.color,
    required this.size,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedCounter(
              value: value,
              fontSize: size * 0.07,
              fontWeight: FontWeight.bold,
            ),
            if (icon != null) ...[
              const SizedBox(width: 4),
              Icon(icon, color: color, size: size * 0.07),
            ],
          ],
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: size * 0.04,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
