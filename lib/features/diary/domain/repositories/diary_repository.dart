import '../entities/diary_day.dart';
import '../entities/meal.dart';
import '../../../../core/value_objects/weight.dart';
import '../../../../core/value_objects/water_volume.dart';

abstract class DiaryRepository {
  Future<DiaryDay> getDiaryDay(DateTime date);
  Future<void> saveDiaryDay(DiaryDay day);

  // Atalhos para operações específicas (opcional, mas útil)
  Future<void> addMeal(DateTime date, Meal meal);
  Future<void> updateWaterIntake(DateTime date, WaterVolume volume);
  Future<void> logWeight(DateTime date, Weight weight);
}
