import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_points.freezed.dart';
part 'user_points.g.dart';

@freezed
class UserPoints with _$UserPoints {
  const factory UserPoints({
    required int totalPoints,
    required int weeklyPoints,
    required List<PointHistoryEntry> history,
  }) = _UserPoints;

  factory UserPoints.fromJson(Map<String, dynamic> json) =>
      _$UserPointsFromJson(json);

  factory UserPoints.initial() =>
      const UserPoints(totalPoints: 0, weeklyPoints: 0, history: []);
}

@freezed
class PointHistoryEntry with _$PointHistoryEntry {
  const factory PointHistoryEntry({
    required String reason,
    required int points,
    required DateTime date,
  }) = _PointHistoryEntry;

  factory PointHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$PointHistoryEntryFromJson(json);
}
