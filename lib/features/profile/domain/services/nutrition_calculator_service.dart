import 'package:nutriz/features/profile/domain/models/user_profile.dart';

class NutritionCalculatorService {
  /// Calculates Basal Metabolic Rate (BMR) using the Mifflin-St Jeor equation.
  int calculateBMR({
    required Gender gender,
    required double weightKg,
    required int heightCm,
    required int ageYears,
  }) {
    // Mifflin-St Jeor Equation:
    // Men: (10 × weight in kg) + (6.25 × height in cm) - (5 × age in years) + 5
    // Women: (10 × weight in kg) + (6.25 × height in cm) - (5 × age in years) - 161

    double bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * ageYears);

    if (gender == Gender.male) {
      bmr += 5;
    } else {
      bmr -= 161;
    }

    return bmr.round();
  }

  /// Calculates Total Daily Energy Expenditure (TDEE).
  int calculateTDEE({required int bmr, required ActivityLevel activityLevel}) {
    double multiplier;

    switch (activityLevel) {
      case ActivityLevel.sedentary:
        multiplier = 1.2;
        break;
      case ActivityLevel.low:
        multiplier = 1.375;
        break;
      case ActivityLevel.active:
        multiplier = 1.55;
        break;
      case ActivityLevel.veryActive:
        multiplier = 1.725;
        break;
    }

    return (bmr * multiplier).round();
  }

  /// Calculates the daily calorie target based on TDEE and weekly goal.
  /// [weeklyGoalKg] is the desired weight change in kg per week.
  /// 1 kg of fat is approx 7700 kcal.
  int calculateDailyCalories({
    required int tdee,
    required double weeklyGoalKg,
  }) {
    // 7700 kcal per kg
    // Daily deficit/surplus = (weeklyGoal * 7700) / 7
    final dailyAdjustment = (weeklyGoalKg * 7700) / 7;

    int target = (tdee + dailyAdjustment).round();

    // Safety limits (approximate)
    if (target < 1200) return 1200; // Minimum safe limit

    return target;
  }

  /// Calculates macros based on calories and goal.
  /// Returns a map with 'protein', 'carbs', 'fat' in grams.
  Map<String, int> calculateMacros({
    required int dailyCalories,
    required MainGoal mainGoal,
  }) {
    double proteinRatio;
    double fatRatio;
    double carbsRatio;

    switch (mainGoal) {
      case MainGoal.loseWeight:
        // High protein to preserve muscle
        proteinRatio = 0.40;
        fatRatio = 0.30;
        carbsRatio = 0.30;
        break;
      case MainGoal.buildMuscle:
        // High carb for energy, moderate protein
        proteinRatio = 0.30;
        fatRatio = 0.20;
        carbsRatio = 0.50;
        break;
      case MainGoal.maintain:
        // Balanced
        proteinRatio = 0.30;
        fatRatio = 0.30;
        carbsRatio = 0.40;
        break;
    }

    // 1g Protein = 4 kcal
    // 1g Carbs = 4 kcal
    // 1g Fat = 9 kcal

    final proteinGrams = (dailyCalories * proteinRatio) / 4;
    final carbsGrams = (dailyCalories * carbsRatio) / 4;
    final fatGrams = (dailyCalories * fatRatio) / 9;

    return {
      'protein': proteinGrams.round(),
      'carbs': carbsGrams.round(),
      'fat': fatGrams.round(),
    };
  }

  /// Calculates the number of weeks to reach the goal weight.
  int calculateWeeksToGoal({
    required double currentWeight,
    required double targetWeight,
    required double weeklyGoalKg,
  }) {
    final weightDiff = (currentWeight - targetWeight).abs();
    final weeklyRate = weeklyGoalKg.abs();
    if (weeklyRate == 0) return 0;
    return (weightDiff / weeklyRate).ceil();
  }

  /// Calculates the estimated date to reach the goal.
  DateTime calculateEstimatedDate({required int weeksToGoal}) {
    return DateTime.now().add(Duration(days: weeksToGoal * 7));
  }

  /// Gets a motivational message based on the goal and time.
  String getMotivationalMessage({
    required MainGoal goal,
    required int weeksToGoal,
  }) {
    if (weeksToGoal <= 4) {
      return 'Você está quase lá! 💪';
    } else if (weeksToGoal <= 12) {
      return 'Um objetivo alcançável! 🎯';
    } else if (weeksToGoal <= 24) {
      return 'Uma jornada transformadora! 🌟';
    } else {
      return 'Grandes conquistas levam tempo! 🏆';
    }
  }
}
