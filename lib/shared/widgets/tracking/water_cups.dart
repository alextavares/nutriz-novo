import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WaterCups extends StatelessWidget {
  final int currentMl;
  final int goalMl;
  final Function(int) onAdd;

  const WaterCups({
    super.key,
    required this.currentMl,
    required this.goalMl,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate filled cups (assuming 250ml per cup, max 8 cups)
    final cupsFilled = (currentMl / 250).floor();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(8, (index) {
        final isFilled = index < cupsFilled;
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onAdd(250);
          },
          child: _buildCup(isFilled),
        );
      }),
    );
  }

  Widget _buildCup(bool isFilled) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      width: 32,
      height: 40,
      decoration: BoxDecoration(
        color: isFilled
            ? Colors.blue.withValues(alpha: 0.2)
            : Colors.transparent,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(4),
          bottom: Radius.circular(8),
        ),
        border: Border.all(color: Colors.blue, width: 2),
      ),
      child: isFilled
          ? ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(2),
                bottom: Radius.circular(6),
              ),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    color: Colors.blue,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  // Simple wave effect simulation could go here
                ],
              ),
            )
          : null,
    );
  }
}
