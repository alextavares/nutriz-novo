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
    final padding = const EdgeInsets.fromLTRB(18, 12, 18, 24);
    final rect = padding.deflateRect(Offset.zero & size);

    final x0 = rect.left + 24;
    final x1 = rect.right - 8;
    final y0 = rect.bottom - 20;
    final yTop = rect.top + 10;

    final axisPaint = Paint()
      ..color =
          const Color(0xFFE5E7EB) // Very light grey
      ..strokeWidth = 1.5
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
      canvas.drawLine(Offset(x1, y0), Offset(x1 - 8, y0 - 5), axisPaint);
      canvas.drawLine(Offset(x1, y0), Offset(x1 - 8, y0 + 5), axisPaint);
      canvas.drawLine(Offset(x0, yTop), Offset(x0 - 5, yTop + 8), axisPaint);
      canvas.drawLine(Offset(x0, yTop), Offset(x0 + 5, yTop + 8), axisPaint);
    }

    // Wave points (yo-yo effect).
    final width = (x1 - x0);
    final height = (y0 - yTop);

    // Helper to map relative coords (0..1) to screen coords
    Offset p(double t, double y) => Offset(x0 + width * t, yTop + height * y);

    // "Super-smooth" sine-wave points
    // y=0 is top, y=1 is bottom
    final start = p(0.0, 0.50);
    final trough1 = p(0.18, 0.85); // 1st diet
    final peak1 = p(0.33, 0.45); // Rebound
    final trough2 = p(0.50, 0.82); // 2nd diet
    final peak2 = p(0.67, 0.40); // Rebound
    final trough3 = p(0.83, 0.78); // 3rd diet
    final peak3 = p(1.0, 0.22); // Final high

    // Tension for rounder curves (higher = rounder/wider turns)
    const tensionX = 0.12;

    final wave = Path()
      ..moveTo(start.dx, start.dy)
      // Dip to Trough 1
      ..cubicTo(
        start.dx + width * tensionX,
        start.dy + height * 0.2,
        trough1.dx - width * tensionX,
        trough1.dy - height * 0.02,
        trough1.dx,
        trough1.dy,
      )
      // Rise to Peak 1
      ..cubicTo(
        trough1.dx + width * tensionX,
        trough1.dy - height * 0.02,
        peak1.dx - width * tensionX,
        peak1.dy + height * 0.05,
        peak1.dx,
        peak1.dy,
      )
      // Dip to Trough 2
      ..cubicTo(
        peak1.dx + width * tensionX,
        peak1.dy + height * 0.05,
        trough2.dx - width * tensionX,
        trough2.dy - height * 0.02,
        trough2.dx,
        trough2.dy,
      )
      // Rise to Peak 2
      ..cubicTo(
        trough2.dx + width * tensionX,
        trough2.dy - height * 0.02,
        peak2.dx - width * tensionX,
        peak2.dy + height * 0.05,
        peak2.dx,
        peak2.dy,
      )
      // Dip to Trough 3
      ..cubicTo(
        peak2.dx + width * tensionX,
        peak2.dy + height * 0.05,
        trough3.dx - width * tensionX,
        trough3.dy - height * 0.02,
        trough3.dx,
        trough3.dy,
      )
      // Rise to Final Peak
      ..cubicTo(
        trough3.dx + width * tensionX,
        trough3.dy - height * 0.02,
        peak3.dx - width * 0.15,
        peak3.dy + height * 0.1,
        peak3.dx,
        peak3.dy,
      );

    final fillPath = Path.from(wave)
      ..lineTo(peak3.dx, y0)
      ..lineTo(start.dx, y0)
      ..close();

    final redPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final gradientChoice = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0x66EF4444), // Red ~40%
        Color(0x00EF4444), // Transparent
      ],
      stops: [0.0, 0.9],
    );

    // Draw fill first
    if (curveProgress > 0) {
      final metric = wave.computeMetrics().isEmpty
          ? null
          : wave.computeMetrics();
      if (metric != null) {
        final first = metric.first;
        final length = first.length * curveProgress.clamp(0.0, 1.0);

        // Correct Fill approximation
        final currentPos = first.getTangentForOffset(length)?.position;
        if (currentPos != null) {
          canvas.save();
          // Clip to current progress width
          canvas.clipRect(Rect.fromLTRB(x0, yTop, currentPos.dx, y0));

          final fillPaint = Paint()
            ..shader = gradientChoice.createShader(rect)
            ..style = PaintingStyle.fill;

          canvas.drawPath(fillPath, fillPaint);
          canvas.restore();
        }

        // Draw Stroke
        final partial = first.extractPath(0, length);
        canvas.drawPath(partial, redPaint);
      }
    }

    // Dots
    if (curveProgress > 0.05) _drawDot(canvas, start, const Color(0xFFEF4444));
    if (curveProgress > 0.35) _drawDot(canvas, peak1, const Color(0xFFEF4444));
    if (curveProgress > 0.65) _drawDot(canvas, peak2, const Color(0xFFEF4444));
    if (curveProgress > 0.95) _drawDot(canvas, peak3, const Color(0xFFEF4444));

    // Labels
    if (labelsOpacity > 0) {
      final alpha = (255 * labelsOpacity).round().clamp(0, 255);

      // Axis Labels
      _drawText(
        canvas,
        'Peso',
        Offset(rect.left + 5, yTop + 30),
        textStyle.copyWith(
          color: const Color(0xFF9CA3AF).withAlpha(alpha),
        ), // Light grey text
        rotate: -math.pi / 2,
      );
      _drawText(
        canvas,
        'Tempo',
        Offset(x1 - 14, y0 + 10),
        textStyle.copyWith(color: const Color(0xFF9CA3AF).withAlpha(alpha)),
      );

      // Diet labels under troughs
      final labelStyle = textStyle.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFEF4444).withAlpha(alpha), // Red text
      );

      _drawTextCentered(
        canvas,
        '1ª dieta',
        Offset(trough1.dx, trough1.dy + 8),
        labelStyle,
      );
      _drawTextCentered(
        canvas,
        '2ª dieta',
        Offset(trough2.dx, trough2.dy + 8),
        labelStyle,
      );
      _drawTextCentered(
        canvas,
        '3ª dieta',
        Offset(trough3.dx, trough3.dy + 8),
        labelStyle,
      );

      // "Restrictive diets" badge - positioned slightly offset from the last/middle wave
      final pillWidth = 110.0;
      final pillHeight = 22.0;
      final pillX = x1 - pillWidth - 10;
      final pillY = y0 - 45.0; // Floating above axis

      final pillRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(pillX, pillY, pillWidth, pillHeight),
        const Radius.circular(16),
      );
      final pillPaint = Paint()
        ..color = const Color(0xFFEF4444).withAlpha(alpha);

      canvas.drawRRect(pillRect, pillPaint);

      _drawText(
        canvas,
        'Dietas restritivas',
        Offset(pillX + 12, pillY + 4),
        textStyle.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
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
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, 4.0, fill);
    canvas.drawCircle(center, 4.0, stroke);
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
    )..layout(maxWidth: 200);

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    if (rotate != 0) canvas.rotate(rotate);
    painter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  void _drawTextCentered(
    Canvas canvas,
    String text,
    Offset center,
    TextStyle style,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 200);

    canvas.save();
    canvas.translate(center.dx - painter.width / 2, center.dy);
    painter.paint(canvas, Offset.zero);
    canvas.restore();
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

  @override
  bool shouldRepaint(covariant _RestrictiveDietsChartPainter oldDelegate) {
    return axisProgress != oldDelegate.axisProgress ||
        curveProgress != oldDelegate.curveProgress ||
        labelsOpacity != oldDelegate.labelsOpacity ||
        textStyle != oldDelegate.textStyle;
  }
}
