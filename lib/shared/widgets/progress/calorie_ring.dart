import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
          height: size + 140, // +20px de folga pro espaçamento novo
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedCaloriesRing(
                progress: (consumed + burned) / goal.clamp(1, double.infinity),
                size: size,
              ),

              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Remaining gigante
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

                  // ←←← AQUI É O AJUSTE QUE VOCÊ QUERIA →→→
                  const SizedBox(
                    height: 32,
                  ), // era 20 → agora 32 (espaço perfeito)

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _EatenBurnedColumn(
                        label: 'Eaten',
                        value: consumed,
                        color: const Color(0xFFFF6B35),
                        size: size,
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
                        showFire: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: consumed == 0 && burned == 0
                          ? const Color(0xFFFFF3E0)
                          : const Color(0xFFE8F5E8),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      consumed == 0 && burned == 0
                          ? 'Now: Fasting'
                          : 'Keep going!',
                      style: GoogleFonts.inter(
                        fontSize: size * 0.04,
                        fontWeight: FontWeight.w600,
                        color: consumed == 0 && burned == 0
                            ? const Color(0xFFFF8A65)
                            : const Color(0xFF4CAF50),
                      ),
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

// =======================================
// 1. Anel com animação suave
// =======================================
class AnimatedCaloriesRing extends StatelessWidget {
  final double progress;
  final double size;

  const AnimatedCaloriesRing({
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
          painter: _CaloriesRingPainter(
            progress: value.clamp(0.0, 1.0),
            strokeWidth: 22,
          ),
        );
      },
    );
  }
}

// =======================================
// 2. Contador que sobe bonitinho
// =======================================
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

// =======================================
// 3. Coluna Eaten / Burned reutilizável
// =======================================
class _EatenBurnedColumn extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final double size;
  final bool showFire;

  const _EatenBurnedColumn({
    required this.label,
    required this.value,
    required this.color,
    required this.size,
    this.showFire = false,
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
            if (showFire) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.local_fire_department,
                color: color,
                size: size * 0.07,
              ),
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

// =======================================
// 4. O painter do anel (mesmo de antes)
// =======================================
class _CaloriesRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  _CaloriesRingPainter({required this.progress, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = Colors.grey[200]!.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFF8A65), Color(0xFFFF3B30)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CaloriesRingPainter old) =>
      old.progress != progress;
}
