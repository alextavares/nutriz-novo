import 'package:isar/isar.dart';

part 'water_intake_schema.g.dart';

/// Isar schema for daily water intake
/// Stores water consumption per day
@collection
class WaterIntakeSchema {
  Id id = Isar.autoIncrement;

  /// Date of the water intake (only date part, time is ignored)
  @Index(unique: true, replace: true)
  late DateTime date;

  /// Total water intake in milliliters
  late int volumeMl;

  /// Goal water intake in milliliters
  late int goalMl;

  /// Timestamp when this record was created
  late DateTime createdAt;

  /// Timestamp when this record was last updated
  late DateTime updatedAt;
}
