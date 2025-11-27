import 'package:flutter/material.dart';

class WaterTracker extends StatelessWidget {
  final double currentIntake;
  final double goal;
  final Function(double) onAdd;

  const WaterTracker({
    super.key,
    required this.currentIntake,
    required this.goal,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final totalGlasses = (goal / 250).ceil();
    final currentGlasses = (currentIntake / 250).floor();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalGlasses, (index) {
            return IconButton(
              icon: Icon(
                index < currentGlasses
                    ? Icons.local_drink
                    : Icons.local_drink_outlined,
                color: Colors.blue,
              ),
              onPressed: () => onAdd(250),
            );
          }),
        ),
        TextButton(onPressed: () => onAdd(250), child: const Text('+ 250ml')),
      ],
    );
  }
}
