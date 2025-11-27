import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/award_points.dart';
import '../../domain/usecases/check_streak.dart';
import '../../domain/usecases/unlock_achievement.dart';
import '../../domain/repositories/gamification_repository.dart';
import 'gamification_state.dart';

class GamificationNotifier extends StateNotifier<GamificationState> {
  final GamificationRepository _repository;
  final AwardPoints _awardPoints;
  final CheckStreak _checkStreak;
  final UnlockAchievement _unlockAchievement;

  GamificationNotifier({
    required GamificationRepository repository,
    required AwardPoints awardPoints,
    required CheckStreak checkStreak,
    required UnlockAchievement unlockAchievement,
  }) : _repository = repository,
       _awardPoints = awardPoints,
       _checkStreak = checkStreak,
       _unlockAchievement = unlockAchievement,
       super(GamificationState.initial()) {
    loadGamificationData();
  }

  Future<void> loadGamificationData() async {
    state = state.copyWith(isLoading: const AsyncValue.loading());
    try {
      final level = await _repository.getUserLevel();
      final points = await _repository.getUserPoints();
      final streak = await _repository.getStreak();
      final achievements = await _repository.getAchievements();

      state = state.copyWith(
        userLevel: level,
        userPoints: points,
        streak: streak,
        achievements: achievements,
        isLoading: const AsyncValue.data(null),
      );
    } catch (e, st) {
      state = state.copyWith(isLoading: AsyncValue.error(e, st));
    }
  }

  Future<void> awardPoints({
    required int points,
    required String reason,
  }) async {
    await _awardPoints(points: points, reason: reason);
    await loadGamificationData(); // Reload to update UI
  }

  Future<void> checkStreak() async {
    await _checkStreak();
    await loadGamificationData();
  }

  Future<void> unlockAchievement(String achievementId) async {
    await _unlockAchievement(achievementId);
    await loadGamificationData();
  }
}
