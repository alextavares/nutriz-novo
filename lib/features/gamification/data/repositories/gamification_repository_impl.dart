import 'package:isar/isar.dart';
import '../../domain/entities/user_level.dart';
import '../../domain/entities/streak.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/user_points.dart';
import '../../domain/entities/daily_challenge.dart';
import '../../domain/repositories/gamification_repository.dart';
import '../models/gamification_schemas.dart';

class GamificationRepositoryImpl implements GamificationRepository {
  final Isar _isar;

  GamificationRepositoryImpl(this._isar);

  @override
  Future<UserLevel> getUserLevel() async {
    final schema = await _isar.userLevelSchemas.where().findFirst();
    return schema?.toEntity() ?? UserLevel.initial();
  }

  @override
  Future<void> saveUserLevel(UserLevel level) async {
    await _isar.writeTxn(() async {
      await _isar.userLevelSchemas.put(UserLevelSchema.fromEntity(level));
    });
  }

  @override
  Future<UserPoints> getUserPoints() async {
    final schema = await _isar.userPointsSchemas.where().findFirst();
    return schema?.toEntity() ?? UserPoints.initial();
  }

  @override
  Future<void> saveUserPoints(UserPoints points) async {
    await _isar.writeTxn(() async {
      await _isar.userPointsSchemas.put(UserPointsSchema.fromEntity(points));
    });
  }

  @override
  Future<Streak> getStreak() async {
    final schema = await _isar.streakSchemas.where().findFirst();
    return schema?.toEntity() ?? Streak.initial();
  }

  @override
  Future<void> saveStreak(Streak streak) async {
    await _isar.writeTxn(() async {
      await _isar.streakSchemas.put(StreakSchema.fromEntity(streak));
    });
  }

  @override
  Future<List<Achievement>> getAchievements() async {
    final schemas = await _isar.achievementSchemas.where().findAll();
    return schemas.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> saveAchievement(Achievement achievement) async {
    await _isar.writeTxn(() async {
      await _isar.achievementSchemas.put(
        AchievementSchema.fromEntity(achievement),
      );
    });
  }

  @override
  Future<void> unlockAchievement(String achievementId) async {
    await _isar.writeTxn(() async {
      final schema = await _isar.achievementSchemas
          .filter()
          .achievementIdEqualTo(achievementId)
          .findFirst();
      if (schema != null) {
        schema.isUnlocked = true;
        schema.unlockedAt = DateTime.now();
        await _isar.achievementSchemas.put(schema);
      }
    });
  }

  @override
  Future<List<DailyChallenge>> getDailyChallenges(DateTime date) async {
    // Simplificação: pegando todos por enquanto, ideal seria filtrar por data
    final schemas = await _isar.dailyChallengeSchemas.where().findAll();
    return schemas.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> saveDailyChallenge(DailyChallenge challenge) async {
    await _isar.writeTxn(() async {
      await _isar.dailyChallengeSchemas.put(
        DailyChallengeSchema.fromEntity(challenge),
      );
    });
  }
}
