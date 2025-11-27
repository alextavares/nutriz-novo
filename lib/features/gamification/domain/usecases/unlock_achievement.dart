import '../repositories/gamification_repository.dart';

class UnlockAchievement {
  final GamificationRepository _repository;

  UnlockAchievement(this._repository);

  Future<void> call(String achievementId) async {
    await _repository.unlockAchievement(achievementId);
  }
}
