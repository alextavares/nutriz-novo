import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/value_objects/water_volume.dart';
import '../../../../shared/widgets/tracking/water_cups.dart';
import '../providers/diary_providers.dart';

class WaterSection extends ConsumerWidget {
  final WaterVolume currentVolume;

  const WaterSection({super.key, required this.currentVolume});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.water_drop,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Water Tracker',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${currentVolume.valueMl.toInt()} / 2000 ml',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Water Cups
          WaterCups(
            currentMl: currentVolume.valueMl.toInt(),
            goalMl: 2000,
            onAdd: (amount) {
              final newVolume = WaterVolume(currentVolume.valueMl + amount);
              ref.read(diaryNotifierProvider.notifier).updateWater(newVolume);
            },
          ),
          const SizedBox(height: AppSpacing.lg),

          // Add Button
          Center(
            child: TextButton(
              onPressed: () {
                final newVolume = WaterVolume(currentVolume.valueMl + 250);
                ref.read(diaryNotifierProvider.notifier).updateWater(newVolume);
              },
              child: Text(
                '+ 250ml',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
