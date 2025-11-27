import 'package:isar/isar.dart';
import '../../domain/entities/user_level.dart';
import '../../domain/entities/streak.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/user_points.dart';
import '../../domain/entities/daily_challenge.dart';

part 'gamification_schemas.g.dart';

@collection
class UserLevelSchema {
  Id id = Isar.autoIncrement;
  late int currentLevel;
  late int currentXp;
  late int xpToNextLevel;
  late String title;

  UserLevel toEntity() {
    return UserLevel(
      currentLevel: currentLevel,
      currentXp: currentXp,
      xpToNextLevel: xpToNextLevel,
      title: title,
    );
  }

  static UserLevelSchema fromEntity(UserLevel entity) {
    return UserLevelSchema()
      ..currentLevel = entity.currentLevel
      ..currentXp = entity.currentXp
      ..xpToNextLevel = entity.xpToNextLevel
      ..title = entity.title;
  }
}

@collection
class StreakSchema {
  Id id = Isar.autoIncrement;
  late int currentStreak;
  late int bestStreak;
  late DateTime lastActivityDate;
  late List<DateTime> frozenDays;

  Streak toEntity() {
    return Streak(
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      lastActivityDate: lastActivityDate,
      frozenDays: frozenDays,
    );
  }

  static StreakSchema fromEntity(Streak entity) {
    return StreakSchema()
      ..currentStreak = entity.currentStreak
      ..bestStreak = entity.bestStreak
      ..lastActivityDate = entity.lastActivityDate
      ..frozenDays = entity.frozenDays;
  }
}

@collection
class AchievementSchema {
  Id id = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String achievementId;
  late String title;
  late String description;
  late String iconPath;
  late bool isUnlocked;
  DateTime? unlockedAt;
  late int progress;
  late int maxProgress;
  late bool isSecret;

  Achievement toEntity() {
    return Achievement(
      id: achievementId,
      title: title,
      description: description,
      iconPath: iconPath,
      isUnlocked: isUnlocked,
      unlockedAt: unlockedAt,
      progress: progress,
      maxProgress: maxProgress,
      isSecret: isSecret,
    );
  }

  static AchievementSchema fromEntity(Achievement entity) {
    return AchievementSchema()
      ..achievementId = entity.id
      ..title = entity.title
      ..description = entity.description
      ..iconPath = entity.iconPath
      ..isUnlocked = entity.isUnlocked
      ..unlockedAt = entity.unlockedAt
      ..progress = entity.progress
      ..maxProgress = entity.maxProgress
      ..isSecret = entity.isSecret;
  }
}

@collection
class UserPointsSchema {
  Id id = Isar.autoIncrement;
  late int totalPoints;
  late int weeklyPoints;
  // Isar não suporta listas de objetos complexos diretamente sem Embedded,
  // simplificando para JSON string ou Embedded se necessário.
  // Usando Embedded para histórico simples.
  late List<PointHistoryEmbedded> history;

  UserPoints toEntity() {
    return UserPoints(
      totalPoints: totalPoints,
      weeklyPoints: weeklyPoints,
      history: history.map((e) => e.toEntity()).toList(),
    );
  }

  static UserPointsSchema fromEntity(UserPoints entity) {
    return UserPointsSchema()
      ..totalPoints = entity.totalPoints
      ..weeklyPoints = entity.weeklyPoints
      ..history = entity.history
          .map((e) => PointHistoryEmbedded.fromEntity(e))
          .toList();
  }
}

@embedded
class PointHistoryEmbedded {
  late String reason;
  late int points;
  late DateTime date;

  PointHistoryEntry toEntity() {
    return PointHistoryEntry(reason: reason, points: points, date: date);
  }

  static PointHistoryEmbedded fromEntity(PointHistoryEntry entity) {
    return PointHistoryEmbedded()
      ..reason = entity.reason
      ..points = entity.points
      ..date = entity.date;
  }
}

@collection
class DailyChallengeSchema {
  Id id = Isar.autoIncrement;
  @Index(unique: true, replace: true)
  late String challengeId;
  late String title;
  late String description;
  late int rewardPoints;
  late bool isCompleted;
  late DateTime date;

  DailyChallenge toEntity() {
    return DailyChallenge(
      id: challengeId,
      title: title,
      description: description,
      rewardPoints: rewardPoints,
      isCompleted: isCompleted,
      date: date,
    );
  }

  static DailyChallengeSchema fromEntity(DailyChallenge entity) {
    return DailyChallengeSchema()
      ..challengeId = entity.id
      ..title = entity.title
      ..description = entity.description
      ..rewardPoints = entity.rewardPoints
      ..isCompleted = entity.isCompleted
      ..date = entity.date;
  }
}
