import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_challenge.freezed.dart';
part 'daily_challenge.g.dart';

@freezed
class DailyChallenge with _$DailyChallenge {
  const factory DailyChallenge({
    required String id,
    required String title,
    required String description,
    required int rewardPoints,
    required bool isCompleted,
    required DateTime date,
  }) = _DailyChallenge;

  factory DailyChallenge.fromJson(Map<String, dynamic> json) =>
      _$DailyChallengeFromJson(json);
}
