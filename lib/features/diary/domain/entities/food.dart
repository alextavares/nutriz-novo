import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/value_objects/calories.dart';
import '../../../../core/value_objects/macro_nutrients.dart';

part 'food.freezed.dart';

@freezed
class Food with _$Food {
  const factory Food({
    required String id,
    required String name,
    required Calories calories,
    required MacroNutrients macros,
    required double servingSize, // em gramas ou ml
    required String servingUnit, // g, ml, fatia, etc.
    String? brand,
  }) = _Food;
}
