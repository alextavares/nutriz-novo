// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      id: json['id'] as String,
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
      calculatedCalories: (json['calculatedCalories'] as num).toInt(),
      proteinGrams: (json['proteinGrams'] as num).toInt(),
      carbsGrams: (json['carbsGrams'] as num).toInt(),
      fatGrams: (json['fatGrams'] as num).toInt(),
      weeksToGoal: (json['weeksToGoal'] as num?)?.toInt(),
      estimatedGoalDate: json['estimatedGoalDate'] == null
          ? null
          : DateTime.parse(json['estimatedGoalDate'] as String),
      isOnboardingCompleted: json['isOnboardingCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
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
      'calculatedCalories': instance.calculatedCalories,
      'proteinGrams': instance.proteinGrams,
      'carbsGrams': instance.carbsGrams,
      'fatGrams': instance.fatGrams,
      'weeksToGoal': instance.weeksToGoal,
      'estimatedGoalDate': instance.estimatedGoalDate?.toIso8601String(),
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
