import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/value_objects/water_volume.dart';

class WaterTrackerCardImproved extends StatelessWidget {
  final WaterVolume currentVolume;
  final int goalMl;
  final Function(int) onAdd;
  final Function(int)? onRemove; // Optional
  final VoidCallback? onReset; // Optional

  const WaterTrackerCardImproved({
    super.key,
    required this.currentVolume,
    required this.goalMl,
    required this.onAdd,
    this.onRemove,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentVolume.valueMl / goalMl).clamp(0.0, 1.0);
    final glassesGoal = 8; // 8 glasses of 250ml = 2000ml
    final glassesFilled = (currentVolume.valueMl / 250).floor().clamp(
      0,
      glassesGoal,
    );
    final hasWater = currentVolume.valueMl > 0;

    // Debug
    print(
      '💧 Water: ${currentVolume.valueMl}ml | hasWater: $hasWater | onRemove: ${onRemove != null}',
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: hasWater
            ? Border.all(color: Colors.blue.withOpacity(0.3), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: hasWater
                ? Colors.blue.withOpacity(0.12)
                : Colors.blue.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
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
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),

          // Water Glasses Visual
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Goal Label
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Goal: ${(goalMl / 1000).toStringAsFixed(2)} Liters',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Glasses Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    glassesGoal,
                    (index) => _WaterGlass(
                      isFilled: index < glassesFilled,
                      onTap: () => onAdd(250),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Current Volume Display
                Text(
                  '${(currentVolume.valueMl / 1000).toStringAsFixed(2)} L',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Quick Add/Remove Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Remove buttons (só mostra se tem água)
                if (hasWater && onRemove != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _QuickRemoveButton(
                          amount: 250,
                          label: '-250ml',
                          onTap: () => onRemove!(250),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickRemoveButton(
                          amount: 500,
                          label: '-500ml',
                          onTap: () => onRemove!(500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // Add buttons
                Row(
                  children: [
                    Expanded(
                      child: _QuickAddButton(
                        amount: 250,
                        label: '+250ml',
                        icon: Icons.local_cafe_rounded,
                        onTap: () => onAdd(250),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickAddButton(
                        amount: 500,
                        label: '+500ml',
                        icon: Icons.water_drop_outlined,
                        onTap: () => onAdd(500),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterGlass extends StatefulWidget {
  final bool isFilled;
  final VoidCallback onTap;

  const _WaterGlass({required this.isFilled, required this.onTap});

  @override
  State<_WaterGlass> createState() => _WaterGlassState();
}

class _WaterGlassState extends State<_WaterGlass>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fillAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    if (widget.isFilled) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_WaterGlass oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFilled != oldWidget.isFilled) {
      if (widget.isFilled) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _fillAnimation,
        builder: (context, child) {
          return CustomPaint(
            size: const Size(30, 40),
            painter: _GlassPainter(
              fillLevel: _fillAnimation.value,
              isFilled: widget.isFilled,
            ),
          );
        },
      ),
    );
  }
}

class _GlassPainter extends CustomPainter {
  final double fillLevel;
  final bool isFilled;

  _GlassPainter({required this.fillLevel, required this.isFilled});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = isFilled
          ? Colors.blue.withOpacity(0.3)
          : Colors.grey.withOpacity(0.1);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = isFilled ? Colors.blue : Colors.grey.withOpacity(0.3);

    // Draw glass outline (trapezoid)
    final path = Path()
      ..moveTo(size.width * 0.2, 0) // Top left
      ..lineTo(size.width * 0.8, 0) // Top right
      ..lineTo(size.width, size.height) // Bottom right
      ..lineTo(0, size.height) // Bottom left
      ..close();

    // Fill from bottom
    if (fillLevel > 0) {
      final fillPath = Path()
        ..moveTo(0, size.height)
        ..lineTo(
          size.width * 0.2 * (1 - fillLevel),
          size.height - (size.height * fillLevel),
        )
        ..lineTo(
          size.width - (size.width * 0.2 * (1 - fillLevel)),
          size.height - (size.height * fillLevel),
        )
        ..lineTo(size.width, size.height)
        ..close();

      canvas.drawPath(fillPath, paint);
    }

    // Draw border
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(_GlassPainter oldDelegate) {
    return oldDelegate.fillLevel != fillLevel ||
        oldDelegate.isFilled != isFilled;
  }
}

class _QuickAddButton extends StatelessWidget {
  final int amount;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickAddButton({
    required this.amount,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Remove Button Widget (Discrete/Ghost style)
class _QuickRemoveButton extends StatelessWidget {
  final int amount;
  final String label;
  final VoidCallback onTap;

  const _QuickRemoveButton({
    required this.amount,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.remove_circle_outline,
                size: 16,
                color: Colors.grey[400],
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
