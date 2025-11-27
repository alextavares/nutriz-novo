import 'package:flutter/material.dart';

class FastingTimer extends StatelessWidget {
  final double progress;
  final String remainingTime;

  const FastingTimer({
    super.key,
    required this.progress,
    required this.remainingTime,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircularProgressIndicator(value: progress),
        Text(remainingTime),
      ],
    );
  }
}
