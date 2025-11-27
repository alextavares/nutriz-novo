import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_daily_summary.dart';
import '../../domain/usecases/add_food_to_meal.dart';
import '../../domain/usecases/update_water_intake.dart';
import '../../domain/usecases/log_weight.dart';
import '../../domain/entities/meal.dart';
import '../../domain/entities/food.dart';
import '../../../../core/value_objects/water_volume.dart';
import '../../../../core/value_objects/weight.dart';
import '../providers/diary_state.dart';

class DiaryNotifier extends StateNotifier<DiaryState> {
  final GetDailySummary _getDailySummary;
  final AddFoodToMeal _addFoodToMeal;
  final UpdateWaterIntake _updateWaterIntake;
  final LogWeight _logWeight;

  DiaryNotifier({
    required GetDailySummary getDailySummary,
    required AddFoodToMeal addFoodToMeal,
    required UpdateWaterIntake updateWaterIntake,
    required LogWeight logWeight,
  }) : _getDailySummary = getDailySummary,
       _addFoodToMeal = addFoodToMeal,
       _updateWaterIntake = updateWaterIntake,
       _logWeight = logWeight,
       super(DiaryState.initial()) {
    loadDate(DateTime.now());
  }

  Future<void> loadDate(DateTime date) async {
    state = state.copyWith(
      selectedDate: date,
      diaryDay: const AsyncValue.loading(),
    );
    try {
      final day = await _getDailySummary(date);
      state = state.copyWith(diaryDay: AsyncValue.data(day));
    } catch (e, st) {
      state = state.copyWith(diaryDay: AsyncValue.error(e, st));
    }
  }

  Future<void> addMeal(Meal meal) async {
    try {
      await _addFoodToMeal(date: state.selectedDate, meal: meal);
      await loadDate(state.selectedDate); // Reload to update UI
    } catch (e) {
      // Handle error
    }
  }

  Future<void> addFoodToMeal(
    MealType type,
    Food food,
    double servingAmount,
  ) async {
    try {
      final foodItem = FoodItem(food: food, quantity: servingAmount);
      final meal = Meal(
        id: DateTime.now().millisecondsSinceEpoch
            .toString(), // Simple ID generation
        type: type,
        foods: [foodItem],
        timestamp: DateTime.now(),
      );
      await _addFoodToMeal(date: state.selectedDate, meal: meal);
      await loadDate(state.selectedDate);
    } catch (e) {
      // Handle error
      // print('Error adding food: $e');
    }
  }

  Future<void> updateWater(WaterVolume volume) async {
    try {
      await _updateWaterIntake(state.selectedDate, volume);
      await loadDate(state.selectedDate);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> logWeight(Weight weight) async {
    try {
      await _logWeight(state.selectedDate, weight);
      state = state.copyWith(currentWeight: weight);
    } catch (e) {
      // Handle error
    }
  }

  void changeDate(DateTime date) {
    loadDate(date);
  }
}
