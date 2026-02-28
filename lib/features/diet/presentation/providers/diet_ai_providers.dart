import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../profile/domain/models/user_profile.dart';
import '../../../profile/presentation/notifiers/profile_notifier.dart';
import '../../data/services/ai_diet_service.dart';
import '../../domain/models/diet_meal.dart';
import '../../domain/models/diet_plan.dart';
import 'diet_providers.dart';

final aiDietServiceProvider = Provider<AiDietService>((ref) {
  return AiDietService();
});

final dietReplaceInProgressProvider = StateProvider<bool>((ref) => false);
final dietReplaceMealInProgressProvider =
    StateProvider<Set<String>>((ref) => <String>{});

enum DietReplaceHint {
  higherProtein,
  lowerCarbs,
  lowerFat,
  noLactose,
  vegetarian,
  vegan,
}

String dietReplaceHintLabel(DietReplaceHint hint) {
  switch (hint) {
    case DietReplaceHint.higherProtein:
      return 'Mais proteína';
    case DietReplaceHint.lowerCarbs:
      return 'Menos carbo';
    case DietReplaceHint.lowerFat:
      return 'Menos gordura';
    case DietReplaceHint.noLactose:
      return 'Sem lactose';
    case DietReplaceHint.vegetarian:
      return 'Vegetariano';
    case DietReplaceHint.vegan:
      return 'Vegano';
  }
}

String dietReplaceHintWire(DietReplaceHint hint) {
  switch (hint) {
    case DietReplaceHint.higherProtein:
      return 'higher_protein';
    case DietReplaceHint.lowerCarbs:
      return 'lower_carbs';
    case DietReplaceHint.lowerFat:
      return 'lower_fat';
    case DietReplaceHint.noLactose:
      return 'no_lactose';
    case DietReplaceHint.vegetarian:
      return 'vegetarian';
    case DietReplaceHint.vegan:
      return 'vegan';
  }
}

String dietReplaceMealKey(DateTime day, DietMealType type) {
  final d = DateTime(day.year, day.month, day.day);
  return '${d.toIso8601String().split('T').first}:${type.name}';
}

class DietAiActions {
  DietAiActions(this._ref);

  final Ref _ref;

  List<DietMeal> _filterCandidates(
    UserProfile profile,
    DietMealType type,
    List<DietMeal> all, {
    Set<DietReplaceHint> hints = const {},
  }) {
    final candidates = all.where((m) => m.mealType == type).toList(growable: false);
    if (candidates.isEmpty) return const <DietMeal>[];

    bool containsAny(String haystack, List<String> needles) {
      for (final n in needles) {
        if (haystack.contains(n)) return true;
      }
      return false;
    }

    final pref = profile.dietaryPreference;
    final lowered = <DietMeal>[];

    for (final meal in candidates) {
      final text = ('${meal.title} ${meal.ingredients.join(' ')}').toLowerCase();

      final meatKeywords = <String>[
        'frango',
        'carne',
        'bov',
        'boi',
        'porco',
        'bacon',
        'presunto',
        'lingui',
        'salsich',
        'peru',
        'peito de',
        'calabresa',
        'hamburg',
      ];

      final fishKeywords = <String>[
        'peixe',
        'atum',
        'salm',
        'camar',
        'tiláp',
        'bacal',
        'sard',
      ];

    final animalProductKeywords = <String>[
      ...meatKeywords,
      ...fishKeywords,
      'ovo',
      'ovos',
      'leite',
      'queijo',
      'iogurte',
      'yogurt',
      'manteiga',
      'creme de leite',
      'requeijão',
      'mel',
      'whey',
      'caseína',
    ];

    final dairyKeywords = <String>[
      'leite',
      'queijo',
      'iogurte',
      'yogurt',
      'manteiga',
      'creme de leite',
      'requeijão',
      'whey',
      'caseína',
      'lactose',
    ];

    final isMeat = containsAny(text, meatKeywords);
    final isFish = containsAny(text, fishKeywords);
    final isAnimalProduct = containsAny(text, animalProductKeywords);
    final isDairy = containsAny(text, dairyKeywords);

    var ok = true;

    final forceVegan = hints.contains(DietReplaceHint.vegan);
    final forceVegetarian = hints.contains(DietReplaceHint.vegetarian);
    final forceNoLactose = hints.contains(DietReplaceHint.noLactose);

    switch (pref) {
      case DietaryPreference.vegan:
        ok = !isAnimalProduct;
        break;
      case DietaryPreference.vegetarian:
        ok = !(isMeat || isFish);
        break;
      case DietaryPreference.pescetarian:
        ok = !isMeat;
        break;
      case DietaryPreference.keto:
        ok = meal.carbsG <= (type == DietMealType.snack ? 10 : 15);
        break;
      case DietaryPreference.lowCarb:
        ok = meal.carbsG <= (type == DietMealType.snack ? 20 : 30);
        break;
      case DietaryPreference.highProtein:
        ok = meal.proteinG >= (type == DietMealType.lunch || type == DietMealType.dinner ? 22 : 14);
        break;
      case DietaryPreference.lowFat:
        ok = meal.fatG <= 12;
        break;
      default:
        ok = true;
    }

    if (ok && forceVegan) ok = !isAnimalProduct;
    if (ok && forceVegetarian) ok = !(isMeat || isFish);
    if (ok && forceNoLactose) ok = !isDairy;

    if (ok && hints.contains(DietReplaceHint.lowerCarbs)) {
      ok = meal.carbsG <= (type == DietMealType.snack ? 15 : 25);
    }
    if (ok && hints.contains(DietReplaceHint.lowerFat)) {
      ok = meal.fatG <= 10;
    }
    if (ok && hints.contains(DietReplaceHint.higherProtein)) {
      ok = meal.proteinG >= (type == DietMealType.lunch || type == DietMealType.dinner ? 25 : 16);
    }

    if (ok) lowered.add(meal);
  }

    // If filtering got too aggressive, fall back to the raw candidates.
    if (lowered.length < 5) return candidates;
    return lowered;
  }

  Future<void> replaceDayAi(DateTime day) async {
    final inProgress = _ref.read(dietReplaceInProgressProvider);
    if (inProgress) return;
    _ref.read(dietReplaceInProgressProvider.notifier).state = true;
    try {
      final week = await _ref.read(dietWeekProvider.future);
      final catalog = await _ref.read(dietCatalogProvider.future);
      final profile = _ref.read(profileNotifierProvider);
      final repo = _ref.read(dietPlanRepositoryProvider);

      final d = DateTime(day.year, day.month, day.day);
      final dayPlan = week.days.firstWhere(
        (x) => x.date.year == d.year && x.date.month == d.month && x.date.day == d.day,
        orElse: () => week.days.first,
      );

      final result = await _ref.read(aiDietServiceProvider).replaceDay(
            profile: profile,
            day: d,
            catalog: catalog,
            currentDayMealIds: dayPlan.mealIdsByType,
            lockedTypes: dayPlan.lockedTypes,
          );

      final nextDays = week.days.map((x) {
        final same =
            x.date.year == d.year && x.date.month == d.month && x.date.day == d.day;
        if (!same) return x;

        final nextMap = Map<DietMealType, String>.from(result.mealIdsByType);
        for (final t in x.lockedTypes) {
          final currentId = x.mealIdsByType[t];
          if (currentId != null && currentId.isNotEmpty) {
            nextMap[t] = currentId;
          }
        }
        return DietPlanDay(date: x.date, mealIdsByType: nextMap, lockedTypes: x.lockedTypes);
      }).toList(growable: false);

      await repo.saveWeek(DietPlanWeek(weekStart: week.weekStart, days: nextDays));
      _ref.invalidate(dietWeekProvider);
    } finally {
      _ref.read(dietReplaceInProgressProvider.notifier).state = false;
    }
  }

  Future<void> replaceMealAi(
    DateTime day,
    DietMealType type, {
    Set<DietReplaceHint> hints = const {},
  }) async {
    final d = DateTime(day.year, day.month, day.day);
    final key = dietReplaceMealKey(d, type);

    final inProgress = _ref.read(dietReplaceMealInProgressProvider);
    if (inProgress.contains(key)) return;
    _ref.read(dietReplaceMealInProgressProvider.notifier).state = {...inProgress, key};

    try {
      final week = await _ref.read(dietWeekProvider.future);
      final catalog = await _ref.read(dietCatalogProvider.future);
      final profile = _ref.read(profileNotifierProvider);
      final repo = _ref.read(dietPlanRepositoryProvider);
      final byId = {for (final m in catalog) m.id: m};

      final dayPlan = week.days.firstWhere(
        (x) => x.date.year == d.year && x.date.month == d.month && x.date.day == d.day,
        orElse: () => week.days.first,
      );
      if (dayPlan.lockedTypes.contains(type)) return;

      try {
        final currentId = dayPlan.mealIdsByType[type] ?? '';
        final weekUsedSameType = week.days
            .where((x) => !DateUtils.isSameDay(x.date, d))
            .map((x) => x.mealIdsByType[type] ?? '')
            .where((id) => id.isNotEmpty && id != currentId)
            .toSet()
            .toList(growable: false);

        final dayOtherIds = DietMealType.values
            .where((t) => t != type)
            .map((t) => dayPlan.mealIdsByType[t] ?? '')
            .where((id) => id.isNotEmpty)
            .toSet()
            .toList(growable: false);

        int sumKcal = 0, sumP = 0, sumC = 0, sumF = 0;
        for (final id in dayOtherIds) {
          final m = byId[id];
          if (m == null) continue;
          sumKcal += m.kcal;
          sumP += m.proteinG;
          sumC += m.carbsG;
          sumF += m.fatG;
        }

        int clamp0(int v) => v < 0 ? 0 : v;
        final remaining = <String, int>{
          'calories': clamp0(profile.calculatedCalories - sumKcal),
          'protein_g': clamp0(profile.proteinGrams - sumP),
          'carbs_g': clamp0(profile.carbsGrams - sumC),
          'fat_g': clamp0(profile.fatGrams - sumF),
        };

        final candidates = _filterCandidates(profile, type, catalog, hints: hints);

        final nextMealId = await _ref.read(aiDietServiceProvider).replaceMeal(
              profile: profile,
              day: d,
              mealType: type,
              catalog: candidates,
              currentDayMealIds: dayPlan.mealIdsByType,
              weekUsedSameTypeMealIds: weekUsedSameType,
              dayOtherMealIds: dayOtherIds,
              remaining: remaining,
              hints: hints.map(dietReplaceHintWire).toList(growable: false),
            );

        final nextDays = week.days.map((x) {
          final same =
              x.date.year == d.year && x.date.month == d.month && x.date.day == d.day;
          if (!same) return x;
          final nextMap = Map<DietMealType, String>.from(x.mealIdsByType);
          nextMap[type] = nextMealId;
          return DietPlanDay(date: x.date, mealIdsByType: nextMap);
        }).toList(growable: false);

        await repo.saveWeek(DietPlanWeek(weekStart: week.weekStart, days: nextDays));
      } catch (_) {
        await repo.replaceMeal(
          current: week,
          day: d,
          mealType: type,
          profileId: profile.id,
          catalog: catalog,
        );
      }

      _ref.invalidate(dietWeekProvider);
    } finally {
      final current = _ref.read(dietReplaceMealInProgressProvider);
      if (current.contains(key)) {
        final next = {...current}..remove(key);
        _ref.read(dietReplaceMealInProgressProvider.notifier).state = next;
      }
    }
  }
}

final dietAiActionsProvider = Provider<DietAiActions>((ref) {
  return DietAiActions(ref);
});
