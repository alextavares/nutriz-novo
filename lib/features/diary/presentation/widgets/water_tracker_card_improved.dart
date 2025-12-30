import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
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
    final glassesGoal = 8; // 8 glasses of 250ml = 2000ml
    final glassesFilled = (currentVolume.valueMl / 250).floor().clamp(
      0,
      glassesGoal,
    );
    final hasWater = currentVolume.valueMl > 0;

    // Debug
    // Debug
    // print(
    //   '💧 Water: ${currentVolume.valueMl}ml | hasWater: $hasWater | onRemove: ${onRemove != null}',
    // );

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: hasWater
            ? Border.all(
                color: AppColors.accent.withValues(alpha: 0.22),
                width: 1.5,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Meta: ${(goalMl / 1000).toStringAsFixed(2)} L',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  '${currentVolume.valueMl.toInt()} / $goalMl mL',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
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
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${(currentVolume.valueMl / 1000).toStringAsFixed(2)} L',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (hasWater && onRemove != null) ...[
              Row(
                children: [
                  Expanded(
                    child: _QuickRemoveButton(
                      label: '-250 mL',
                      onTap: () => onRemove!(250),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _QuickRemoveButton(
                      label: '-500 mL',
                      onTap: () => onRemove!(500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            Row(
              children: [
                Expanded(
                  child: _QuickAddButton(
                    label: '+250 mL',
                    icon: Icons.local_cafe_rounded,
                    onTap: () => onAdd(250),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _QuickAddButton(
                    label: '+500 mL',
                    icon: Icons.water_drop_outlined,
                    onTap: () => onAdd(500),
                  ),
                ),
              ],
            ),
          ],
        ),
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
          ? AppColors.accent.withValues(alpha: 0.3)
          : Colors.grey.withValues(alpha: 0.1);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = isFilled ? AppColors.accent : Colors.grey.withValues(alpha: 0.3);

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
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickAddButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent.withValues(alpha: 0.12),
        foregroundColor: AppColors.accent,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

// Remove Button Widget (Discrete/Ghost style)
class _QuickRemoveButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickRemoveButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.remove_circle_outline, size: 18),
      label: Text(label),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8),
        foregroundColor: AppColors.textSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.border),
        ),
        textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
