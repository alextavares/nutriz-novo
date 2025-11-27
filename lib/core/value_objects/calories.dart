import 'package:freezed_annotation/freezed_annotation.dart';

part 'calories.freezed.dart';

@freezed
class Calories with _$Calories {
  const Calories._();
  const factory Calories(double value) = _Calories;

  factory Calories.zero() => const Calories(0);

  bool get isValid => value >= 0;
  bool get isZero => value == 0;

  Calories operator +(Calories other) => Calories(value + other.value);
  Calories operator -(Calories other) => Calories(value - other.value);

  String toDisplayString() => '${value.toStringAsFixed(0)} kcal';
}
