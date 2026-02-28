import 'package:isar/isar.dart';
import '../../../../core/value_objects/calories.dart';
import '../../../../core/value_objects/macro_nutrients.dart';
import '../../domain/entities/food.dart';

part 'custom_food_schema.g.dart';

@collection
class CustomFoodSchema {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String name;

  late double calories;
  late double carbs;
  late double protein;
  late double fat;

  late double servingSize;
  late String servingUnit;
  String? brand;

  @Index()
  late DateTime createdAt;

  Food toEntity() {
    return Food(
      id: 'custom_$id',
      name: name,
      calories: Calories(calories),
      macros: MacroNutrients(carbs: carbs, protein: protein, fat: fat),
      servingSize: servingSize,
      servingUnit: servingUnit,
      brand: brand,
    );
  }

  static CustomFoodSchema fromEntity(Food entity) {
    return CustomFoodSchema()
      ..name = entity.name
      ..calories = entity.calories.value
      ..carbs = entity.macros.carbs
      ..protein = entity.macros.protein
      ..fat = entity.macros.fat
      ..servingSize = entity.servingSize
      ..servingUnit = entity.servingUnit
      ..brand = entity.brand
      ..createdAt = DateTime.now();
  }
}
