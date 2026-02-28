import 'package:isar/isar.dart';
import '../../domain/entities/food.dart';
import '../../domain/entities/food_item.dart';
import '../models/custom_food_schema.dart';

class CustomFoodService {
  final Isar isar;

  CustomFoodService({required this.isar});

  Future<void> saveCustomFood(Food food) async {
    final schema = CustomFoodSchema.fromEntity(food);
    await isar.writeTxn(() async {
      await isar.customFoodSchemas.put(schema);
    });
  }

  Future<void> deleteCustomFood(int id) async {
    await isar.writeTxn(() async {
      await isar.customFoodSchemas.delete(id);
    });
  }

  Future<List<FoodItem>> searchCustomFoods(String query) async {
    final lowerQuery = query.toLowerCase();

    // As Isar doesn't support built-in case-insensitive contains easily without
    // exact indexes, we fetch all and filter in memory if the dataset is small,
    // or use beginsWith. Since custom foods are usually few, fetching all is fine.
    final allCustomFoods = await isar.customFoodSchemas.where().findAll();

    final results = allCustomFoods
        .where((schema) {
          return schema.name.toLowerCase().contains(lowerQuery) ||
              (schema.brand?.toLowerCase().contains(lowerQuery) ?? false);
        })
        .map((schema) {
          final entity = schema.toEntity();
          return FoodItem(
            id: entity.id,
            name: entity.name,
            brand: entity.brand,
            calories: entity.calories.value,
            protein: entity.macros.protein,
            carbs: entity.macros.carbs,
            fat: entity.macros.fat,
            servingSize:
                '${entity.servingSize.toStringAsFixed(0)}${entity.servingUnit}',
          );
        })
        .toList();

    return results;
  }
}
