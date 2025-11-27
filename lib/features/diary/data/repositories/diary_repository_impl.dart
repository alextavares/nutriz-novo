import 'package:isar/isar.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/diary_day.dart';
import '../../domain/entities/meal.dart';
import '../../domain/repositories/diary_repository.dart';
import '../../../../core/value_objects/weight.dart';
import '../../../../core/value_objects/water_volume.dart';
import '../models/diary_schemas.dart';

class DiaryRepositoryImpl implements DiaryRepository {
  final Isar _isar;

  DiaryRepositoryImpl(this._isar);

  @override
  Future<DiaryDay> getDiaryDay(DateTime date) async {
    final normalizedDate = DateUtils.dateOnly(date);
    final schema = await _isar.diaryDaySchemas
        .filter()
        .dateEqualTo(normalizedDate)
        .findFirst();

    if (schema == null) {
      // Retorna um dia vazio se não existir
      return DiaryDay(date: normalizedDate);
    }

    return schema.toEntity();
  }

  @override
  Future<void> saveDiaryDay(DiaryDay day) async {
    await _isar.writeTxn(() async {
      await _isar.diaryDaySchemas.put(DiaryDaySchema.fromEntity(day));
    });
  }

  @override
  Future<void> addMeal(DateTime date, Meal meal) async {
    final day = await getDiaryDay(date);
    final updatedMeals = [...day.meals, meal];
    final updatedDay = day.copyWith(meals: updatedMeals);
    await saveDiaryDay(updatedDay);
  }

  @override
  Future<void> updateWaterIntake(DateTime date, WaterVolume volume) async {
    final day = await getDiaryDay(date);
    final updatedDay = day.copyWith(waterIntake: volume);
    await saveDiaryDay(updatedDay);
  }

  @override
  Future<void> logWeight(DateTime date, Weight weight) async {
    // TODO: Implementar log de peso (pode ser em outra collection ou no DiaryDay)
    // Por enquanto, vamos assumir que não salvamos no DiaryDaySchema simplificado
  }
}
