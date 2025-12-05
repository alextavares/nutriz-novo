import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/value_objects/height.dart';
import '../../../../core/value_objects/weight.dart';
import 'user_goal.dart';

part 'user_profile.freezed.dart';

enum Gender { male, female, other }

@freezed
class UserProfile with _$UserProfile {
  const UserProfile._();

  const factory UserProfile({
    required String id,
    required String name,
    required Gender gender,
    required DateTime birthDate,
    required Height height,
    required Weight startWeight,
    required Weight currentWeight,
    required UserGoal goal,
    String? photoUrl,
  }) = _UserProfile;

  factory UserProfile.initial() => UserProfile(
    id: 'user_1',
    name: 'Alexandre Tavares', // Mock default
    gender: Gender.male,
    birthDate: DateTime(1994, 1, 1), // Mock default
    height: Height.fromCm(175),
    startWeight: Weight.fromKg(80),
    currentWeight: Weight.fromKg(77),
    goal: UserGoal.initial(),
  );

  int get age {
    final today = DateTime.now();
    var age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  double get progressPercentage {
    final start = startWeight.kg;
    final current = currentWeight.kg;
    final target = goal.targetWeight.kg;

    if (start == target) return 1.0;

    final totalDiff = start - target;
    final currentDiff = start - current;

    // Avoid division by zero and clamp between 0 and 1
    if (totalDiff == 0) return 1.0;

    return (currentDiff / totalDiff).clamp(0.0, 1.0);
  }
}
