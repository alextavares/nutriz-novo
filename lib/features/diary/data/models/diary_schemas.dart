import 'package:isar/isar.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/diary_day.dart';
import '../../domain/entities/meal.dart';
import '../../domain/entities/food.dart';
import '../../../../core/value_objects/calories.dart';
import '../../../../core/value_objects/macro_nutrients.dart';

import '../../../../core/value_objects/water_volume.dart';

part 'diary_schemas.g.dart';

@collection
class DiaryDaySchema {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late DateTime date; // Normalizado para meia-noite

  late List<MealEmbedded> meals;

  late double waterIntakeMl;

  double? calorieGoal;

  String? notes;

  DiaryDay toEntity() {
    return DiaryDay(
      date: date,
      meals: meals.map((e) => e.toEntity()).toList(),
      waterIntake: WaterVolume(waterIntakeMl),
      calorieGoal: calorieGoal != null ? Calories(calorieGoal!) : null,
      notes: notes,
    );
  }

  static DiaryDaySchema fromEntity(DiaryDay entity) {
    return DiaryDaySchema()
      ..date = DateUtils.dateOnly(entity.date)
      ..meals = entity.meals.map((e) => MealEmbedded.fromEntity(e)).toList()
      ..waterIntakeMl = entity.waterIntake.valueMl
      ..calorieGoal = entity.calorieGoal?.value
      ..notes = entity.notes;
  }
}

@embedded
class MealEmbedded {
  late String id;
  @Enumerated(EnumType.name)
  late MealType type;
  late List<FoodItemEmbedded> foods;
  late DateTime timestamp;

  Meal toEntity() {
    return Meal(
      id: id,
      type: type,
      foods: foods.map((e) => e.toEntity()).toList(),
      timestamp: timestamp,
    );
  }

  static MealEmbedded fromEntity(Meal entity) {
    return MealEmbedded()
      ..id = entity.id
      ..type = entity.type
      ..foods = entity.foods.map((e) => FoodItemEmbedded.fromEntity(e)).toList()
      ..timestamp = entity.timestamp;
  }
}

@embedded
class FoodItemEmbedded {
  late FoodEmbedded food;
  late double quantity;

  FoodItem toEntity() {
    return FoodItem(food: food.toEntity(), quantity: quantity);
  }

  static FoodItemEmbedded fromEntity(FoodItem entity) {
    return FoodItemEmbedded()
      ..food = FoodEmbedded.fromEntity(entity.food)
      ..quantity = entity.quantity;
  }
}

@embedded
class FoodEmbedded {
  late String id;
  late String name;
  late double calories;
  late double carbs;
  late double protein;
  late double fat;
  late double servingSize;
  late String servingUnit;
  String? brand;

  Food toEntity() {
    return Food(
      id: id,
      name: name,
      calories: Calories(calories),
      macros: MacroNutrients(carbs: carbs, protein: protein, fat: fat),
      servingSize: servingSize,
      servingUnit: servingUnit,
      brand: brand,
    );
  }

  static FoodEmbedded fromEntity(Food entity) {
    return FoodEmbedded()
      ..id = entity.id
      ..name = entity.name
      ..calories = entity.calories.value
      ..carbs = entity.macros.carbs
      ..protein = entity.macros.protein
      ..fat = entity.macros.fat
      ..servingSize = entity.servingSize
      ..servingUnit = entity.servingUnit
      ..brand = entity.brand;
  }
}
