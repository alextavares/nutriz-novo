import '../repositories/diary_repository.dart';

class UpdateFoodQuantity {
  final DiaryRepository _repository;

  UpdateFoodQuantity(this._repository);

  Future<void> call({
    required DateTime date,
    required String mealId,
    required double newQuantity,
  }) async {
    await _repository.updateMealQuantity(date, mealId, newQuantity);
  }
}
