import '../repositories/diary_repository.dart';
import '../entities/diary_day.dart';

class GetDailySummary {
  final DiaryRepository _repository;

  GetDailySummary(this._repository);

  Future<DiaryDay> call(DateTime date) async {
    return _repository.getDiaryDay(date);
  }
}
