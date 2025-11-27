import 'package:freezed_annotation/freezed_annotation.dart';

part 'streak.freezed.dart';
part 'streak.g.dart';

@freezed
class Streak with _$Streak {
  const factory Streak({
    required int currentStreak,
    required int bestStreak,
    required DateTime lastActivityDate,
    @Default([])
    List<DateTime> frozenDays, // Dias protegidos por "Streak Freeze"
  }) = _Streak;

  factory Streak.fromJson(Map<String, dynamic> json) => _$StreakFromJson(json);

  factory Streak.initial() => Streak(
    currentStreak: 0,
    bestStreak: 0,
    lastActivityDate: DateTime.now().subtract(const Duration(days: 1)),
  );
}
