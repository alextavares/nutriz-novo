import 'package:isar/isar.dart';
import '../models/measurement_schemas.dart';
import '../../domain/entities/measurement.dart';

class MeasurementsRepository {
  final Isar isar;

  MeasurementsRepository(this.isar);

  // Save a measurement
  Future<int> saveMeasurement({
    required String type,
    required double value,
    required String unit,
    double? systolic,
    double? diastolic,
    String? notes,
  }) async {
    final measurement = MeasurementSchema()
      ..type = type
      ..value = value
      ..date = DateTime.now()
      ..unit = unit
      ..systolic = systolic
      ..diastolic = diastolic
      ..notes = notes;

    return await isar.writeTxn(() async {
      return await isar.measurementSchemas.put(measurement);
    });
  }

  // Get all measurements of a specific type
  Future<List<Measurement>> getMeasurementsByType(String type) async {
    final schemas = await isar.measurementSchemas
        .filter()
        .typeEqualTo(type)
        .sortByDateDesc()
        .findAll();

    return schemas.map(_schemaToEntity).toList();
  }

  // Get latest measurement of a specific type
  Future<Measurement?> getLatestMeasurement(String type) async {
    final schema = await isar.measurementSchemas
        .filter()
        .typeEqualTo(type)
        .sortByDateDesc()
        .findFirst();

    return schema != null ? _schemaToEntity(schema) : null;
  }

  // Get measurements in a date range
  Future<List<Measurement>> getMeasurementsInRange({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final schemas = await isar.measurementSchemas
        .filter()
        .typeEqualTo(type)
        .dateBetween(startDate, endDate)
        .sortByDateDesc()
        .findAll();

    return schemas.map(_schemaToEntity).toList();
  }

  // Get last N measurements of a type
  Future<List<Measurement>> getLastNMeasurements(
    String type,
    int count,
  ) async {
    final schemas = await isar.measurementSchemas
        .filter()
        .typeEqualTo(type)
        .sortByDateDesc()
        .limit(count)
        .findAll();

    return schemas.map(_schemaToEntity).toList();
  }

  // Delete a measurement
  Future<bool> deleteMeasurement(int id) async {
    return await isar.writeTxn(() async {
      return await isar.measurementSchemas.delete(id);
    });
  }

  // Update a measurement
  Future<void> updateMeasurement(int id, {
    double? value,
    String? notes,
  }) async {
    await isar.writeTxn(() async {
      final measurement = await isar.measurementSchemas.get(id);
      if (measurement != null) {
        if (value != null) measurement.value = value;
        if (notes != null) measurement.notes = notes;
        await isar.measurementSchemas.put(measurement);
      }
    });
  }

  // Get statistics for a measurement type
  Future<MeasurementStats> getStats(String type) async {
    final measurements = await getMeasurementsByType(type);
    
    if (measurements.isEmpty) {
      return MeasurementStats(
        count: 0,
        average: 0,
        min: 0,
        max: 0,
        latest: null,
        trend: 0,
      );
    }

    final values = measurements.map((m) => m.value).toList();
    final latest = measurements.first;
    
    // Calculate trend (last vs first in last 7 days)
    final last7Days = measurements
        .where((m) => m.date.isAfter(
          DateTime.now().subtract(const Duration(days: 7)),
        ))
        .toList();
    
    double trend = 0;
    if (last7Days.length >= 2) {
      trend = last7Days.first.value - last7Days.last.value;
    }

    return MeasurementStats(
      count: measurements.length,
      average: values.reduce((a, b) => a + b) / values.length,
      min: values.reduce((a, b) => a < b ? a : b),
      max: values.reduce((a, b) => a > b ? a : b),
      latest: latest,
      trend: trend,
    );
  }

  // Convert schema to entity
  Measurement _schemaToEntity(MeasurementSchema schema) {
    return Measurement(
      id: schema.id,
      type: schema.type,
      value: schema.value,
      date: schema.date,
      unit: schema.unit,
      systolic: schema.systolic,
      diastolic: schema.diastolic,
      notes: schema.notes,
    );
  }
}

class MeasurementStats {
  final int count;
  final double average;
  final double min;
  final double max;
  final Measurement? latest;
  final double trend; // Positive = increasing, Negative = decreasing

  MeasurementStats({
    required this.count,
    required this.average,
    required this.min,
    required this.max,
    required this.latest,
    required this.trend,
  });
}
