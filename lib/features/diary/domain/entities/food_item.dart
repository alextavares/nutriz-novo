import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/value_objects/calories.dart';
import '../../../../core/value_objects/macro_nutrients.dart';
import 'food.dart';

part 'food_item.freezed.dart';
part 'food_item.g.dart';

@freezed
class FoodItem with _$FoodItem {
  const FoodItem._(); // Added for custom methods

  const factory FoodItem({
    @Default('') String id,
    required String name,
    String? brand,
    @Default(0.0) double calories,
    @Default(0.0) double protein,
    @Default(0.0) double carbs,
    @Default(0.0) double fat,
    @Default('100g') String servingSize,
    String? imageUrl,
  }) = _FoodItem;

  factory FoodItem.fromJson(Map<String, dynamic> json) =>
      _$FoodItemFromJson(json);

  Food toDomain() {
    // Basic parsing for serving size (e.g. "100g" -> 100.0)
    var parsedServingSize = 100.0;
    var unit = 'g';

    final match = RegExp(
      r'(\d+(\.\d+)?)\s*([a-zA-Z]+)',
    ).firstMatch(servingSize);
    if (match != null) {
      parsedServingSize = double.tryParse(match.group(1) ?? '') ?? 100.0;
      unit = match.group(3) ?? 'g';
    }

    return Food(
      id: id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : id,
      name: name,
      calories: Calories(calories),
      macros: MacroNutrients(carbs: carbs, protein: protein, fat: fat),
      servingSize: parsedServingSize,
      servingUnit: unit,
      brand: brand,
    );
  }
}
