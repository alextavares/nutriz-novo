import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/value_objects/weight.dart';

part 'user_goal.freezed.dart';

enum GoalType { loseWeight, maintainWeight, gainMuscle }

enum ActivityLevel {
  sedentary, // Little or no exercise
  lightlyActive, // Light exercise 1-3 days/week
  moderatelyActive, // Moderate exercise 3-5 days/week
  veryActive, // Hard exercise 6-7 days/week
  extraActive, // Very hard exercise & physical job
}

@freezed
class UserGoal with _$UserGoal {
  const factory UserGoal({
    required GoalType type,
    required Weight targetWeight,
    required ActivityLevel activityLevel,
    required double weeklyGoalKg, // e.g., -0.5 kg/week
    required int calorieTarget,
    required int proteinTarget,
    required int carbsTarget,
    required int fatTarget,
  }) = _UserGoal;

  factory UserGoal.initial() => UserGoal(
    type: GoalType.loseWeight,
    targetWeight: Weight.fromKg(70),
    activityLevel: ActivityLevel.sedentary,
    weeklyGoalKg: -0.5,
    calorieTarget: 2000,
    proteinTarget: 150,
    carbsTarget: 200,
    fatTarget: 65,
  );
}
