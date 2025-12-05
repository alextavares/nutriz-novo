import 'package:isar/isar.dart';
import '../../domain/models/user_profile.dart';

part 'user_profile_schema.g.dart';

@collection
class UserProfileEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String profileId;

  @enumerated
  late Gender gender;

  late DateTime birthDate;
  late int height;
  late double currentWeight;
  late double targetWeight;
  late double weeklyGoal;

  @enumerated
  late ActivityLevel activityLevel;

  @enumerated
  late MainGoal mainGoal;

  @enumerated
  late DietaryPreference dietaryPreference;

  late int calculatedCalories;
  late int proteinGrams;
  late int carbsGrams;
  late int fatGrams;
  late bool isOnboardingCompleted;

  // Mapper methods
  static UserProfileEntity fromDomain(UserProfile profile) {
    return UserProfileEntity()
      ..profileId = profile.id
      ..gender = profile.gender
      ..birthDate = profile.birthDate
      ..height = profile.height
      ..currentWeight = profile.currentWeight
      ..targetWeight = profile.targetWeight
      ..weeklyGoal = profile.weeklyGoal
      ..activityLevel = profile.activityLevel
      ..mainGoal = profile.mainGoal
      ..dietaryPreference = profile.dietaryPreference
      ..calculatedCalories = profile.calculatedCalories
      ..proteinGrams = profile.proteinGrams
      ..carbsGrams = profile.carbsGrams
      ..fatGrams = profile.fatGrams
      ..isOnboardingCompleted = profile.isOnboardingCompleted;
  }

  UserProfile toDomain() {
    return UserProfile(
      id: profileId,
      gender: gender,
      birthDate: birthDate,
      height: height,
      currentWeight: currentWeight,
      targetWeight: targetWeight,
      weeklyGoal: weeklyGoal,
      activityLevel: activityLevel,
      mainGoal: mainGoal,
      dietaryPreference: dietaryPreference,
      calculatedCalories: calculatedCalories,
      proteinGrams: proteinGrams,
      carbsGrams: carbsGrams,
      fatGrams: fatGrams,
      isOnboardingCompleted: isOnboardingCompleted,
    );
  }
}
