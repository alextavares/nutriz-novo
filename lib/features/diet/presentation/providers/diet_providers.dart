import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/debug/debug_flags.dart';
import '../../../gamification/presentation/providers/gamification_providers.dart';
import '../../../profile/presentation/notifiers/profile_notifier.dart';
import '../../data/repositories/diet_plan_repository.dart';
import '../../domain/models/diet_meal.dart';
import '../../domain/models/diet_plan.dart';

final dietCatalogProvider = FutureProvider<List<DietMeal>>((ref) async {
  final raw = await rootBundle.loadString('assets/data/diet_meals.json');
  final data = jsonDecode(raw);
  if (data is! List) return const [];
  return data
      .whereType<Map>()
      .cast<Map<String, dynamic>>()
      .map(DietMeal.fromJson)
      .toList(growable: false);
});

final dietPlanRepositoryProvider = Provider<DietPlanRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return DietPlanRepository(isar);
});

final dietWeekStartProvider = Provider<DateTime>((ref) {
  return weekStartSunday(DateTime.now());
});

final dietWeekProvider = FutureProvider.autoDispose<DietPlanWeek>((ref) async {
  final weekStart = ref.watch(dietWeekStartProvider);
  final catalog = await ref.watch(dietCatalogProvider.future);
  final profile = ref.watch(profileNotifierProvider);
  final repo = ref.watch(dietPlanRepositoryProvider);

  // Some devices can hang on the first Isar read (init/file lock edge). Avoid a
  // "never ending spinner" by timing out and falling back to an in-memory plan.
  final fallback = repo.generateWeek(
    weekStart: weekStart,
    profileId: profile.id,
    catalog: catalog,
  );

  try {
    return await repo
        .getOrCreateWeek(
          weekStart: weekStart,
          profileId: profile.id,
          catalog: catalog,
        )
        .timeout(const Duration(seconds: 12));
  } on TimeoutException {
    if (DebugFlags.canLog) {
      debugPrint('DEBUG: dietWeekProvider timed out reading Isar; using fallback');
    }

    // Best-effort persistence in background (don't block UI).
    // ignore: unawaited_futures
    Future(() async {
      try {
        await repo.saveWeek(fallback).timeout(const Duration(seconds: 12));
      } catch (_) {}
    });

    return fallback;
  } catch (e) {
    if (DebugFlags.canLog) {
      debugPrint('DEBUG: dietWeekProvider failed ($e); using fallback');
    }
    return fallback;
  }
});

class DietPlanActions {
  DietPlanActions(this._ref);

  final Ref _ref;

  Future<void> replaceDay(DateTime day) async {
    final repo = _ref.read(dietPlanRepositoryProvider);
    final week = await _ref.read(dietWeekProvider.future);
    final catalog = await _ref.read(dietCatalogProvider.future);
    final profile = _ref.read(profileNotifierProvider);
    await repo.replaceDay(current: week, day: day, profileId: profile.id, catalog: catalog);
    _ref.invalidate(dietWeekProvider);
  }

  Future<void> replaceWeek() async {
    final repo = _ref.read(dietPlanRepositoryProvider);
    final week = await _ref.read(dietWeekProvider.future);
    final catalog = await _ref.read(dietCatalogProvider.future);
    final profile = _ref.read(profileNotifierProvider);
    await repo.replaceWeek(current: week, profileId: profile.id, catalog: catalog);
    _ref.invalidate(dietWeekProvider);
  }

  Future<void> toggleMealPin(DateTime day, DietMealType type) async {
    final repo = _ref.read(dietPlanRepositoryProvider);
    final week = await _ref.read(dietWeekProvider.future);

    final d = DateUtils.dateOnly(day);
    final nextDays = week.days.map((x) {
      if (!DateUtils.isSameDay(x.date, d)) return x;
      final nextLocked = <DietMealType>{...x.lockedTypes};
      if (nextLocked.contains(type)) {
        nextLocked.remove(type);
      } else {
        nextLocked.add(type);
      }
      return DietPlanDay(date: x.date, mealIdsByType: x.mealIdsByType, lockedTypes: nextLocked);
    }).toList(growable: false);

    await repo.saveWeek(DietPlanWeek(weekStart: week.weekStart, days: nextDays));
    _ref.invalidate(dietWeekProvider);
  }
}

final dietPlanActionsProvider = Provider<DietPlanActions>((ref) {
  return DietPlanActions(ref);
});

final dietSelectedDayProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});
