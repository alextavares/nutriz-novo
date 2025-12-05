import 'package:freezed_annotation/freezed_annotation.dart';

part 'measurement.freezed.dart';
part 'measurement.g.dart';

@freezed
class Measurement with _$Measurement {
  const factory Measurement({
    required int id,
    required String type,
    required double value,
    required DateTime date,
    required String unit,
    double? systolic,
    double? diastolic,
    String? notes,
  }) = _Measurement;

  factory Measurement.fromJson(Map<String, dynamic> json) =>
      _$MeasurementFromJson(json);
}
