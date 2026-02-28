enum DietMealType { breakfast, lunch, dinner, snack }

DietMealType dietMealTypeFromString(String raw) {
  switch (raw.trim().toLowerCase()) {
    case 'breakfast':
      return DietMealType.breakfast;
    case 'lunch':
      return DietMealType.lunch;
    case 'dinner':
      return DietMealType.dinner;
    case 'snack':
      return DietMealType.snack;
  }
  throw ArgumentError('Unknown mealType: $raw');
}

String dietMealTypeLabel(DietMealType type) {
  switch (type) {
    case DietMealType.breakfast:
      return 'Café da manhã';
    case DietMealType.lunch:
      return 'Almoço';
    case DietMealType.dinner:
      return 'Jantar';
    case DietMealType.snack:
      return 'Lanche';
  }
}

class DietMeal {
  final String id;
  final DietMealType mealType;
  final String title;
  final int kcal;
  final int proteinG;
  final int carbsG;
  final int fatG;
  final List<String> ingredients;
  final List<String> steps;

  const DietMeal({
    required this.id,
    required this.mealType,
    required this.title,
    required this.kcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.ingredients,
    required this.steps,
  });

  factory DietMeal.fromJson(Map<String, dynamic> json) {
    return DietMeal(
      id: json['id'] as String,
      mealType: dietMealTypeFromString(json['mealType'] as String),
      title: json['title'] as String,
      kcal: (json['kcal'] as num).toInt(),
      proteinG: (json['protein_g'] as num).toInt(),
      carbsG: (json['carbs_g'] as num).toInt(),
      fatG: (json['fat_g'] as num).toInt(),
      ingredients:
          (json['ingredients'] as List).whereType<String>().toList(growable: false),
      steps: (json['steps'] as List).whereType<String>().toList(growable: false),
    );
  }
}

