enum RecipeMeal { breakfast, lunch, dinner, snack }

enum RecipeDiet { vegetarian, vegan, lowCarb, glutenFree, highProtein, lowFat }

enum RecipeDifficulty { easy, medium, hard }

class RecipeNutrition {
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  const RecipeNutrition({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory RecipeNutrition.fromJson(Map<String, dynamic> json) {
    return RecipeNutrition(
      calories: (json['calories'] as num).round(),
      protein: (json['protein'] as num).round(),
      carbs: (json['carbs'] as num).round(),
      fat: (json['fat'] as num).round(),
    );
  }

  Map<String, dynamic> toJson() => {
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
  };
}

class Recipe {
  final String id;
  final String title;
  final String description;
  final RecipeMeal meal;
  final List<RecipeDiet> diets;
  final List<String> tags;
  final int timeMinutes;
  final RecipeDifficulty difficulty;
  final RecipeNutrition nutrition;
  final String? imageUrl;
  final List<String> ingredients;
  final List<String> steps;

  const Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.meal,
    required this.diets,
    required this.tags,
    required this.timeMinutes,
    required this.difficulty,
    required this.nutrition,
    this.imageUrl,
    required this.ingredients,
    required this.steps,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      meal: _parseMeal(json['meal'] as String?),
      diets: _parseDiets(json['diets']),
      tags: _parseTags(json['tags']),
      timeMinutes: (json['timeMinutes'] as num?)?.round() ?? 0,
      difficulty: _parseDifficulty(json['difficulty'] as String?),
      nutrition: RecipeNutrition.fromJson(
        (json['nutrition'] as Map).cast<String, dynamic>(),
      ),
      imageUrl: json['imageUrl'] as String?,
      ingredients: _parseStringList(json['ingredients']),
      steps: _parseStringList(json['steps']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'meal': meal.name,
    'diets': diets.map((d) => d.name).toList(growable: false),
    'tags': tags,
    'timeMinutes': timeMinutes,
    'difficulty': difficulty.name,
    'nutrition': nutrition.toJson(),
    'imageUrl': imageUrl,
    'ingredients': ingredients,
    'steps': steps,
  };
}

RecipeMeal _parseMeal(String? value) {
  switch (value) {
    case 'breakfast':
      return RecipeMeal.breakfast;
    case 'lunch':
      return RecipeMeal.lunch;
    case 'dinner':
      return RecipeMeal.dinner;
    case 'snack':
      return RecipeMeal.snack;
    default:
      return RecipeMeal.lunch;
  }
}

RecipeDifficulty _parseDifficulty(String? value) {
  switch (value) {
    case 'easy':
      return RecipeDifficulty.easy;
    case 'medium':
      return RecipeDifficulty.medium;
    case 'hard':
      return RecipeDifficulty.hard;
    default:
      return RecipeDifficulty.easy;
  }
}

List<RecipeDiet> _parseDiets(dynamic value) {
  final diets = <RecipeDiet>[];
  if (value is! List) return diets;

  for (final item in value) {
    final label = item?.toString();
    if (label == null) continue;
    final parsed = _parseDiet(label);
    if (parsed != null) diets.add(parsed);
  }

  return diets;
}

RecipeDiet? _parseDiet(String value) {
  switch (value) {
    case 'vegetarian':
      return RecipeDiet.vegetarian;
    case 'vegan':
      return RecipeDiet.vegan;
    case 'lowCarb':
      return RecipeDiet.lowCarb;
    case 'glutenFree':
      return RecipeDiet.glutenFree;
    case 'highProtein':
      return RecipeDiet.highProtein;
    case 'lowFat':
      return RecipeDiet.lowFat;
    default:
      return null;
  }
}

List<String> _parseTags(dynamic value) {
  if (value is! List) return const [];
  return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
}

List<String> _parseStringList(dynamic value) {
  if (value is! List) return const [];
  return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
}
