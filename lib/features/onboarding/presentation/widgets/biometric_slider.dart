import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Slider estilizado para entrada de valores biométricos (altura, peso)
class BiometricSlider extends StatefulWidget {
  final String label;
  final String unit;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  final Color? activeColor;
  final bool isInteger;

  const BiometricSlider({
    super.key,
    required this.label,
    required this.unit,
    required this.value,
    required this.min,
    required this.max,
    this.divisions = 100,
    required this.onChanged,
    this.activeColor,
    this.isInteger = true,
  });

  @override
  State<BiometricSlider> createState() => _BiometricSliderState();
}

class _BiometricSliderState extends State<BiometricSlider> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.activeColor ?? theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Label
        Text(
          widget.label,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 16),
        // Value display
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              widget.isInteger
                  ? widget.value.round().toString()
                  : widget.value.toStringAsFixed(1),
              style: theme.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 64,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.unit,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        // Custom Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.2),
            thumbColor: color,
            overlayColor: color.withOpacity(0.1),
            trackHeight: 8,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 16,
              elevation: 4,
            ),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 28),
          ),
          child: Slider(
            value: widget.value.clamp(widget.min, widget.max),
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            onChanged: (value) {
              HapticFeedback.selectionClick();
              widget.onChanged(value);
            },
          ),
        ),
        // Min/Max labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.isInteger ? widget.min.round() : widget.min.toStringAsFixed(1)} ${widget.unit}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
              Text(
                '${widget.isInteger ? widget.max.round() : widget.max.toStringAsFixed(1)} ${widget.unit}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Slider para taxa de perda/ganho de peso semanal
class WeeklyGoalSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const WeeklyGoalSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  String _getLabel(double value) {
    if (value < 0) {
      return 'Perder ${value.abs().toStringAsFixed(1)} kg/semana';
    } else if (value > 0) {
      return 'Ganhar ${value.toStringAsFixed(1)} kg/semana';
    }
    return 'Manter peso';
  }

  Color _getColor(BuildContext context, double value) {
    if (value < 0) {
      return Colors.orange;
    } else if (value > 0) {
      return Colors.blue;
    }
    return Theme.of(context).colorScheme.primary;
  }

  String _getDescription(double value) {
    final absValue = value.abs();
    if (value == 0) return 'Manter seu peso atual';
    if (absValue <= 0.25) return 'Ritmo leve e sustentável';
    if (absValue <= 0.5) return 'Ritmo recomendado';
    if (absValue <= 0.75) return 'Ritmo moderado';
    return 'Ritmo intenso';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getColor(context, value);

    return Column(
      children: [
        // Value display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                _getLabel(value),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getDescription(value),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.2),
            thumbColor: color,
            overlayColor: color.withOpacity(0.1),
            trackHeight: 8,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 16,
              elevation: 4,
            ),
          ),
          child: Slider(
            value: value,
            min: -1.0,
            max: 1.0,
            divisions: 20,
            onChanged: (newValue) {
              HapticFeedback.selectionClick();
              onChanged(newValue);
            },
          ),
        ),
        // Labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '-1 kg',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.orange.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Manter',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              Text(
                '+1 kg',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.blue.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
