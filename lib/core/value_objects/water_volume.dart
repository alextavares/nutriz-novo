import 'package:freezed_annotation/freezed_annotation.dart';

part 'water_volume.freezed.dart';

@freezed
class WaterVolume with _$WaterVolume {
  const WaterVolume._();
  const factory WaterVolume(double valueMl) = _WaterVolume;

  factory WaterVolume.zero() => const WaterVolume(0);

  double get toLiters => valueMl / 1000;

  String toDisplayString() => '${valueMl.toStringAsFixed(0)} ml';
}
