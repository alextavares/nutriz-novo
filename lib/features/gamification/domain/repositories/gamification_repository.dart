import '../entities/user_level.dart';
import '../entities/streak.dart';
import '../entities/achievement.dart';
import '../entities/user_points.dart';
import '../entities/daily_challenge.dart';

abstract class GamificationRepository {
  // Level & Points
  Future<UserLevel> getUserLevel();
  Future<void> saveUserLevel(UserLevel level);
  Future<UserPoints> getUserPoints();
  Future<void> saveUserPoints(UserPoints points);

  // Streak
  Future<Streak> getStreak();
  Future<void> saveStreak(Streak streak);

  // Achievements
  Future<List<Achievement>> getAchievements();
  Future<void> saveAchievement(Achievement achievement);
  Future<void> unlockAchievement(String achievementId);

  // Challenges
  Future<List<DailyChallenge>> getDailyChallenges(DateTime date);
  Future<void> saveDailyChallenge(DailyChallenge challenge);
}
