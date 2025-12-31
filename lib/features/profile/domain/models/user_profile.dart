import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

enum Gender { male, female }

enum ActivityLevel {
  sedentary, // Little or no exercise
  low, // Light exercise/sports 1-3 days/week
  active, // Moderate exercise/sports 3-5 days/week
  veryActive, // Hard exercise/sports 6-7 days/week
}

enum MainGoal { loseWeight, maintain, buildMuscle }

enum DietaryPreference { classic, pescetarian, vegetarian, vegan }

enum SleepDuration { lessThan5, fiveToSix, sevenToEight, moreThan8 }

enum WaterIntake { lessThan1L, oneToTwoL, twoToThreeL, moreThan3L }

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    @Default('') String name,
    required Gender gender,
    required DateTime birthDate,
    required int height, // cm
    required double currentWeight, // kg
    required double targetWeight, // kg
    /// Desired weight change per week in kg.
    /// Negative for weight loss, positive for gain.
    /// e.g., -0.5 for losing 0.5kg/week.
    required double weeklyGoal,

    required ActivityLevel activityLevel,
    required MainGoal mainGoal,
    required DietaryPreference dietaryPreference,

    @Default(SleepDuration.sevenToEight) SleepDuration sleepDuration,
    @Default(WaterIntake.oneToTwoL) WaterIntake waterIntake,
    @Default(<String>[]) List<String> badHabits,
    @Default(<String>[]) List<String> motivations,

    // Calculated values
    required int calculatedCalories,
    required int proteinGrams,
    required int carbsGrams,
    required int fatGrams,

    // Time estimate fields
    int? weeksToGoal,
    DateTime? estimatedGoalDate,

    // Favoritos (para sync futura)
    @Default(<String>[]) List<String> favoriteFoodKeys,

    // Monetization / gating (bootstrapped growth)
    @Default(1) int freeMealsRemaining,
    DateTime? challengeStartedAt,
    DateTime? challengeLastMealAt,
    @Default(0) int challengeMealsRemaining,
    @Default(0) int paywallDismissCount,

    // Onboarding commitment
    @Default(false) bool committedToLogDaily,

    @Default(false) bool isOnboardingCompleted,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
