import '../repositories/diary_repository.dart';
import '../entities/meal.dart';
import '../../../../features/gamification/domain/usecases/award_points.dart';

class AddFoodToMeal {
  final DiaryRepository _repository;
  final AwardPoints _awardPoints; // Gamification Integration!

  AddFoodToMeal(this._repository, this._awardPoints);

  Future<void> call({required DateTime date, required Meal meal}) async {
    await _repository.addMeal(date, meal);

    // Gamification Hook: Award points for logging a meal
    await _awardPoints(points: 10, reason: 'Registrou refeição');
  }
}
