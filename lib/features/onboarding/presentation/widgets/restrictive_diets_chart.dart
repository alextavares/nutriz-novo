import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RestrictiveDietsChart extends StatefulWidget {
  const RestrictiveDietsChart({super.key});

  @override
  State<RestrictiveDietsChart> createState() => _RestrictiveDietsChartState();
}

class _RestrictiveDietsChartState extends State<RestrictiveDietsChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _axisProgress;
  late final Animation<double> _curveProgress;
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
      curve: const Interval(0.0, 0.28, curve: Curves.easeOutCubic),
    );

    _curveProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.18, 0.86, curve: Curves.easeOutCubic),
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
        return SizedBox(
          height: chartHeight,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _RestrictiveDietsChartPainter(
                  axisProgress: _axisProgress.value,
                  curveProgress: _curveProgress.value,
                  labelsOpacity: _labelsOpacity.value,
                  textStyle: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _RestrictiveDietsChartPainter extends CustomPainter {
  final double axisProgress;
  final double curveProgress;
  final double labelsOpacity;
  final TextStyle textStyle;

  _RestrictiveDietsChartPainter({
    required this.axisProgress,
    required this.curveProgress,
    required this.labelsOpacity,
    required this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final padding = const EdgeInsets.fromLTRB(18, 8, 18, 16);
    final rect = padding.deflateRect(Offset.zero & size);

    final x0 = rect.left + 18;
    final x1 = rect.right - 8;
    final y0 = rect.bottom - 16;
    final yTop = rect.top + 10;

    final axisPaint = Paint()
      ..color = const Color(0xFF9CA3AF)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Axes with arrow heads.
    final xAxis = Path()
      ..moveTo(x0, y0)
      ..lineTo(x1, y0);
    final yAxis = Path()
      ..moveTo(x0, y0)
      ..lineTo(x0, yTop);

    _drawPartialPath(canvas, xAxis, axisPaint, axisProgress);
    _drawPartialPath(canvas, yAxis, axisPaint, axisProgress);

    if (axisProgress > 0.9) {
      // Arrow heads.
      canvas.drawLine(
        Offset(x1, y0),
        Offset(x1 - 10, y0 - 6),
        axisPaint,
      );
      canvas.drawLine(
        Offset(x1, y0),
        Offset(x1 - 10, y0 + 6),
        axisPaint,
      );

      canvas.drawLine(
        Offset(x0, yTop),
        Offset(x0 - 6, yTop + 10),
        axisPaint,
      );
      canvas.drawLine(
        Offset(x0, yTop),
        Offset(x0 + 6, yTop + 10),
        axisPaint,
      );
    }

    final redPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = const Color(0xFFEF4444).withOpacity(0.15)
      ..style = PaintingStyle.fill;

    // Wave points (yo-yo effect).
    final width = (x1 - x0);
    final height = (y0 - yTop);

    Offset p(double t, double y) => Offset(x0 + width * t, yTop + height * y);

    final start = p(0.04, 0.42);
    final trough1 = p(0.16, 0.72);
    final peak1 = p(0.28, 0.46);
    final trough2 = p(0.42, 0.70);
    final peak2 = p(0.56, 0.40);
    final trough3 = p(0.70, 0.74);
    final peak3 = p(0.84, 0.38);
    final end = p(0.95, 0.30);

    final wave = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        start.dx + width * 0.06,
        start.dy + height * 0.30,
        trough1.dx - width * 0.06,
        trough1.dy - height * 0.02,
        trough1.dx,
        trough1.dy,
      )
      ..cubicTo(
        trough1.dx + width * 0.08,
        trough1.dy - height * 0.40,
        peak1.dx - width * 0.06,
        peak1.dy + height * 0.10,
        peak1.dx,
        peak1.dy,
      )
      ..cubicTo(
        peak1.dx + width * 0.06,
        peak1.dy + height * 0.35,
        trough2.dx - width * 0.06,
        trough2.dy - height * 0.02,
        trough2.dx,
        trough2.dy,
      )
      ..cubicTo(
        trough2.dx + width * 0.08,
        trough2.dy - height * 0.42,
        peak2.dx - width * 0.06,
        peak2.dy + height * 0.10,
        peak2.dx,
        peak2.dy,
      )
      ..cubicTo(
        peak2.dx + width * 0.06,
        peak2.dy + height * 0.38,
        trough3.dx - width * 0.06,
        trough3.dy - height * 0.02,
        trough3.dx,
        trough3.dy,
      )
      ..cubicTo(
        trough3.dx + width * 0.08,
        trough3.dy - height * 0.50,
        peak3.dx - width * 0.06,
        peak3.dy + height * 0.10,
        peak3.dx,
        peak3.dy,
      )
      ..cubicTo(
        peak3.dx + width * 0.04,
        peak3.dy - height * 0.10,
        end.dx - width * 0.04,
        end.dy + height * 0.10,
        end.dx,
        end.dy,
      );

    final filled = Path.from(wave)
      ..lineTo(end.dx, y0)
      ..lineTo(start.dx, y0)
      ..close();

    if (curveProgress > 0) {
      final metric = wave.computeMetrics().isEmpty ? null : wave.computeMetrics();
      if (metric != null) {
        final first = metric.first;
        final length = first.length * curveProgress.clamp(0.0, 1.0);
        final partial = first.extractPath(0, length);
        // Fill: approximate by clipping full fill to the current x.
        final currentPos = first.getTangentForOffset(length)?.position;
        if (currentPos != null) {
          canvas.save();
          canvas.clipRect(Rect.fromLTRB(rect.left, rect.top, currentPos.dx, rect.bottom));
          canvas.drawPath(filled, fillPaint);
          canvas.restore();
        }
        canvas.drawPath(partial, redPaint);
      }
    }

    // Dots.
    if (curveProgress > 0.15) {
      _drawDot(canvas, start, const Color(0xFFEF4444));
    }
    if (curveProgress > 0.35) {
      _drawDot(canvas, peak1, const Color(0xFFEF4444));
    }
    if (curveProgress > 0.55) {
      _drawDot(canvas, peak2, const Color(0xFFEF4444));
    }
    if (curveProgress > 0.78) {
      _drawDot(canvas, peak3, const Color(0xFFEF4444));
    }
    if (curveProgress > 0.95) {
      _drawDot(canvas, end, const Color(0xFFEF4444));
    }

    // Labels.
    if (labelsOpacity > 0) {
      final alpha = (255 * labelsOpacity).round().clamp(0, 255);
      _drawText(
        canvas,
        'Peso',
        Offset(rect.left, yTop + 40),
        textStyle.copyWith(color: const Color(0xFF6B7280).withAlpha(alpha)),
        rotate: -math.pi / 2,
      );
      _drawText(
        canvas,
        'Tempo',
        Offset(x0 + 26, y0 + 10),
        textStyle.copyWith(color: const Color(0xFF6B7280).withAlpha(alpha)),
      );

      final small = textStyle.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: const Color(0xFFEF4444).withAlpha(alpha),
      );

      _drawText(canvas, '1ª dieta', Offset(trough1.dx - 18, y0 - 10), small);
      _drawText(canvas, '2ª dieta', Offset(trough2.dx - 18, y0 - 10), small);
      _drawText(canvas, '3ª dieta', Offset(trough3.dx - 18, y0 - 10), small);

      final pillRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x1 - 122, y0 - 26, 118, 22),
        const Radius.circular(999),
      );
      final pillPaint = Paint()
        ..color = const Color(0xFFEF4444).withAlpha(alpha);
      canvas.drawRRect(pillRect, pillPaint);
      _drawText(
        canvas,
        'Dietas restritivas',
        Offset(pillRect.left + 10, pillRect.top + 4),
        textStyle.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Colors.white.withAlpha(alpha),
        ),
      );
    }
  }

  void _drawDot(Canvas canvas, Offset center, Color color) {
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, 5.5, fill);
    canvas.drawCircle(center, 5.5, stroke);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    TextStyle style, {
    double rotate = 0,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 220);

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    if (rotate != 0) canvas.rotate(rotate);
    painter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  void _drawPartialPath(Canvas canvas, Path path, Paint paint, double progress) {
    if (progress <= 0) return;
    final metric = path.computeMetrics().isEmpty ? null : path.computeMetrics();
    if (metric == null) return;
    final first = metric.first;
    final length = first.length * progress.clamp(0.0, 1.0);
    canvas.drawPath(first.extractPath(0, length), paint);
  }

  @override
  bool shouldRepaint(covariant _RestrictiveDietsChartPainter oldDelegate) {
    return axisProgress != oldDelegate.axisProgress ||
        curveProgress != oldDelegate.curveProgress ||
        labelsOpacity != oldDelegate.labelsOpacity ||
        textStyle != oldDelegate.textStyle;
  }
}

