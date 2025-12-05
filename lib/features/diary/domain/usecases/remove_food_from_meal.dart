import '../repositories/diary_repository.dart';

class RemoveFoodFromMeal {
  final DiaryRepository _repository;

  RemoveFoodFromMeal(this._repository);

  Future<void> call({required DateTime date, required String mealId}) async {
    await _repository.removeMeal(date, mealId);
  }
}
