import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/water_providers.dart';

/// Water Tracker Card with persistence
/// Uses WaterNotifier to save/load water intake
class WaterTrackerCardPersistent extends ConsumerWidget {
  const WaterTrackerCardPersistent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waterState = ref.watch(waterNotifierProvider);

    return waterState.when(
      loading: () => _buildLoadingCard(),
      error: (error, stack) => _buildErrorCard(error.toString()),
      data: (currentVolume) {
        final goalMl = 2000; // Default goal
        final progress = (currentVolume.valueMl / goalMl).clamp(0.0, 1.0);
        final glassesGoal = 8;
        final glassesFilled =
            (currentVolume.valueMl / 250).floor().clamp(0, glassesGoal);
        final hasWater = currentVolume.valueMl > 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: hasWater
                ? Border.all(
                    color: Colors.blue.withOpacity(0.3),
                    width: 2,
                  )
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
                      style: GoogleFonts.inter(
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
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Glasses Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        glassesGoal,
                        (index) => _buildGlass(
                          index: index,
                          isFilled: index < glassesFilled,
                          isPartial: false,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Volume Display
                    Text(
                      '${(currentVolume.valueMl / 1000).toStringAsFixed(2)} L',
                      style: GoogleFonts.inter(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildAddButton(
                            context,
                            ref,
                            '☕ +250ml',
                            250,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildAddButton(
                            context,
                            ref,
                            '💧 +500ml',
                            500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlass({
    required int index,
    required bool isFilled,
    required bool isPartial,
  }) {
    return Container(
      width: 30,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(
          color: isFilled ? Colors.blue : Colors.grey[300]!,
          width: 2,
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(4),
        ),
        color: isFilled ? Colors.blue.withOpacity(0.2) : Colors.transparent,
      ),
      child: Stack(
        children: [
          if (isFilled)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.6),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(2),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddButton(
    BuildContext context,
    WidgetRef ref,
    String label,
    int amountMl,
  ) {
    return ElevatedButton(
      onPressed: () {
        ref.read(waterNotifierProvider.notifier).addWater(amountMl);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.withOpacity(0.1),
        foregroundColor: Colors.blue,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 300,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      height: 150,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'Error: $error',
          style: GoogleFonts.inter(
            color: Colors.red,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
