import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/food.dart';
import '../../../../core/value_objects/calories.dart';
import '../../../../core/value_objects/macro_nutrients.dart';

class FoodSearchNotifier extends StateNotifier<List<Food>> {
  FoodSearchNotifier() : super(_initialFoods);

  static final List<Food> _initialFoods = [
    Food(
      id: '1',
      name: 'Banana',
      calories: Calories(89),
      servingSize: 100,
      servingUnit: 'g',
      macros: MacroNutrients(carbs: 23, protein: 1.1, fat: 0.3),
    ),
    Food(
      id: '2',
      name: 'Maçã',
      calories: Calories(52),
      servingSize: 100,
      servingUnit: 'g',
      macros: MacroNutrients(carbs: 14, protein: 0.3, fat: 0.2),
    ),
    Food(
      id: '3',
      name: 'Peito de Frango Grelhado',
      calories: Calories(165),
      servingSize: 100,
      servingUnit: 'g',
      macros: MacroNutrients(carbs: 0, protein: 31, fat: 3.6),
    ),
    Food(
      id: '4',
      name: 'Arroz Branco Cozido',
      calories: Calories(130),
      servingSize: 100,
      servingUnit: 'g',
      macros: MacroNutrients(carbs: 28, protein: 2.7, fat: 0.3),
    ),
    Food(
      id: '5',
      name: 'Feijão Carioca Cozido',
      calories: Calories(76),
      servingSize: 100,
      servingUnit: 'g',
      macros: MacroNutrients(carbs: 14, protein: 5, fat: 0.5),
    ),
    Food(
      id: '6',
      name: 'Ovo Cozido',
      calories: Calories(155),
      servingSize: 100,
      servingUnit: 'g',
      macros: MacroNutrients(carbs: 1.1, protein: 13, fat: 11),
    ),
  ];

  void search(String query) {
    if (query.isEmpty) {
      state = _initialFoods;
    } else {
      state = _initialFoods
          .where(
            (food) => food.name.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
  }
}
