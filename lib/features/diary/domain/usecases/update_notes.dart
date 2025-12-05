import '../repositories/diary_repository.dart';

class UpdateNotes {
  final DiaryRepository _repository;

  UpdateNotes(this._repository);

  Future<void> call(DateTime date, String notes) async {
    final day = await _repository.getDiaryDay(date);
    final updatedDay = day.copyWith(notes: notes);
    await _repository.saveDiaryDay(updatedDay);
  }
}
