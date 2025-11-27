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

  double toKg() => unit == WeightUnit.lb ? value * 0.453592 : value;
  double toLb() => unit == WeightUnit.kg ? value * 2.20462 : value;

  String toDisplayString() {
    return unit == WeightUnit.kg
        ? '${value.toStringAsFixed(1)} kg'
        : '${value.toStringAsFixed(1)} lb';
  }
}
