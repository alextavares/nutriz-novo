import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_level.dart';
import '../../domain/entities/streak.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/entities/user_points.dart';

part 'gamification_state.freezed.dart';

@freezed
class GamificationState with _$GamificationState {
  const factory GamificationState({
    required UserLevel userLevel,
    required Streak streak,
    required UserPoints userPoints,
    @Default([]) List<Achievement> achievements,
    @Default(AsyncValue.loading()) AsyncValue<void> isLoading,
  }) = _GamificationState;

  factory GamificationState.initial() => GamificationState(
    userLevel: UserLevel.initial(),
    streak: Streak.initial(),
    userPoints: UserPoints.initial(),
  );
}
