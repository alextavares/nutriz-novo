import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_daily_summary.dart';
import '../../domain/usecases/add_food_to_meal.dart';
import '../../domain/usecases/remove_food_from_meal.dart';
import '../../domain/usecases/update_food_quantity.dart';
import '../../domain/usecases/update_water_intake.dart';
import '../../domain/usecases/log_weight.dart';
import '../../domain/usecases/update_notes.dart';
import '../../domain/entities/meal.dart';
import '../../domain/entities/food.dart';
import '../../../../core/value_objects/water_volume.dart';
import '../../../../core/value_objects/weight.dart';
import '../providers/diary_state.dart';

class DiaryNotifier extends StateNotifier<DiaryState> {
  final GetDailySummary _getDailySummary;
  final AddFoodToMeal _addFoodToMeal;
  final RemoveFoodFromMeal _removeFoodFromMeal;
  final UpdateFoodQuantity _updateFoodQuantity;
  final UpdateWaterIntake _updateWaterIntake;
  final LogWeight _logWeight;
  final UpdateNotes _updateNotesUseCase;

  DiaryNotifier({
    required GetDailySummary getDailySummary,
    required AddFoodToMeal addFoodToMeal,
    required RemoveFoodFromMeal removeFoodFromMeal,
    required UpdateFoodQuantity updateFoodQuantity,
    required UpdateWaterIntake updateWaterIntake,
    required LogWeight logWeight,
    required UpdateNotes updateNotes,
  }) : _getDailySummary = getDailySummary,
       _addFoodToMeal = addFoodToMeal,
       _removeFoodFromMeal = removeFoodFromMeal,
       _updateFoodQuantity = updateFoodQuantity,
       _updateWaterIntake = updateWaterIntake,
       _logWeight = logWeight,
       _updateNotesUseCase = updateNotes,
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
// print('📅 Loaded diary for ${date.toString().split(' ')[0]}: ${day.meals.length} meals');
      for (final meal in day.meals) {
// print('   🍽️ ${meal.type.name}: ${meal.foods.length} foods');
        for (final food in meal.foods) {
// print('      - ${food.food.name} (${food.quantity}x)');
        }
      }
      state = state.copyWith(diaryDay: AsyncValue.data(day));
    } catch (e, st) {
// print('❌ Error loading diary: $e');
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
// print('➕ Adding food: ${food.name} to ${type.name} (qty: $servingAmount)');
      final foodItem = FoodItem(food: food, quantity: servingAmount);
      final meal = Meal(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        type: type,
        foods: [foodItem],
        timestamp: DateTime.now(),
      );
      await _addFoodToMeal(date: state.selectedDate, meal: meal);
// print('✅ Food saved successfully!');
      await loadDate(state.selectedDate);
    } catch (e, st) {
// print('❌ Error adding food: $e');
// print(st);
    }
  }

  Future<void> removeFoodFromMeal(String mealId) async {
    try {
// print('🗑️ Removing meal: $mealId');
      await _removeFoodFromMeal(date: state.selectedDate, mealId: mealId);
// print('✅ Food removed successfully!');
      await loadDate(state.selectedDate);
    } catch (e, st) {
// print('❌ Error removing food: $e');
// print(st);
    }
  }

  Future<void> updateFoodQuantity(String mealId, double newQuantity) async {
    try {
// print('✏️ Updating meal $mealId quantity to $newQuantity');
      await _updateFoodQuantity(
        date: state.selectedDate,
        mealId: mealId,
        newQuantity: newQuantity,
      );
// print('✅ Quantity updated successfully!');
      await loadDate(state.selectedDate);
    } catch (e, st) {
// print('❌ Error updating quantity: $e');
// print(st);
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

  Future<void> updateNotes(String notes) async {
    try {
      await _updateNotesUseCase(state.selectedDate, notes);
      await loadDate(state.selectedDate);
    } catch (e) {
      // Handle error
    }
  }

  void changeDate(DateTime date) {
    loadDate(date);
  }
}
