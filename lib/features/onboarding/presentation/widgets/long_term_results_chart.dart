import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LongTermResultsChart extends StatefulWidget {
  const LongTermResultsChart({super.key});

  @override
  State<LongTermResultsChart> createState() => _LongTermResultsChartState();
}

class _LongTermResultsChartState extends State<LongTermResultsChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _axisProgress;
  late final Animation<double> _blackProgress;
  late final Animation<double> _redProgress;
  late final Animation<double> _labelsOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _axisProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.25, curve: Curves.easeOutCubic),
    );

    _blackProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.20, 0.78, curve: Curves.easeOutCubic),
    );

    _redProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.28, 0.90, curve: Curves.easeOutCubic),
    );

    _labelsOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.70, 1.0, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final chartHeight = math.min(constraints.maxHeight, 320.0);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: chartHeight,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _LongTermResultsChartPainter(
                      axisProgress: _axisProgress.value,
                      blackProgress: _blackProgress.value,
                      redProgress: _redProgress.value,
                      labelsOpacity: _labelsOpacity.value,
                      textStyle: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LongTermResultsChartPainter extends CustomPainter {
  final double axisProgress;
  final double blackProgress;
  final double redProgress;
  final double labelsOpacity;
  final TextStyle textStyle;

  _LongTermResultsChartPainter({
    required this.axisProgress,
    required this.blackProgress,
    required this.redProgress,
    required this.labelsOpacity,
    required this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 10);
    final rect = padding.deflateRect(Offset.zero & size);

    final axisY = rect.top + rect.height * 0.76;
    final x0 = rect.left + 12;
    final x1 = rect.right - 12;

    final start = Offset(x0, rect.top + rect.height * 0.36);
    final endBlack = Offset(x1, axisY);
    final endRed = Offset(x1, rect.top + rect.height * 0.32);

    final axisPaint = Paint()
      ..color = const Color(0xFF111827)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final guidePaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final blackPaint = Paint()
      ..color = const Color(0xFF111827)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final redPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Axis baseline (Month line).
    final axisPath = Path()
      ..moveTo(x0, axisY)
      ..lineTo(x1, axisY);
    _drawPartialPath(canvas, axisPath, axisPaint, axisProgress);

    // Left guide line + start dot.
    final guidePath = Path()
      ..moveTo(x0, start.dy)
      ..lineTo(x0, axisY);
    _drawPartialPath(canvas, guidePath, guidePaint, axisProgress);

    final startDot = _dotPaint(center: start, radius: 12);
    if (axisProgress > 0.02) {
      canvas.drawCircle(start, 12, startDot.fill);
      canvas.drawCircle(start, 12, startDot.stroke);
    }

    // Curves.
    final blackPath = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        start.dx + (x1 - x0) * 0.28,
        start.dy + rect.height * 0.08,
        start.dx + (x1 - x0) * 0.56,
        axisY - rect.height * 0.06,
        endBlack.dx,
        endBlack.dy,
      );
    _drawPartialPath(canvas, blackPath, blackPaint, blackProgress);

    final redPath = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        start.dx + (x1 - x0) * 0.32,
        start.dy + rect.height * 0.18,
        start.dx + (x1 - x0) * 0.58,
        axisY + rect.height * 0.12,
        endRed.dx,
        endRed.dy,
      );
    _drawPartialPath(canvas, redPath, redPaint, redProgress);

    // End dot for the "DietAI" line.
    if (blackProgress > 0.98) {
      final endDot = _dotPaint(center: endBlack, radius: 12);
      canvas.drawCircle(endBlack, 12, endDot.fill);
      canvas.drawCircle(endBlack, 12, endDot.stroke);
    }

    // Labels (fade in near the end).
    if (labelsOpacity > 0) {
      final alpha = (255 * labelsOpacity).round().clamp(0, 255);
      _drawText(
        canvas,
        'Seu peso',
        Offset(rect.left, rect.top + 6),
        textStyle.copyWith(color: const Color(0xFF111827).withAlpha(alpha)),
      );
      _drawText(
        canvas,
        'Dieta tradicional',
        Offset(rect.right - 130, rect.top + 6),
        textStyle.copyWith(color: const Color(0xFFEF4444).withAlpha(alpha)),
      );
      _drawText(
        canvas,
        'Mês 1',
        Offset(rect.left, axisY + 14),
        textStyle.copyWith(color: const Color(0xFF111827).withAlpha(alpha)),
      );
      _drawText(
        canvas,
        'Nutriz - Mês 6',
        Offset(rect.right - 120, axisY + 14),
        textStyle.copyWith(color: const Color(0xFF22C55E).withAlpha(alpha)),
      );
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 200);
    painter.paint(canvas, offset);
  }

  void _drawPartialPath(
    Canvas canvas,
    Path path,
    Paint paint,
    double progress,
  ) {
    if (progress <= 0) return;
    final metric = path.computeMetrics().isEmpty ? null : path.computeMetrics();
    if (metric == null) return;
    final first = metric.first;
    final length = first.length * progress.clamp(0.0, 1.0);
    canvas.drawPath(first.extractPath(0, length), paint);
  }

  _DotPaint _dotPaint({required Offset center, required double radius}) {
    final fill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final stroke = Paint()
      ..color = const Color(0xFF111827)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    return _DotPaint(fill: fill, stroke: stroke);
  }

  @override
  bool shouldRepaint(covariant _LongTermResultsChartPainter oldDelegate) {
    return axisProgress != oldDelegate.axisProgress ||
        blackProgress != oldDelegate.blackProgress ||
        redProgress != oldDelegate.redProgress ||
        labelsOpacity != oldDelegate.labelsOpacity ||
        textStyle != oldDelegate.textStyle;
  }
}

class _DotPaint {
  final Paint fill;
  final Paint stroke;

  const _DotPaint({required this.fill, required this.stroke});
}
