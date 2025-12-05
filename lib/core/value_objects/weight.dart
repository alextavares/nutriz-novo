import 'package:freezed_annotation/freezed_annotation.dart';

part 'weight.freezed.dart';

enum WeightUnit { kg, lb }

@freezed
class Weight with _$Weight {
  const Weight._();
  const factory Weight({
    required double value,
    @Default(WeightUnit.kg) WeightUnit unit,
  }) = _Weight;

  factory Weight.fromKg(double value) =>
      Weight(value: value, unit: WeightUnit.kg);
  factory Weight.fromLb(double value) =>
      Weight(value: value, unit: WeightUnit.lb);

  double get kg => toKg();
  double get lb => toLb();

  double toKg() => unit == WeightUnit.lb ? value * 0.453592 : value;
  double toLb() => unit == WeightUnit.kg ? value * 2.20462 : value;

  String format() {
    return unit == WeightUnit.kg
        ? '${value.toStringAsFixed(1)} kg'
        : '${value.toStringAsFixed(1)} lb';
  }
}
