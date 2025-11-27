import 'package:flutter/material.dart';

class NutrizButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const NutrizButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: Theme.of(context).elevatedButtonTheme.style,
      child: Text(label),
    );
  }
}
