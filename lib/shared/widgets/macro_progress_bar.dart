import 'package:flutter/material.dart';

class MacroProgressBar extends StatelessWidget {
  final String label;
  final double value;
  final double total;
  final Color color;

  const MacroProgressBar({
    super.key,
    required this.label,
    required this.value,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label),
        LinearProgressIndicator(
          value: total > 0 ? value / total : 0,
          color: color,
        ),
      ],
    );
  }
}
