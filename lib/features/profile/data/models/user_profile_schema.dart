import 'dart:convert';
import 'package:isar/isar.dart';
import '../../domain/models/user_profile.dart';

part 'user_profile_schema.g.dart';

@collection
class UserProfileEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String profileId;

  String? name;

  @enumerated
  late Gender gender;

  late DateTime birthDate;
  late int height;
  late double currentWeight;
  late double startWeight;
  late double targetWeight;
  late double weeklyGoal;

  @enumerated
  late ActivityLevel activityLevel;

  @enumerated
  late MainGoal mainGoal;

  @enumerated
  late DietaryPreference dietaryPreference;

  @enumerated
  late FoodLoggingMethod foodLoggingMethod;

  late int calculatedCalories;
  late int proteinGrams;
  late int carbsGrams;
  late int fatGrams;
  late bool isOnboardingCompleted;
  String? favoriteFoodKeysJson;

  // Monetization / gating (nullable for smooth upgrades from older DBs)
  int? freeMealsRemaining;
  DateTime? challengeStartedAt;
  DateTime? challengeLastMealAt;
  int? challengeMealsRemaining;
  int? paywallDismissCount;
  bool? committedToLogDaily;

  // Mapper methods
  static UserProfileEntity fromDomain(UserProfile profile) {
    return UserProfileEntity()
      ..profileId = profile.id
      ..name = profile.name.trim().isEmpty ? null : profile.name.trim()
      ..gender = profile.gender
      ..birthDate = profile.birthDate
      ..height = profile.height
      ..currentWeight = profile.currentWeight
      ..startWeight = profile.startWeight
      ..targetWeight = profile.targetWeight
      ..weeklyGoal = profile.weeklyGoal
      ..activityLevel = profile.activityLevel
      ..mainGoal = profile.mainGoal
      ..dietaryPreference = profile.dietaryPreference
      ..foodLoggingMethod = profile.foodLoggingMethod
      ..calculatedCalories = profile.calculatedCalories
      ..proteinGrams = profile.proteinGrams
      ..carbsGrams = profile.carbsGrams
      ..fatGrams = profile.fatGrams
      ..isOnboardingCompleted = profile.isOnboardingCompleted
      ..favoriteFoodKeysJson = _encodeFavorites(profile.favoriteFoodKeys)
      ..freeMealsRemaining = profile.freeMealsRemaining
      ..challengeStartedAt = profile.challengeStartedAt
      ..challengeLastMealAt = profile.challengeLastMealAt
      ..challengeMealsRemaining = profile.challengeMealsRemaining
      ..paywallDismissCount = profile.paywallDismissCount
      ..committedToLogDaily = profile.committedToLogDaily;
  }

  UserProfile toDomain() {
    return UserProfile(
      id: profileId,
      name: name ?? '',
      gender: gender,
      birthDate: birthDate,
      height: height,
      currentWeight: currentWeight,
      startWeight: startWeight,
      targetWeight: targetWeight,
      weeklyGoal: weeklyGoal,
      activityLevel: activityLevel,
      mainGoal: mainGoal,
      dietaryPreference: dietaryPreference,
      foodLoggingMethod: foodLoggingMethod,
      calculatedCalories: calculatedCalories,
      proteinGrams: proteinGrams,
      carbsGrams: carbsGrams,
      fatGrams: fatGrams,
      favoriteFoodKeys: _decodeFavorites(favoriteFoodKeysJson),
      freeMealsRemaining: freeMealsRemaining ?? 7,
      challengeStartedAt: challengeStartedAt,
      challengeLastMealAt: challengeLastMealAt,
      challengeMealsRemaining: challengeMealsRemaining ?? 0,
      paywallDismissCount: paywallDismissCount ?? 0,
      committedToLogDaily: committedToLogDaily ?? false,
      isOnboardingCompleted: isOnboardingCompleted,
    );
  }

  static String? _encodeFavorites(List<String> keys) {
    if (keys.isEmpty) return null;
    return jsonEncode(keys);
  }

  static List<String> _decodeFavorites(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final data = jsonDecode(raw);
      if (data is List) {
        return data.whereType<String>().toList();
      }
    } catch (_) {}
    return const [];
  }
}
