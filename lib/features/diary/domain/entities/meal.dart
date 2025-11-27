import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/value_objects/calories.dart';
import '../../../../core/value_objects/macro_nutrients.dart';
import 'food.dart';

part 'meal.freezed.dart';

enum MealType { breakfast, lunch, snack, dinner }

@freezed
class Meal with _$Meal {
  const Meal._();
  const factory Meal({
    required String id,
    required MealType type,
    required List<FoodItem> foods,
    required DateTime timestamp,
  }) = _Meal;

  Calories get totalCalories {
    return foods.fold(Calories.zero(), (sum, item) => sum + item.totalCalories);
  }

  MacroNutrients get totalMacros {
    return foods.fold(MacroNutrients.zero(), (sum, item) {
      return MacroNutrients(
        carbs: sum.carbs + item.totalMacros.carbs,
        protein: sum.protein + item.totalMacros.protein,
        fat: sum.fat + item.totalMacros.fat,
      );
    });
  }
}

@freezed
class FoodItem with _$FoodItem {
  const FoodItem._();
  const factory FoodItem({
    required Food food,
    required double quantity, // Quantidade consumida (ex: 1.5 porções ou 150g)
  }) = _FoodItem;

  Calories get totalCalories => Calories(food.calories.value * quantity);

  MacroNutrients get totalMacros => MacroNutrients(
    carbs: food.macros.carbs * quantity,
    protein: food.macros.protein * quantity,
    fat: food.macros.fat * quantity,
  );
}
