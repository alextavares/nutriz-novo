import 'package:isar/isar.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/diary_day.dart';
import '../../domain/entities/meal.dart';
import '../../domain/repositories/diary_repository.dart';
import '../../../../core/value_objects/weight.dart';
import '../../../../core/value_objects/water_volume.dart';
import '../models/diary_schemas.dart';

class DiaryRepositoryImpl implements DiaryRepository {
  final Isar _isar;

  DiaryRepositoryImpl(this._isar);

  @override
  Future<DiaryDay> getDiaryDay(DateTime date) async {
    final normalizedDate = DateUtils.dateOnly(date);
    final schema = await _isar.diaryDaySchemas
        .filter()
        .dateEqualTo(normalizedDate)
        .findFirst();

    if (schema == null) {
      // Retorna um dia vazio se não existir
      return DiaryDay(date: normalizedDate);
    }

    return schema.toEntity();
  }

  @override
  Future<void> saveDiaryDay(DiaryDay day) async {
    await _isar.writeTxn(() async {
      await _isar.diaryDaySchemas.put(DiaryDaySchema.fromEntity(day));
    });
  }

  @override
  Future<void> addMeal(DateTime date, Meal meal) async {
// print('💾 Repository: Adding meal to $date');
    final day = await getDiaryDay(date);
// print('   Current meals count: ${day.meals.length}');
    final updatedMeals = [...day.meals, meal];
    final updatedDay = day.copyWith(meals: updatedMeals);
// print('   New meals count: ${updatedDay.meals.length}');
    await saveDiaryDay(updatedDay);
// print('   ✅ Saved to Isar');
  }

  @override
  Future<void> removeMeal(DateTime date, String mealId) async {
// print('🗑️ Repository: Removing meal $mealId from $date');
    final day = await getDiaryDay(date);
    final updatedMeals = day.meals.where((m) => m.id != mealId).toList();
    final updatedDay = day.copyWith(meals: updatedMeals);
// print('   Meals after removal: ${updatedDay.meals.length}');
    await saveDiaryDay(updatedDay);
// print('   ✅ Removed from Isar');
  }

  @override
  Future<void> updateMealQuantity(DateTime date, String mealId, double newQuantity) async {
// print('✏️ Repository: Updating meal $mealId quantity to $newQuantity');
    final day = await getDiaryDay(date);
    final updatedMeals = day.meals.map((meal) {
      if (meal.id == mealId) {
        final updatedFoods = meal.foods.map((foodItem) {
          return FoodItem(food: foodItem.food, quantity: newQuantity);
        }).toList();
        return Meal(
          id: meal.id,
          type: meal.type,
          foods: updatedFoods,
          timestamp: meal.timestamp,
        );
      }
      return meal;
    }).toList();
    final updatedDay = day.copyWith(meals: updatedMeals);
    await saveDiaryDay(updatedDay);
// print('   ✅ Updated in Isar');
  }

  @override
  Future<void> updateWaterIntake(DateTime date, WaterVolume volume) async {
    final day = await getDiaryDay(date);
    final updatedDay = day.copyWith(waterIntake: volume);
    await saveDiaryDay(updatedDay);
  }

  @override
  Future<void> logWeight(DateTime date, Weight weight) async {
    // TODO: Implementar log de peso (pode ser em outra collection ou no DiaryDay)
    // Por enquanto, vamos assumir que não salvamos no DiaryDaySchema simplificado
  }
}
