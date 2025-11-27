import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../data/repositories/gamification_repository_impl.dart';
import '../../domain/repositories/gamification_repository.dart';
import '../../domain/usecases/award_points.dart';
import '../../domain/usecases/check_streak.dart';
import '../../domain/usecases/unlock_achievement.dart';
import '../notifiers/gamification_notifier.dart';
import '../notifiers/gamification_state.dart';

// Placeholder provider for Isar (needs to be initialized in main.dart and overridden)
final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError(
    'Isar must be initialized and overridden in main.dart',
  );
});

final gamificationRepositoryProvider = Provider<GamificationRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return GamificationRepositoryImpl(isar);
});

final awardPointsUseCaseProvider = Provider<AwardPoints>((ref) {
  return AwardPoints(ref.watch(gamificationRepositoryProvider));
});

final checkStreakUseCaseProvider = Provider<CheckStreak>((ref) {
  return CheckStreak(ref.watch(gamificationRepositoryProvider));
});

final unlockAchievementUseCaseProvider = Provider<UnlockAchievement>((ref) {
  return UnlockAchievement(ref.watch(gamificationRepositoryProvider));
});

final gamificationProvider =
    StateNotifierProvider<GamificationNotifier, GamificationState>((ref) {
      return GamificationNotifier(
        repository: ref.watch(gamificationRepositoryProvider),
        awardPoints: ref.watch(awardPointsUseCaseProvider),
        checkStreak: ref.watch(checkStreakUseCaseProvider),
        unlockAchievement: ref.watch(unlockAchievementUseCaseProvider),
      );
    });
