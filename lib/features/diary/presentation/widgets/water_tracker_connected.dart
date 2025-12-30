import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/water_providers.dart';
import '../widgets/water_tracker_card_improved.dart';

/// Widget conectado que gerencia persistência do Water Tracker
class WaterTrackerConnected extends ConsumerWidget {
  final DateTime date;

  const WaterTrackerConnected({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch da água para a data específica
    final waterStream = ref.watch(waterIntakeByDateProvider(date));
    final goal = ref.watch(waterGoalProvider);

    return waterStream.when(
      data: (waterVolume) {
        return WaterTrackerCardImproved(
          currentVolume: waterVolume,
          goalMl: goal,
          onAdd: (amountMl) {
            // Adiciona água e salva no banco (sem await para não travar UI)
            ref.read(waterNotifierProvider.notifier).addWater(
                  date: date,
                  amountMl: amountMl,
                );
          },
          onRemove: (amountMl) {
            // Remove água (pode ficar negativo, mas clampa no card)
            ref.read(waterNotifierProvider.notifier).addWater(
                  date: date,
                  amountMl: -amountMl, // Negativo para remover
                );
          },
          onReset: () {
            // Reseta para 0
            ref.read(waterNotifierProvider.notifier).resetWater(date);
          },
        );
      },
      loading: () => const SizedBox(
        height: 300,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Container(
        padding: const EdgeInsets.all(16),
        child: Text('Erro ao carregar dados de água: $error'),
      ),
    );
  }
}
