import '../repositories/diary_repository.dart';
import '../../../../core/value_objects/weight.dart';
import '../../../../features/gamification/domain/usecases/award_points.dart';

class LogWeight {
  final DiaryRepository _repository;
  final AwardPoints _awardPoints;

  LogWeight(this._repository, this._awardPoints);

  Future<void> call(DateTime date, Weight weight) async {
    await _repository.logWeight(date, weight);

    // Gamification Hook
    await _awardPoints(points: 20, reason: 'Registrou peso');
  }
}
