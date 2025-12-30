import 'package:isar/isar.dart';

part 'measurement_schemas.g.dart';

@collection
class MeasurementSchema {
  Id id = Isar.autoIncrement;

  @Index()
  late String type; // 'weight', 'body_fat', 'blood_pressure', etc.

  late double value;

  @Index()
  late DateTime date;

  late String unit; // 'kg', 'lb', '%', 'mmHg', etc.

  // For blood pressure, store systolic/diastolic separately
  double? systolic;
  double? diastolic;

  // Notes (optional)
  String? notes;
}

enum MeasurementType {
  weight,
  bodyFat,
  bloodPressure,
  bloodGlucose,
  muscleMass,
  waist,
  hips,
  chest,
  thighs,
  upperArms,
}

extension MeasurementTypeExtension on MeasurementType {
  String get displayName {
    switch (this) {
      case MeasurementType.weight:
        return 'Peso';
      case MeasurementType.bodyFat:
        return 'Gordura corporal';
      case MeasurementType.bloodPressure:
        return 'Pressão arterial';
      case MeasurementType.bloodGlucose:
        return 'Glicose no sangue';
      case MeasurementType.muscleMass:
        return 'Massa muscular';
      case MeasurementType.waist:
        return 'Cintura';
      case MeasurementType.hips:
        return 'Quadril';
      case MeasurementType.chest:
        return 'Peito';
      case MeasurementType.thighs:
        return 'Coxas';
      case MeasurementType.upperArms:
        return 'Braços';
    }
  }

  String get icon {
    switch (this) {
      case MeasurementType.weight:
        return '⚖️';
      case MeasurementType.bodyFat:
        return '🧈';
      case MeasurementType.bloodPressure:
        return '🩺';
      case MeasurementType.bloodGlucose:
        return '💉';
      case MeasurementType.muscleMass:
        return '💪';
      case MeasurementType.waist:
      case MeasurementType.hips:
      case MeasurementType.chest:
      case MeasurementType.thighs:
      case MeasurementType.upperArms:
        return '📏';
    }
  }

  String get defaultUnit {
    switch (this) {
      case MeasurementType.weight:
        return 'kg';
      case MeasurementType.bodyFat:
      case MeasurementType.muscleMass:
        return '%';
      case MeasurementType.bloodPressure:
        return 'mmHg';
      case MeasurementType.bloodGlucose:
        return 'mg/dL';
      case MeasurementType.waist:
      case MeasurementType.hips:
      case MeasurementType.chest:
      case MeasurementType.thighs:
      case MeasurementType.upperArms:
        return 'cm';
    }
  }

  String get key {
    return name;
  }
}
