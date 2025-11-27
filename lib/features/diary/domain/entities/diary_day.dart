import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/value_objects/calories.dart';
import '../../../../core/value_objects/macro_nutrients.dart';
import '../../../../core/value_objects/water_volume.dart';
import 'meal.dart';

part 'diary_day.freezed.dart';

@freezed
class DiaryDay with _$DiaryDay {
  const DiaryDay._();
  const factory DiaryDay({
    required DateTime date,
    @Default([]) List<Meal> meals,
    @Default(WaterVolume(0)) WaterVolume waterIntake,
    Calories? calorieGoal,
  }) = _DiaryDay;

  Calories get totalCalories {
    return meals.fold(Calories.zero(), (sum, meal) => sum + meal.totalCalories);
  }

  MacroNutrients get totalMacros {
    return meals.fold(MacroNutrients.zero(), (sum, meal) {
      return MacroNutrients(
        carbs: sum.carbs + meal.totalMacros.carbs,
        protein: sum.protein + meal.totalMacros.protein,
        fat: sum.fat + meal.totalMacros.fat,
      );
    });
  }

  List<Meal> getMealsByType(MealType type) {
    return meals.where((m) => m.type == type).toList();
  }
}
