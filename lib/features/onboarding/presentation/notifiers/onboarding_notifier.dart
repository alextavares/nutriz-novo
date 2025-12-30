import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:nutriz/features/profile/domain/models/user_profile.dart';
import 'package:nutriz/features/profile/domain/services/nutrition_calculator_service.dart';
import 'package:nutriz/features/gamification/presentation/providers/gamification_providers.dart'; // For isarProvider
import 'package:nutriz/core/debug/debug_flags.dart';
import '../../../profile/data/repositories/profile_repository.dart';

part 'onboarding_notifier.g.dart';

@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  bool _hydrated = false;
  Timer? _draftTimer;
  UserProfile? _pendingDraft;
  UserProfile? _lastSavedDraft;

  @override
  UserProfile build() {
    // Prevent provider from being auto-disposed during onboarding flow.
    // Without this, page transitions can dispose/recreate the provider,
    // causing the PageView to reset to page 0.
    ref.keepAlive();

    final initial = UserProfile(
      id: ProfileRepository.singleProfileId,
      gender: Gender.male,
      birthDate: DateTime(1990, 1, 1),
      height: 170,
      currentWeight: 70,
      targetWeight: 70,
      weeklyGoal: 0,
      activityLevel: ActivityLevel.sedentary,
      mainGoal: MainGoal.maintain,
      dietaryPreference: DietaryPreference.classic,
      sleepDuration: SleepDuration.sevenToEight,
      waterIntake: WaterIntake.oneToTwoL,
      badHabits: const [],
      motivations: const [],
      calculatedCalories: 2000,
      proteinGrams: 150,
      carbsGrams: 200,
      fatGrams: 65,
    );
    ref.onDispose(() {
      _draftTimer?.cancel();
      _draftTimer = null;
    });
    unawaited(_hydrateOnce());
    return initial;
  }

  Future<void> _hydrateOnce() async {
    if (_hydrated) return;
    _hydrated = true;

    try {
      final isar = ref.read(isarProvider);
      final repository = ProfileRepository(isar);
      final profile = await repository.getProfile();
      if (profile != null) {
        state = profile;
      }
    } catch (_) {
      // Keep default state on errors (beta-friendly).
    }
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
    final double weeklyGoal = switch (goal) {
      MainGoal.loseWeight => -0.25,
      MainGoal.maintain => 0.0,
      MainGoal.buildMuscle => 0.25,
    };
    state = state.copyWith(mainGoal: goal, weeklyGoal: weeklyGoal);
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

  void updateSleepDuration(SleepDuration duration) {
    state = state.copyWith(sleepDuration: duration);
  }

  void updateWaterIntake(WaterIntake intake) {
    state = state.copyWith(waterIntake: intake);
  }

  void updateBadHabits(List<String> habits) {
    state = state.copyWith(badHabits: habits);
  }

  void toggleBadHabit(String habit) {
    final current = List<String>.from(state.badHabits);
    if (current.contains(habit)) {
      current.remove(habit);
    } else {
      current.add(habit);
    }
    state = state.copyWith(badHabits: current);
  }

  void updateMotivations(List<String> motivations) {
    state = state.copyWith(motivations: motivations);
  }

  void toggleMotivation(String motivation) {
    final current = List<String>.from(state.motivations);
    if (current.contains(motivation)) {
      current.remove(motivation);
    } else {
      current.add(motivation);
    }
    state = state.copyWith(motivations: current);
  }

  void updateCommitment({required bool committedToLogDaily}) {
    state = state.copyWith(committedToLogDaily: committedToLogDaily);
  }

  Future<void> saveDraft({bool immediate = false}) async {
    if (immediate) {
      _draftTimer?.cancel();
      _pendingDraft = null;
      await _saveDraftNow(state);
      return;
    }

    // Debounce draft persistence to reduce jank (Isar tx can block frames).
    _pendingDraft = state;
    _draftTimer?.cancel();
    _draftTimer = Timer(const Duration(milliseconds: 600), () {
      final draft = _pendingDraft;
      _pendingDraft = null;
      if (draft == null) return;
      unawaited(_saveDraftNow(draft));
    });
  }

  Future<void> _saveDraftNow(UserProfile draft) async {
    if (_lastSavedDraft == draft) return;
    try {
      final isar = ref.read(isarProvider);
      final repository = ProfileRepository(isar);
      await repository.saveProfile(draft);
      _lastSavedDraft = draft;
    } catch (e) {
      if (DebugFlags.canVerbose) {
        debugPrint('DEBUG: saveDraft failed: $e');
      }
    }
  }

  Future<void> persistCompletion() async {
    if (DebugFlags.canVerbose) {
      debugPrint(
        'DEBUG: OnboardingNotifier.persistCompletion (before) isOnboardingCompleted=${state.isOnboardingCompleted}',
      );
    }
    state = state.copyWith(isOnboardingCompleted: true);
    await saveDraft(immediate: true);
    if (DebugFlags.canVerbose) {
      debugPrint(
        'DEBUG: OnboardingNotifier.persistCompletion (after) isOnboardingCompleted=${state.isOnboardingCompleted}',
      );
    }
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
      // Não marcar como concluído aqui.
      // Isso evita que o router reavalie redirects no meio do onboarding e
      // resete o PageView (parece “voltar pro início”).
      isOnboardingCompleted: state.isOnboardingCompleted,
    );

    // Save to local storage
    await saveDraft(immediate: true);
  }
}
