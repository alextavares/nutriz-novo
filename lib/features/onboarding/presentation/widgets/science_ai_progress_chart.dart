import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScienceAiProgressChart extends StatefulWidget {
  const ScienceAiProgressChart({super.key});

  @override
  State<ScienceAiProgressChart> createState() => _ScienceAiProgressChartState();
}

class _ScienceAiProgressChartState extends State<ScienceAiProgressChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
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
    final labelStyle = GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF111827),
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ScienceAiProgressChartPainter(
            progress: _progress.value,
            fadeIn: _fadeIn.value,
            labelStyle: labelStyle,
          ),
        );
      },
    );
  }
}

class _ScienceAiProgressChartPainter extends CustomPainter {
  final double progress;
  final double fadeIn;
  final TextStyle labelStyle;

  _ScienceAiProgressChartPainter({
    required this.progress,
    required this.fadeIn,
    required this.labelStyle,
  });

  static const _green = Color(0xFF22C55E);
  static const _greenDark = Color(0xFF16A34A);
  static const _axis = Color(0xFF111827);

  @override
  void paint(Canvas canvas, Size size) {
    final padding = const EdgeInsets.fromLTRB(18, 10, 18, 16);
    final rect = padding.deflateRect(Offset.zero & size);

    final axisY = rect.bottom - 28;
    final x0 = rect.left + 2;
    final x1 = rect.right - 2;

    // Points (normalized in the plot area).
    final plotTop = rect.top + 14;
    final plotBottom = axisY - 6;

    Offset p(double t, double y) {
      final x = x0 + (x1 - x0) * t;
      final yy = plotBottom - (plotBottom - plotTop) * y;
      return Offset(x, yy);
    }

    final points = <Offset>[
      p(0.02, 0.15),
      p(0.28, 0.14),
      p(0.62, 0.62),
      p(0.98, 0.82),
    ];

    // Axis baseline.
    final axisPaint = Paint()
      ..color = _axis.withOpacity(0.9 * fadeIn.clamp(0.0, 1.0))
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(x0, axisY), Offset(x1, axisY), axisPaint);

    // Line path (smooth).
    final linePath = _smoothPath(points);

    // Clip by progress along x to mimic "growing" chart.
    final clipX = x0 + (x1 - x0) * progress.clamp(0.0, 1.0);
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(x0 - 20, rect.top - 20, clipX, rect.bottom));

    // Fill under curve.
    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, axisY)
      ..lineTo(points.first.dx, axisY)
      ..close();
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_green.withOpacity(0.25), _green.withOpacity(0.06)],
      ).createShader(Rect.fromLTRB(x0, plotTop, x1, axisY));
    canvas.drawPath(fillPath, fillPaint);

    // Line.
    final linePaint = Paint()
      ..color = _greenDark
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(linePath, linePaint);

    canvas.restore();

    // Dots.
    for (var i = 0; i < points.length; i++) {
      final t = points[i].dx == x0 ? 0.0 : (points[i].dx - x0) / (x1 - x0);
      if (progress < t - 0.02) continue;
      final isLast = i == points.length - 1;
      if (isLast) {
        _drawCheckDot(canvas, points[i]);
      } else {
        _drawHollowDot(canvas, points[i]);
      }
    }

    // X labels.
    final labelsAlpha = (255 * fadeIn).round().clamp(0, 255);
    _drawText(
      canvas,
      '3 dias',
      Offset(points[1].dx - 14, axisY + 12),
      labelStyle.copyWith(color: labelStyle.color?.withAlpha(labelsAlpha)),
    );
    _drawText(
      canvas,
      '7 dias',
      Offset(points[2].dx - 14, axisY + 12),
      labelStyle.copyWith(color: labelStyle.color?.withAlpha(labelsAlpha)),
    );
    _drawText(
      canvas,
      '30 dias',
      Offset(points[3].dx - 22, axisY + 12),
      labelStyle.copyWith(color: labelStyle.color?.withAlpha(labelsAlpha)),
    );
  }

  Path _smoothPath(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = i == 0 ? points[i] : points[i - 1];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i + 2 < points.length ? points[i + 2] : p2;

      // Catmull-Rom to cubic approximation.
      final cp1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 6,
        p1.dy + (p2.dy - p0.dy) / 6,
      );
      final cp2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 6,
        p2.dy - (p3.dy - p1.dy) / 6,
      );
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 140);
    painter.paint(canvas, offset);
  }

  void _drawHollowDot(Canvas canvas, Offset center) {
    final fill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = _axis
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, 7.5, fill);
    canvas.drawCircle(center, 7.5, stroke);
  }

  void _drawCheckDot(Canvas canvas, Offset center) {
    final fill = Paint()
      ..color = _greenDark
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 8.5, fill);

    final check = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final a = Offset(center.dx - 3.5, center.dy + 0.5);
    final b = Offset(center.dx - 0.8, center.dy + 3.0);
    final c = Offset(center.dx + 4.5, center.dy - 3.5);
    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(c.dx, c.dy);
    canvas.drawPath(path, check);
  }

  @override
  bool shouldRepaint(covariant _ScienceAiProgressChartPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        fadeIn != oldDelegate.fadeIn ||
        labelStyle != oldDelegate.labelStyle;
  }
}
