import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:nutriz/features/profile/domain/models/user_profile.dart';
import 'package:nutriz/features/profile/domain/services/nutrition_calculator_service.dart';
import 'package:uuid/uuid.dart';
import 'package:nutriz/features/gamification/presentation/providers/gamification_providers.dart'; // For isarProvider
import '../../../profile/data/repositories/profile_repository.dart';

part 'onboarding_notifier.g.dart';

@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  @override
  UserProfile build() {
    return UserProfile(
      id: const Uuid().v4(),
      gender: Gender.male,
      birthDate: DateTime(1990, 1, 1),
      height: 170,
      currentWeight: 70,
      targetWeight: 65,
      weeklyGoal: -0.5,
      activityLevel: ActivityLevel.sedentary,
      mainGoal: MainGoal.loseWeight,
      dietaryPreference: DietaryPreference.classic,
      calculatedCalories: 2000,
      proteinGrams: 150,
      carbsGrams: 200,
      fatGrams: 65,
    );
  }

  void updateGender(Gender gender) {
    state = state.copyWith(gender: gender);
  }

  void updateBiometrics({
    DateTime? birthDate,
    int? height,
    double? currentWeight,
  }) {
    state = state.copyWith(
      birthDate: birthDate ?? state.birthDate,
      height: height ?? state.height,
      currentWeight: currentWeight ?? state.currentWeight,
    );
  }

  void updateActivityLevel(ActivityLevel level) {
    state = state.copyWith(activityLevel: level);
  }

  void updateMainGoal(MainGoal goal) {
    state = state.copyWith(mainGoal: goal);
  }

  void updateTarget({double? targetWeight, double? weeklyGoal}) {
    state = state.copyWith(
      targetWeight: targetWeight ?? state.targetWeight,
      weeklyGoal: weeklyGoal ?? state.weeklyGoal,
    );
  }

  void updateDietaryPreference(DietaryPreference preference) {
    state = state.copyWith(dietaryPreference: preference);
  }

  Future<void> calculateAndSave() async {
    final calculator = NutritionCalculatorService();

    final age = DateTime.now().year - state.birthDate.year;

    final bmr = calculator.calculateBMR(
      gender: state.gender,
      weightKg: state.currentWeight,
      heightCm: state.height,
      ageYears: age,
    );

    final tdee = calculator.calculateTDEE(
      bmr: bmr,
      activityLevel: state.activityLevel,
    );

    final dailyCalories = calculator.calculateDailyCalories(
      tdee: tdee,
      weeklyGoalKg: state.weeklyGoal,
    );

    final macros = calculator.calculateMacros(
      dailyCalories: dailyCalories,
      mainGoal: state.mainGoal,
    );

    // Calculate time estimate
    final weeksToGoal = calculator.calculateWeeksToGoal(
      currentWeight: state.currentWeight,
      targetWeight: state.targetWeight,
      weeklyGoalKg: state.weeklyGoal,
    );

    final estimatedDate = calculator.calculateEstimatedDate(
      weeksToGoal: weeksToGoal,
    );

    state = state.copyWith(
      calculatedCalories: dailyCalories,
      proteinGrams: macros['protein']!,
      carbsGrams: macros['carbs']!,
      fatGrams: macros['fat']!,
      weeksToGoal: weeksToGoal,
      estimatedGoalDate: estimatedDate,
      isOnboardingCompleted: true,
    );

    // Save to local storage
    final isar = ref.read(isarProvider);
    final repository = ProfileRepository(isar);
    await repository.saveProfile(state);
  }
}
