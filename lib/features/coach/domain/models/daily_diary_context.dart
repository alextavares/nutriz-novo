/// Context model for daily diary data to be sent to AI coach.
///
/// This allows the AI to provide contextual responses based on today's food log.
class DailyDiaryContext {
  final int totalCalories;
  final int calorieGoal;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;
  final List<String> foodsLogged;
  final bool hasBreakfast;
  final bool hasLunch;
  final bool hasDinner;
  final bool hasSnacks;
  final int waterMl;

  const DailyDiaryContext({
    required this.totalCalories,
    required this.calorieGoal,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.foodsLogged,
    required this.hasBreakfast,
    required this.hasLunch,
    required this.hasDinner,
    required this.hasSnacks,
    required this.waterMl,
  });

  bool get isEmpty => foodsLogged.isEmpty;

  /// Creates an empty context for when no diary data is available.
  factory DailyDiaryContext.empty({int calorieGoal = 0}) => DailyDiaryContext(
    totalCalories: 0,
    calorieGoal: calorieGoal,
    proteinGrams: 0,
    carbsGrams: 0,
    fatGrams: 0,
    foodsLogged: const [],
    hasBreakfast: false,
    hasLunch: false,
    hasDinner: false,
    hasSnacks: false,
    waterMl: 0,
  );

  Map<String, dynamic> toJson() => {
    'totalCalories': totalCalories,
    'calorieGoal': calorieGoal,
    'proteinGrams': proteinGrams,
    'carbsGrams': carbsGrams,
    'fatGrams': fatGrams,
    'foodsLogged': foodsLogged,
    'hasBreakfast': hasBreakfast,
    'hasLunch': hasLunch,
    'hasDinner': hasDinner,
    'hasSnacks': hasSnacks,
    'waterMl': waterMl,
    'isEmpty': isEmpty,
  };
}
