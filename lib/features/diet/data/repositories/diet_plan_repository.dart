import 'dart:math';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import '../../domain/models/diet_meal.dart';
import '../../domain/models/diet_plan.dart';
import '../models/diet_plan_schema.dart';

DateTime weekStartSunday(DateTime date) {
  final d = DateUtils.dateOnly(date);
  final weekday = d.weekday; // Mon=1..Sun=7
  final daysFromSunday = weekday % 7; // Sun -> 0
  return d.subtract(Duration(days: daysFromSunday));
}

class DietPlanRepository {
  DietPlanRepository(this._isar);

  final Isar _isar;

  /// Generates a week plan deterministically (no DB access).
  DietPlanWeek generateWeek({
    required DateTime weekStart,
    required String profileId,
    required List<DietMeal> catalog,
    int salt = 0,
  }) {
    return _generateWeek(
      weekStart,
      profileId: profileId,
      catalog: catalog,
      salt: salt,
    );
  }

  Future<DietPlanWeek?> getWeek(DateTime weekStart) async {
    final ws = DateUtils.dateOnly(weekStart);
    final entity = await _isar.dietPlanWeekEntitys
        .filter()
        .weekStartEqualTo(ws)
        .findFirst();
    return entity?.toDomain();
  }

  Future<DietPlanWeek> getOrCreateWeek({
    required DateTime weekStart,
    required String profileId,
    required List<DietMeal> catalog,
  }) async {
    final ws = DateUtils.dateOnly(weekStart);
    final existing = await getWeek(ws);
    if (existing != null) return existing;

    final plan = _generateWeek(ws, profileId: profileId, catalog: catalog);
    await saveWeek(plan);
    return plan;
  }

  Future<void> saveWeek(DietPlanWeek plan) async {
    final entity = DietPlanWeekEntity.fromDomain(plan);
    await _isar.writeTxn(() async {
      await _isar.dietPlanWeekEntitys.put(entity);
    });
  }

  Future<DietPlanWeek> replaceDay({
    required DietPlanWeek current,
    required DateTime day,
    required String profileId,
    required List<DietMeal> catalog,
  }) async {
    final target = DateUtils.dateOnly(day);
    final days = current.days.map((d) {
      if (!DateUtils.isSameDay(d.date, target)) return d;
      final index = target.difference(current.weekStart).inDays.clamp(0, 6);
      final generated = _generateDay(
        target,
        profileId: profileId,
        catalog: catalog,
        salt: 1000 + index,
      );

      if (d.lockedTypes.isEmpty) return generated;
      final nextMap = Map<DietMealType, String>.from(generated.mealIdsByType);
      for (final t in d.lockedTypes) {
        final currentId = d.mealIdsByType[t];
        if (currentId != null && currentId.isNotEmpty) {
          nextMap[t] = currentId;
        }
      }
      return DietPlanDay(date: generated.date, mealIdsByType: nextMap, lockedTypes: d.lockedTypes);
    }).toList(growable: false);

    final next = DietPlanWeek(weekStart: current.weekStart, days: days);
    await saveWeek(next);
    return next;
  }

  Future<DietPlanWeek> replaceWeek({
    required DietPlanWeek current,
    required String profileId,
    required List<DietMeal> catalog,
  }) async {
    final next = _generateWeek(
      current.weekStart,
      profileId: profileId,
      catalog: catalog,
      salt: 2000,
    );

    // Preserve locked meals from the current week when possible.
    final preservedDays = next.days.map((d) {
      final currentDay = current.days.firstWhere(
        (x) => DateUtils.isSameDay(x.date, d.date),
        orElse: () => d,
      );
      if (currentDay.lockedTypes.isEmpty) return d;

      final nextMap = Map<DietMealType, String>.from(d.mealIdsByType);
      for (final t in currentDay.lockedTypes) {
        final currentId = currentDay.mealIdsByType[t];
        if (currentId != null && currentId.isNotEmpty) {
          nextMap[t] = currentId;
        }
      }
      return DietPlanDay(date: d.date, mealIdsByType: nextMap, lockedTypes: currentDay.lockedTypes);
    }).toList(growable: false);

    final preserved = DietPlanWeek(weekStart: next.weekStart, days: preservedDays);
    await saveWeek(preserved);
    return preserved;
  }

  Future<DietPlanWeek> replaceMeal({
    required DietPlanWeek current,
    required DateTime day,
    required DietMealType mealType,
    required String profileId,
    required List<DietMeal> catalog,
  }) async {
    final target = DateUtils.dateOnly(day);
    final dayIndex = target.difference(current.weekStart).inDays.clamp(0, 6);
    final seed = _hashSeed(profileId, target, 3000 + (dayIndex * 10) + mealType.index);
    final rnd = Random(seed);

    String pickNextId(String currentId, Set<String> avoid) {
      final list = catalog.where((m) => m.mealType == mealType).toList(growable: false);
      if (list.isEmpty) return currentId;
      if (list.length == 1) return list.first.id;

      final allowed = list
          .where((m) => m.id != currentId && !avoid.contains(m.id))
          .map((m) => m.id)
          .toList(growable: false);
      if (allowed.isNotEmpty) {
        return allowed[rnd.nextInt(allowed.length)];
      }

      // Fallback: just avoid the current one, even if it repeats within the week/day.
      final notCurrent = list
          .where((m) => m.id != currentId)
          .map((m) => m.id)
          .toList(growable: false);
      if (notCurrent.isNotEmpty) {
        return notCurrent[rnd.nextInt(notCurrent.length)];
      }
      return list[rnd.nextInt(list.length)].id;
    }

    final days = current.days.map((d) {
      if (!DateUtils.isSameDay(d.date, target)) return d;
      if (d.lockedTypes.contains(mealType)) return d;
      final currentId = d.mealIdsByType[mealType] ?? '';

      final weekUsedSameType = current.days
          .where((x) => !DateUtils.isSameDay(x.date, target))
          .map((x) => x.mealIdsByType[mealType] ?? '')
          .where((id) => id.isNotEmpty && id != currentId)
          .toSet();

      final dayOtherIds = DietMealType.values
          .where((t) => t != mealType)
          .map((t) => d.mealIdsByType[t] ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();

      final avoid = <String>{...weekUsedSameType, ...dayOtherIds};
      final nextId = pickNextId(currentId, avoid);
      final nextMap = Map<DietMealType, String>.from(d.mealIdsByType);
      nextMap[mealType] = nextId;
      return DietPlanDay(date: d.date, mealIdsByType: nextMap, lockedTypes: d.lockedTypes);
    }).toList(growable: false);

    final next = DietPlanWeek(weekStart: current.weekStart, days: days);
    await saveWeek(next);
    return next;
  }

  DietPlanWeek _generateWeek(
    DateTime weekStart, {
    required String profileId,
    required List<DietMeal> catalog,
    int salt = 0,
  }) {
    final ws = DateUtils.dateOnly(weekStart);
    final days = List.generate(7, (i) {
      final date = ws.add(Duration(days: i));
      return _generateDay(date, profileId: profileId, catalog: catalog, salt: salt + i);
    });
    return DietPlanWeek(weekStart: ws, days: days);
  }

  DietPlanDay _generateDay(
    DateTime day, {
    required String profileId,
    required List<DietMeal> catalog,
    required int salt,
  }) {
    final seed = _hashSeed(profileId, day, salt);
    final rnd = Random(seed);

    String pick(DietMealType type) {
      final list = catalog.where((m) => m.mealType == type).toList(growable: false);
      if (list.isEmpty) return '';
      return list[rnd.nextInt(list.length)].id;
    }

    return DietPlanDay(
      date: DateUtils.dateOnly(day),
      mealIdsByType: {
        DietMealType.breakfast: pick(DietMealType.breakfast),
        DietMealType.lunch: pick(DietMealType.lunch),
        DietMealType.dinner: pick(DietMealType.dinner),
        DietMealType.snack: pick(DietMealType.snack),
      },
    );
  }

  int _hashSeed(String profileId, DateTime day, int salt) {
    var h = 17;
    for (final codeUnit in profileId.codeUnits) {
      h = 37 * h + codeUnit;
    }
    h = 37 * h + day.year;
    h = 37 * h + day.month;
    h = 37 * h + day.day;
    h = 37 * h + salt;
    return h & 0x7fffffff;
  }
}
