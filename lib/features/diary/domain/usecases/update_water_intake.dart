import '../repositories/diary_repository.dart';
import '../../../../core/value_objects/water_volume.dart';
import '../../../../features/gamification/domain/usecases/award_points.dart';

class UpdateWaterIntake {
  final DiaryRepository _repository;
  final AwardPoints _awardPoints;

  UpdateWaterIntake(this._repository, this._awardPoints);

  Future<void> call(DateTime date, WaterVolume volume) async {
    await _repository.updateWaterIntake(date, volume);

    // Gamification Hook: Award points for drinking water (simplificado)
    // Idealmente verificaria se atingiu a meta
    if (volume.valueMl >= 2000) {
      await _awardPoints(points: 5, reason: 'Meta de água atingida');
    }
  }
}
