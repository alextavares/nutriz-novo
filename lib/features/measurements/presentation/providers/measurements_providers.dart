import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../data/repositories/measurements_repository.dart';
import '../../data/models/measurement_schemas.dart';
import '../../domain/entities/measurement.dart';

// Provider for Isar (from gamification)
final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('isarProvider must be overridden');
});

// Repository provider
final measurementsRepositoryProvider = Provider<MeasurementsRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return MeasurementsRepository(isar);
});

// Get measurements by type
final measurementsByTypeProvider = FutureProvider.family<List<Measurement>, String>(
  (ref, type) async {
    final repository = ref.watch(measurementsRepositoryProvider);
    return await repository.getMeasurementsByType(type);
  },
);

// Get latest measurement
final latestMeasurementProvider = FutureProvider.family<Measurement?, String>(
  (ref, type) async {
    final repository = ref.watch(measurementsRepositoryProvider);
    return await repository.getLatestMeasurement(type);
  },
);

// Get last N measurements
final lastNMeasurementsProvider = FutureProvider.family<List<Measurement>, MeasurementQuery>(
  (ref, query) async {
    final repository = ref.watch(measurementsRepositoryProvider);
    return await repository.getLastNMeasurements(query.type, query.count);
  },
);

// Get stats
final measurementStatsProvider = FutureProvider.family<MeasurementStats, String>(
  (ref, type) async {
    final repository = ref.watch(measurementsRepositoryProvider);
    return await repository.getStats(type);
  },
);

// Settings provider for unit preferences
final unitPreferenceProvider = StateProvider<bool>((ref) => true); // true = metric (kg), false = imperial (lb)

class MeasurementQuery {
  final String type;
  final int count;

  MeasurementQuery(this.type, this.count);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeasurementQuery &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          count == other.count;

  @override
  int get hashCode => type.hashCode ^ count.hashCode;
}
