// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      gender: $enumDecode(_$GenderEnumMap, json['gender']),
      birthDate: DateTime.parse(json['birthDate'] as String),
      height: (json['height'] as num).toInt(),
      currentWeight: (json['currentWeight'] as num).toDouble(),
      targetWeight: (json['targetWeight'] as num).toDouble(),
      weeklyGoal: (json['weeklyGoal'] as num).toDouble(),
      activityLevel: $enumDecode(_$ActivityLevelEnumMap, json['activityLevel']),
      mainGoal: $enumDecode(_$MainGoalEnumMap, json['mainGoal']),
      dietaryPreference:
          $enumDecode(_$DietaryPreferenceEnumMap, json['dietaryPreference']),
      sleepDuration:
          $enumDecodeNullable(_$SleepDurationEnumMap, json['sleepDuration']) ??
              SleepDuration.sevenToEight,
      waterIntake:
          $enumDecodeNullable(_$WaterIntakeEnumMap, json['waterIntake']) ??
              WaterIntake.oneToTwoL,
      badHabits: (json['badHabits'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      motivations: (json['motivations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      calculatedCalories: (json['calculatedCalories'] as num).toInt(),
      proteinGrams: (json['proteinGrams'] as num).toInt(),
      carbsGrams: (json['carbsGrams'] as num).toInt(),
      fatGrams: (json['fatGrams'] as num).toInt(),
      weeksToGoal: (json['weeksToGoal'] as num?)?.toInt(),
      estimatedGoalDate: json['estimatedGoalDate'] == null
          ? null
          : DateTime.parse(json['estimatedGoalDate'] as String),
      favoriteFoodKeys: (json['favoriteFoodKeys'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      freeMealsRemaining: (json['freeMealsRemaining'] as num?)?.toInt() ?? 1,
      challengeStartedAt: json['challengeStartedAt'] == null
          ? null
          : DateTime.parse(json['challengeStartedAt'] as String),
      challengeLastMealAt: json['challengeLastMealAt'] == null
          ? null
          : DateTime.parse(json['challengeLastMealAt'] as String),
      challengeMealsRemaining:
          (json['challengeMealsRemaining'] as num?)?.toInt() ?? 0,
      paywallDismissCount: (json['paywallDismissCount'] as num?)?.toInt() ?? 0,
      committedToLogDaily: json['committedToLogDaily'] as bool? ?? false,
      isOnboardingCompleted: json['isOnboardingCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'gender': _$GenderEnumMap[instance.gender]!,
      'birthDate': instance.birthDate.toIso8601String(),
      'height': instance.height,
      'currentWeight': instance.currentWeight,
      'targetWeight': instance.targetWeight,
      'weeklyGoal': instance.weeklyGoal,
      'activityLevel': _$ActivityLevelEnumMap[instance.activityLevel]!,
      'mainGoal': _$MainGoalEnumMap[instance.mainGoal]!,
      'dietaryPreference':
          _$DietaryPreferenceEnumMap[instance.dietaryPreference]!,
      'sleepDuration': _$SleepDurationEnumMap[instance.sleepDuration]!,
      'waterIntake': _$WaterIntakeEnumMap[instance.waterIntake]!,
      'badHabits': instance.badHabits,
      'motivations': instance.motivations,
      'calculatedCalories': instance.calculatedCalories,
      'proteinGrams': instance.proteinGrams,
      'carbsGrams': instance.carbsGrams,
      'fatGrams': instance.fatGrams,
      'weeksToGoal': instance.weeksToGoal,
      'estimatedGoalDate': instance.estimatedGoalDate?.toIso8601String(),
      'favoriteFoodKeys': instance.favoriteFoodKeys,
      'freeMealsRemaining': instance.freeMealsRemaining,
      'challengeStartedAt': instance.challengeStartedAt?.toIso8601String(),
      'challengeLastMealAt': instance.challengeLastMealAt?.toIso8601String(),
      'challengeMealsRemaining': instance.challengeMealsRemaining,
      'paywallDismissCount': instance.paywallDismissCount,
      'committedToLogDaily': instance.committedToLogDaily,
      'isOnboardingCompleted': instance.isOnboardingCompleted,
    };

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
};

const _$ActivityLevelEnumMap = {
  ActivityLevel.sedentary: 'sedentary',
  ActivityLevel.low: 'low',
  ActivityLevel.active: 'active',
  ActivityLevel.veryActive: 'veryActive',
};

const _$MainGoalEnumMap = {
  MainGoal.loseWeight: 'loseWeight',
  MainGoal.maintain: 'maintain',
  MainGoal.buildMuscle: 'buildMuscle',
};

const _$DietaryPreferenceEnumMap = {
  DietaryPreference.classic: 'classic',
  DietaryPreference.pescetarian: 'pescetarian',
  DietaryPreference.vegetarian: 'vegetarian',
  DietaryPreference.vegan: 'vegan',
};

const _$SleepDurationEnumMap = {
  SleepDuration.lessThan5: 'lessThan5',
  SleepDuration.fiveToSix: 'fiveToSix',
  SleepDuration.sevenToEight: 'sevenToEight',
  SleepDuration.moreThan8: 'moreThan8',
};

const _$WaterIntakeEnumMap = {
  WaterIntake.lessThan1L: 'lessThan1L',
  WaterIntake.oneToTwoL: 'oneToTwoL',
  WaterIntake.twoToThreeL: 'twoToThreeL',
  WaterIntake.moreThan3L: 'moreThan3L',
};
