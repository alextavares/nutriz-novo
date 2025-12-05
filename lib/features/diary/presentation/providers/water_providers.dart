import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/value_objects/water_volume.dart';
import '../../../../features/gamification/presentation/providers/gamification_providers.dart';
import '../../data/repositories/water_repository.dart';

/// Provider for WaterRepository
final waterRepositoryProvider = Provider<WaterRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return WaterRepository(isar);
});

/// Provider for water goal (constant for now)
final waterGoalProvider = Provider<int>((ref) => 2000);

/// Provider for water intake by date
final waterIntakeByDateProvider = FutureProvider.family<WaterVolume, DateTime>(
  (ref, date) async {
    final repo = ref.watch(waterRepositoryProvider);
    return await repo.getWaterForDate(date);
  },
);

/// Notifier for managing water intake with date support
class WaterNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> addWater({
    required DateTime date,
    required int amountMl,
  }) async {
    final repo = ref.read(waterRepositoryProvider);
    await repo.addWater(date, amountMl);
    
    // Refresh provider (mais suave que invalidate)
    ref.refresh(waterIntakeByDateProvider(date));
  }

  Future<void> setWater({
    required DateTime date,
    required WaterVolume volume,
  }) async {
    final repo = ref.read(waterRepositoryProvider);
    await repo.saveWater(date, volume);
    
    // Refresh provider (mais suave que invalidate)
    ref.refresh(waterIntakeByDateProvider(date));
  }

  Future<void> resetWater(DateTime date) async {
    final repo = ref.read(waterRepositoryProvider);
    await repo.resetWater(date);
    
    // Refresh provider (mais suave que invalidate)
    ref.refresh(waterIntakeByDateProvider(date));
  }
}

/// Provider for WaterNotifier
final waterNotifierProvider = NotifierProvider<WaterNotifier, void>(
  WaterNotifier.new,
);
