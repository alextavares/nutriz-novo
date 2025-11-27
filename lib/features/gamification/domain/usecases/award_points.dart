import '../repositories/gamification_repository.dart';
import '../entities/user_points.dart';

class AwardPoints {
  final GamificationRepository _repository;

  AwardPoints(this._repository);

  Future<void> call({required int points, required String reason}) async {
    final currentPoints = await _repository.getUserPoints();
    final currentLevel = await _repository.getUserLevel();

    final newTotalPoints = currentPoints.totalPoints + points;
    final newWeeklyPoints = currentPoints.weeklyPoints + points;

    final newHistory = [
      ...currentPoints.history,
      PointHistoryEntry(reason: reason, points: points, date: DateTime.now()),
    ];

    final updatedPoints = currentPoints.copyWith(
      totalPoints: newTotalPoints,
      weeklyPoints: newWeeklyPoints,
      history: newHistory,
    );

    await _repository.saveUserPoints(updatedPoints);

    // Check Level Up
    if (currentLevel.currentXp + points >= currentLevel.xpToNextLevel) {
      final newLevel = currentLevel.currentLevel + 1;
      final remainingXp =
          (currentLevel.currentXp + points) - currentLevel.xpToNextLevel;
      // Lógica simples de XP progressivo: nível * 100
      final newXpToNext = newLevel * 100;

      final updatedLevel = currentLevel.copyWith(
        currentLevel: newLevel,
        currentXp: remainingXp,
        xpToNextLevel: newXpToNext,
      );
      await _repository.saveUserLevel(updatedLevel);
    } else {
      final updatedLevel = currentLevel.copyWith(
        currentXp: currentLevel.currentXp + points,
      );
      await _repository.saveUserLevel(updatedLevel);
    }
  }
}
