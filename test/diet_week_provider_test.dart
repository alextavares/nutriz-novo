import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';

import 'package:nutriz/features/diet/data/repositories/diet_plan_repository.dart';
import 'package:nutriz/features/diet/domain/models/diet_meal.dart';
import 'package:nutriz/features/diet/domain/models/diet_plan.dart';
import 'package:nutriz/features/diet/presentation/providers/diet_providers.dart';
import 'package:nutriz/features/profile/domain/models/user_profile.dart';
import 'package:nutriz/features/profile/presentation/notifiers/profile_notifier.dart';

class _FakeIsar extends Fake implements Isar {}

class _TimeoutDietPlanRepository extends DietPlanRepository {
  _TimeoutDietPlanRepository() : super(_FakeIsar());

  DietPlanWeek? lastSavedWeek;

  @override
  Future<DietPlanWeek> getOrCreateWeek({
    required DateTime weekStart,
    required String profileId,
    required List<DietMeal> catalog,
  }) async {
    throw TimeoutException('simulated Isar hang');
  }

  @override
  Future<void> saveWeek(DietPlanWeek plan) async {
    lastSavedWeek = plan;
  }
}

class _TestProfileNotifier extends ProfileNotifier {
  _TestProfileNotifier(this._profile);
  final UserProfile _profile;

  @override
  UserProfile build() => _profile;
}

void main() {
  test('dietWeekProvider falls back when repo times out', () async {
    final repo = _TimeoutDietPlanRepository();
    final weekStart = DateTime(2026, 1, 4); // Sunday

    const breakfast =
        DietMeal(id: 'b1', mealType: DietMealType.breakfast, title: 'B', kcal: 1, proteinG: 1, carbsG: 1, fatG: 1, ingredients: [], steps: []);
    const lunch =
        DietMeal(id: 'l1', mealType: DietMealType.lunch, title: 'L', kcal: 1, proteinG: 1, carbsG: 1, fatG: 1, ingredients: [], steps: []);
    const dinner =
        DietMeal(id: 'd1', mealType: DietMealType.dinner, title: 'D', kcal: 1, proteinG: 1, carbsG: 1, fatG: 1, ingredients: [], steps: []);
    const snack =
        DietMeal(id: 's1', mealType: DietMealType.snack, title: 'S', kcal: 1, proteinG: 1, carbsG: 1, fatG: 1, ingredients: [], steps: []);

    final profile = UserProfile(
      id: 'p1',
      gender: Gender.male,
      birthDate: DateTime(1990, 1, 1),
      height: 170,
      currentWeight: 70,
      targetWeight: 70,
      weeklyGoal: 0,
      activityLevel: ActivityLevel.sedentary,
      mainGoal: MainGoal.maintain,
      dietaryPreference: DietaryPreference.balanced,
      calculatedCalories: 2000,
      proteinGrams: 150,
      carbsGrams: 200,
      fatGrams: 60,
    );

    final container = ProviderContainer(
      overrides: [
        dietPlanRepositoryProvider.overrideWithValue(repo),
        dietWeekStartProvider.overrideWithValue(weekStart),
        dietCatalogProvider.overrideWith((ref) async => const [breakfast, lunch, dinner, snack]),
        profileNotifierProvider.overrideWith(() => _TestProfileNotifier(profile)),
      ],
    );
    addTearDown(container.dispose);

    final week = await container.read(dietWeekProvider.future);

    expect(week.weekStart, DateUtils.dateOnly(weekStart));
    expect(week.days, hasLength(7));
    for (final day in week.days) {
      expect(day.mealIdsByType[DietMealType.breakfast], 'b1');
      expect(day.mealIdsByType[DietMealType.lunch], 'l1');
      expect(day.mealIdsByType[DietMealType.dinner], 'd1');
      expect(day.mealIdsByType[DietMealType.snack], 's1');
    }

    // Background persistence is best-effort; if it runs, it should match.
    await Future<void>.delayed(Duration.zero);
    if (repo.lastSavedWeek != null) {
      expect(repo.lastSavedWeek!.weekStart, week.weekStart);
      expect(repo.lastSavedWeek!.days, hasLength(7));
    }
  });
}
