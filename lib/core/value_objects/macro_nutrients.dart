import 'package:freezed_annotation/freezed_annotation.dart';

part 'macro_nutrients.freezed.dart';

@freezed
class MacroNutrients with _$MacroNutrients {
  const factory MacroNutrients({
    required double carbs,
    required double protein,
    required double fat,
  }) = _MacroNutrients;

  factory MacroNutrients.zero() =>
      const MacroNutrients(carbs: 0, protein: 0, fat: 0);
}
