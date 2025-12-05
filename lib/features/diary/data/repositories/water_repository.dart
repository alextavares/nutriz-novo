import 'package:isar/isar.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/value_objects/water_volume.dart';
import '../models/water_intake_schema.dart';

/// Repository for managing water intake data
class WaterRepository {
  final Isar _isar;

  WaterRepository(this._isar);

  /// Get water intake for a specific date
  Future<WaterVolume> getWaterForDate(DateTime date) async {
    final normalizedDate = _normalizeDate(date);
    
    final schema = await _isar.waterIntakeSchemas
        .filter()
        .dateEqualTo(normalizedDate)
        .findFirst();

    if (schema == null) {
      return const WaterVolume(0);
    }

    return WaterVolume(schema.volumeMl.toDouble());
  }

  /// Save water intake for a specific date
  Future<void> saveWater(DateTime date, WaterVolume volume) async {
    final normalizedDate = _normalizeDate(date);
    
    await _isar.writeTxn(() async {
      // Check if record exists
      final existing = await _isar.waterIntakeSchemas
          .filter()
          .dateEqualTo(normalizedDate)
          .findFirst();

      if (existing != null) {
        // Update existing record
        existing.volumeMl = volume.valueMl.toInt();
        existing.updatedAt = DateTime.now();
        await _isar.waterIntakeSchemas.put(existing);
      } else {
        // Create new record
        final schema = WaterIntakeSchema()
          ..date = normalizedDate
          ..volumeMl = volume.valueMl.toInt()
          ..goalMl = 2000 // Default goal
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now();
        
        await _isar.waterIntakeSchemas.put(schema);
      }
    });
  }

  /// Add water to existing intake for a specific date
  Future<void> addWater(DateTime date, int amountMl) async {
    final current = await getWaterForDate(date);
    final newVolume = WaterVolume(current.valueMl + amountMl);
    await saveWater(date, newVolume);
  }

  /// Reset water intake for a specific date
  Future<void> resetWater(DateTime date) async {
    await saveWater(date, const WaterVolume(0));
  }

  /// Get water intake for a date range
  Future<List<WaterIntakeSchema>> getWaterInRange(
    DateTime start,
    DateTime end,
  ) async {
    final normalizedStart = _normalizeDate(start);
    final normalizedEnd = _normalizeDate(end);

    return await _isar.waterIntakeSchemas
        .filter()
        .dateBetween(normalizedStart, normalizedEnd)
        .sortByDate()
        .findAll();
  }

  /// Get water goal for a specific date
  Future<int> getGoalForDate(DateTime date) async {
    final normalizedDate = _normalizeDate(date);
    
    final schema = await _isar.waterIntakeSchemas
        .filter()
        .dateEqualTo(normalizedDate)
        .findFirst();

    return schema?.goalMl ?? 2000; // Default 2L
  }

  /// Update water goal for a specific date
  Future<void> updateGoal(DateTime date, int goalMl) async {
    final normalizedDate = _normalizeDate(date);
    
    await _isar.writeTxn(() async {
      final existing = await _isar.waterIntakeSchemas
          .filter()
          .dateEqualTo(normalizedDate)
          .findFirst();

      if (existing != null) {
        existing.goalMl = goalMl;
        existing.updatedAt = DateTime.now();
        await _isar.waterIntakeSchemas.put(existing);
      } else {
        // Create new record with custom goal
        final schema = WaterIntakeSchema()
          ..date = normalizedDate
          ..volumeMl = 0
          ..goalMl = goalMl
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now();
        
        await _isar.waterIntakeSchemas.put(schema);
      }
    });
  }

  /// Normalize date to remove time component
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
