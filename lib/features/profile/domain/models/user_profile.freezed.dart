// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) {
  return _UserProfile.fromJson(json);
}

/// @nodoc
mixin _$UserProfile {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  Gender get gender => throw _privateConstructorUsedError;
  DateTime get birthDate => throw _privateConstructorUsedError;
  int get height => throw _privateConstructorUsedError; // cm
  double get currentWeight => throw _privateConstructorUsedError; // kg
  double get targetWeight => throw _privateConstructorUsedError; // kg
  /// Desired weight change per week in kg.
  /// Negative for weight loss, positive for gain.
  /// e.g., -0.5 for losing 0.5kg/week.
  double get weeklyGoal => throw _privateConstructorUsedError;
  ActivityLevel get activityLevel => throw _privateConstructorUsedError;
  MainGoal get mainGoal => throw _privateConstructorUsedError;
  DietaryPreference get dietaryPreference => throw _privateConstructorUsedError;
  SleepDuration get sleepDuration => throw _privateConstructorUsedError;
  WaterIntake get waterIntake => throw _privateConstructorUsedError;
  List<String> get badHabits => throw _privateConstructorUsedError;
  List<String> get motivations =>
      throw _privateConstructorUsedError; // Calculated values
  int get calculatedCalories => throw _privateConstructorUsedError;
  int get proteinGrams => throw _privateConstructorUsedError;
  int get carbsGrams => throw _privateConstructorUsedError;
  int get fatGrams =>
      throw _privateConstructorUsedError; // Time estimate fields
  int? get weeksToGoal => throw _privateConstructorUsedError;
  DateTime? get estimatedGoalDate =>
      throw _privateConstructorUsedError; // Favoritos (para sync futura)
  List<String> get favoriteFoodKeys =>
      throw _privateConstructorUsedError; // Monetization / gating (bootstrapped growth)
  int get freeMealsRemaining => throw _privateConstructorUsedError;
  DateTime? get challengeStartedAt => throw _privateConstructorUsedError;
  DateTime? get challengeLastMealAt => throw _privateConstructorUsedError;
  int get challengeMealsRemaining => throw _privateConstructorUsedError;
  int get paywallDismissCount =>
      throw _privateConstructorUsedError; // Onboarding commitment
  bool get committedToLogDaily => throw _privateConstructorUsedError;
  bool get isOnboardingCompleted => throw _privateConstructorUsedError;
  FoodLoggingMethod get foodLoggingMethod => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserProfileCopyWith<UserProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileCopyWith<$Res> {
  factory $UserProfileCopyWith(
          UserProfile value, $Res Function(UserProfile) then) =
      _$UserProfileCopyWithImpl<$Res, UserProfile>;
  @useResult
  $Res call(
      {String id,
      String name,
      Gender gender,
      DateTime birthDate,
      int height,
      double currentWeight,
      double targetWeight,
      double weeklyGoal,
      ActivityLevel activityLevel,
      MainGoal mainGoal,
      DietaryPreference dietaryPreference,
      SleepDuration sleepDuration,
      WaterIntake waterIntake,
      List<String> badHabits,
      List<String> motivations,
      int calculatedCalories,
      int proteinGrams,
      int carbsGrams,
      int fatGrams,
      int? weeksToGoal,
      DateTime? estimatedGoalDate,
      List<String> favoriteFoodKeys,
      int freeMealsRemaining,
      DateTime? challengeStartedAt,
      DateTime? challengeLastMealAt,
      int challengeMealsRemaining,
      int paywallDismissCount,
      bool committedToLogDaily,
      bool isOnboardingCompleted,
      FoodLoggingMethod foodLoggingMethod});
}

/// @nodoc
class _$UserProfileCopyWithImpl<$Res, $Val extends UserProfile>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? gender = null,
    Object? birthDate = null,
    Object? height = null,
    Object? currentWeight = null,
    Object? targetWeight = null,
    Object? weeklyGoal = null,
    Object? activityLevel = null,
    Object? mainGoal = null,
    Object? dietaryPreference = null,
    Object? sleepDuration = null,
    Object? waterIntake = null,
    Object? badHabits = null,
    Object? motivations = null,
    Object? calculatedCalories = null,
    Object? proteinGrams = null,
    Object? carbsGrams = null,
    Object? fatGrams = null,
    Object? weeksToGoal = freezed,
    Object? estimatedGoalDate = freezed,
    Object? favoriteFoodKeys = null,
    Object? freeMealsRemaining = null,
    Object? challengeStartedAt = freezed,
    Object? challengeLastMealAt = freezed,
    Object? challengeMealsRemaining = null,
    Object? paywallDismissCount = null,
    Object? committedToLogDaily = null,
    Object? isOnboardingCompleted = null,
    Object? foodLoggingMethod = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as Gender,
      birthDate: null == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      currentWeight: null == currentWeight
          ? _value.currentWeight
          : currentWeight // ignore: cast_nullable_to_non_nullable
              as double,
      targetWeight: null == targetWeight
          ? _value.targetWeight
          : targetWeight // ignore: cast_nullable_to_non_nullable
              as double,
      weeklyGoal: null == weeklyGoal
          ? _value.weeklyGoal
          : weeklyGoal // ignore: cast_nullable_to_non_nullable
              as double,
      activityLevel: null == activityLevel
          ? _value.activityLevel
          : activityLevel // ignore: cast_nullable_to_non_nullable
              as ActivityLevel,
      mainGoal: null == mainGoal
          ? _value.mainGoal
          : mainGoal // ignore: cast_nullable_to_non_nullable
              as MainGoal,
      dietaryPreference: null == dietaryPreference
          ? _value.dietaryPreference
          : dietaryPreference // ignore: cast_nullable_to_non_nullable
              as DietaryPreference,
      sleepDuration: null == sleepDuration
          ? _value.sleepDuration
          : sleepDuration // ignore: cast_nullable_to_non_nullable
              as SleepDuration,
      waterIntake: null == waterIntake
          ? _value.waterIntake
          : waterIntake // ignore: cast_nullable_to_non_nullable
              as WaterIntake,
      badHabits: null == badHabits
          ? _value.badHabits
          : badHabits // ignore: cast_nullable_to_non_nullable
              as List<String>,
      motivations: null == motivations
          ? _value.motivations
          : motivations // ignore: cast_nullable_to_non_nullable
              as List<String>,
      calculatedCalories: null == calculatedCalories
          ? _value.calculatedCalories
          : calculatedCalories // ignore: cast_nullable_to_non_nullable
              as int,
      proteinGrams: null == proteinGrams
          ? _value.proteinGrams
          : proteinGrams // ignore: cast_nullable_to_non_nullable
              as int,
      carbsGrams: null == carbsGrams
          ? _value.carbsGrams
          : carbsGrams // ignore: cast_nullable_to_non_nullable
              as int,
      fatGrams: null == fatGrams
          ? _value.fatGrams
          : fatGrams // ignore: cast_nullable_to_non_nullable
              as int,
      weeksToGoal: freezed == weeksToGoal
          ? _value.weeksToGoal
          : weeksToGoal // ignore: cast_nullable_to_non_nullable
              as int?,
      estimatedGoalDate: freezed == estimatedGoalDate
          ? _value.estimatedGoalDate
          : estimatedGoalDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      favoriteFoodKeys: null == favoriteFoodKeys
          ? _value.favoriteFoodKeys
          : favoriteFoodKeys // ignore: cast_nullable_to_non_nullable
              as List<String>,
      freeMealsRemaining: null == freeMealsRemaining
          ? _value.freeMealsRemaining
          : freeMealsRemaining // ignore: cast_nullable_to_non_nullable
              as int,
      challengeStartedAt: freezed == challengeStartedAt
          ? _value.challengeStartedAt
          : challengeStartedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      challengeLastMealAt: freezed == challengeLastMealAt
          ? _value.challengeLastMealAt
          : challengeLastMealAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      challengeMealsRemaining: null == challengeMealsRemaining
          ? _value.challengeMealsRemaining
          : challengeMealsRemaining // ignore: cast_nullable_to_non_nullable
              as int,
      paywallDismissCount: null == paywallDismissCount
          ? _value.paywallDismissCount
          : paywallDismissCount // ignore: cast_nullable_to_non_nullable
              as int,
      committedToLogDaily: null == committedToLogDaily
          ? _value.committedToLogDaily
          : committedToLogDaily // ignore: cast_nullable_to_non_nullable
              as bool,
      isOnboardingCompleted: null == isOnboardingCompleted
          ? _value.isOnboardingCompleted
          : isOnboardingCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      foodLoggingMethod: null == foodLoggingMethod
          ? _value.foodLoggingMethod
          : foodLoggingMethod // ignore: cast_nullable_to_non_nullable
              as FoodLoggingMethod,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserProfileImplCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$$UserProfileImplCopyWith(
          _$UserProfileImpl value, $Res Function(_$UserProfileImpl) then) =
      __$$UserProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      Gender gender,
      DateTime birthDate,
      int height,
      double currentWeight,
      double targetWeight,
      double weeklyGoal,
      ActivityLevel activityLevel,
      MainGoal mainGoal,
      DietaryPreference dietaryPreference,
      SleepDuration sleepDuration,
      WaterIntake waterIntake,
      List<String> badHabits,
      List<String> motivations,
      int calculatedCalories,
      int proteinGrams,
      int carbsGrams,
      int fatGrams,
      int? weeksToGoal,
      DateTime? estimatedGoalDate,
      List<String> favoriteFoodKeys,
      int freeMealsRemaining,
      DateTime? challengeStartedAt,
      DateTime? challengeLastMealAt,
      int challengeMealsRemaining,
      int paywallDismissCount,
      bool committedToLogDaily,
      bool isOnboardingCompleted,
      FoodLoggingMethod foodLoggingMethod});
}

/// @nodoc
class __$$UserProfileImplCopyWithImpl<$Res>
    extends _$UserProfileCopyWithImpl<$Res, _$UserProfileImpl>
    implements _$$UserProfileImplCopyWith<$Res> {
  __$$UserProfileImplCopyWithImpl(
      _$UserProfileImpl _value, $Res Function(_$UserProfileImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? gender = null,
    Object? birthDate = null,
    Object? height = null,
    Object? currentWeight = null,
    Object? targetWeight = null,
    Object? weeklyGoal = null,
    Object? activityLevel = null,
    Object? mainGoal = null,
    Object? dietaryPreference = null,
    Object? sleepDuration = null,
    Object? waterIntake = null,
    Object? badHabits = null,
    Object? motivations = null,
    Object? calculatedCalories = null,
    Object? proteinGrams = null,
    Object? carbsGrams = null,
    Object? fatGrams = null,
    Object? weeksToGoal = freezed,
    Object? estimatedGoalDate = freezed,
    Object? favoriteFoodKeys = null,
    Object? freeMealsRemaining = null,
    Object? challengeStartedAt = freezed,
    Object? challengeLastMealAt = freezed,
    Object? challengeMealsRemaining = null,
    Object? paywallDismissCount = null,
    Object? committedToLogDaily = null,
    Object? isOnboardingCompleted = null,
    Object? foodLoggingMethod = null,
  }) {
    return _then(_$UserProfileImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as Gender,
      birthDate: null == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      height: null == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as int,
      currentWeight: null == currentWeight
          ? _value.currentWeight
          : currentWeight // ignore: cast_nullable_to_non_nullable
              as double,
      targetWeight: null == targetWeight
          ? _value.targetWeight
          : targetWeight // ignore: cast_nullable_to_non_nullable
              as double,
      weeklyGoal: null == weeklyGoal
          ? _value.weeklyGoal
          : weeklyGoal // ignore: cast_nullable_to_non_nullable
              as double,
      activityLevel: null == activityLevel
          ? _value.activityLevel
          : activityLevel // ignore: cast_nullable_to_non_nullable
              as ActivityLevel,
      mainGoal: null == mainGoal
          ? _value.mainGoal
          : mainGoal // ignore: cast_nullable_to_non_nullable
              as MainGoal,
      dietaryPreference: null == dietaryPreference
          ? _value.dietaryPreference
          : dietaryPreference // ignore: cast_nullable_to_non_nullable
              as DietaryPreference,
      sleepDuration: null == sleepDuration
          ? _value.sleepDuration
          : sleepDuration // ignore: cast_nullable_to_non_nullable
              as SleepDuration,
      waterIntake: null == waterIntake
          ? _value.waterIntake
          : waterIntake // ignore: cast_nullable_to_non_nullable
              as WaterIntake,
      badHabits: null == badHabits
          ? _value._badHabits
          : badHabits // ignore: cast_nullable_to_non_nullable
              as List<String>,
      motivations: null == motivations
          ? _value._motivations
          : motivations // ignore: cast_nullable_to_non_nullable
              as List<String>,
      calculatedCalories: null == calculatedCalories
          ? _value.calculatedCalories
          : calculatedCalories // ignore: cast_nullable_to_non_nullable
              as int,
      proteinGrams: null == proteinGrams
          ? _value.proteinGrams
          : proteinGrams // ignore: cast_nullable_to_non_nullable
              as int,
      carbsGrams: null == carbsGrams
          ? _value.carbsGrams
          : carbsGrams // ignore: cast_nullable_to_non_nullable
              as int,
      fatGrams: null == fatGrams
          ? _value.fatGrams
          : fatGrams // ignore: cast_nullable_to_non_nullable
              as int,
      weeksToGoal: freezed == weeksToGoal
          ? _value.weeksToGoal
          : weeksToGoal // ignore: cast_nullable_to_non_nullable
              as int?,
      estimatedGoalDate: freezed == estimatedGoalDate
          ? _value.estimatedGoalDate
          : estimatedGoalDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      favoriteFoodKeys: null == favoriteFoodKeys
          ? _value._favoriteFoodKeys
          : favoriteFoodKeys // ignore: cast_nullable_to_non_nullable
              as List<String>,
      freeMealsRemaining: null == freeMealsRemaining
          ? _value.freeMealsRemaining
          : freeMealsRemaining // ignore: cast_nullable_to_non_nullable
              as int,
      challengeStartedAt: freezed == challengeStartedAt
          ? _value.challengeStartedAt
          : challengeStartedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      challengeLastMealAt: freezed == challengeLastMealAt
          ? _value.challengeLastMealAt
          : challengeLastMealAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      challengeMealsRemaining: null == challengeMealsRemaining
          ? _value.challengeMealsRemaining
          : challengeMealsRemaining // ignore: cast_nullable_to_non_nullable
              as int,
      paywallDismissCount: null == paywallDismissCount
          ? _value.paywallDismissCount
          : paywallDismissCount // ignore: cast_nullable_to_non_nullable
              as int,
      committedToLogDaily: null == committedToLogDaily
          ? _value.committedToLogDaily
          : committedToLogDaily // ignore: cast_nullable_to_non_nullable
              as bool,
      isOnboardingCompleted: null == isOnboardingCompleted
          ? _value.isOnboardingCompleted
          : isOnboardingCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      foodLoggingMethod: null == foodLoggingMethod
          ? _value.foodLoggingMethod
          : foodLoggingMethod // ignore: cast_nullable_to_non_nullable
              as FoodLoggingMethod,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileImpl implements _UserProfile {
  const _$UserProfileImpl(
      {required this.id,
      this.name = '',
      required this.gender,
      required this.birthDate,
      required this.height,
      required this.currentWeight,
      required this.targetWeight,
      required this.weeklyGoal,
      required this.activityLevel,
      required this.mainGoal,
      required this.dietaryPreference,
      this.sleepDuration = SleepDuration.sevenToEight,
      this.waterIntake = WaterIntake.oneToTwoL,
      final List<String> badHabits = const <String>[],
      final List<String> motivations = const <String>[],
      required this.calculatedCalories,
      required this.proteinGrams,
      required this.carbsGrams,
      required this.fatGrams,
      this.weeksToGoal,
      this.estimatedGoalDate,
      final List<String> favoriteFoodKeys = const <String>[],
      this.freeMealsRemaining = 1,
      this.challengeStartedAt,
      this.challengeLastMealAt,
      this.challengeMealsRemaining = 0,
      this.paywallDismissCount = 0,
      this.committedToLogDaily = false,
      this.isOnboardingCompleted = false,
      this.foodLoggingMethod = FoodLoggingMethod.notNow})
      : _badHabits = badHabits,
        _motivations = motivations,
        _favoriteFoodKeys = favoriteFoodKeys;

  factory _$UserProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey()
  final String name;
  @override
  final Gender gender;
  @override
  final DateTime birthDate;
  @override
  final int height;
// cm
  @override
  final double currentWeight;
// kg
  @override
  final double targetWeight;
// kg
  /// Desired weight change per week in kg.
  /// Negative for weight loss, positive for gain.
  /// e.g., -0.5 for losing 0.5kg/week.
  @override
  final double weeklyGoal;
  @override
  final ActivityLevel activityLevel;
  @override
  final MainGoal mainGoal;
  @override
  final DietaryPreference dietaryPreference;
  @override
  @JsonKey()
  final SleepDuration sleepDuration;
  @override
  @JsonKey()
  final WaterIntake waterIntake;
  final List<String> _badHabits;
  @override
  @JsonKey()
  List<String> get badHabits {
    if (_badHabits is EqualUnmodifiableListView) return _badHabits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_badHabits);
  }

  final List<String> _motivations;
  @override
  @JsonKey()
  List<String> get motivations {
    if (_motivations is EqualUnmodifiableListView) return _motivations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_motivations);
  }

// Calculated values
  @override
  final int calculatedCalories;
  @override
  final int proteinGrams;
  @override
  final int carbsGrams;
  @override
  final int fatGrams;
// Time estimate fields
  @override
  final int? weeksToGoal;
  @override
  final DateTime? estimatedGoalDate;
// Favoritos (para sync futura)
  final List<String> _favoriteFoodKeys;
// Favoritos (para sync futura)
  @override
  @JsonKey()
  List<String> get favoriteFoodKeys {
    if (_favoriteFoodKeys is EqualUnmodifiableListView)
      return _favoriteFoodKeys;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_favoriteFoodKeys);
  }

// Monetization / gating (bootstrapped growth)
  @override
  @JsonKey()
  final int freeMealsRemaining;
  @override
  final DateTime? challengeStartedAt;
  @override
  final DateTime? challengeLastMealAt;
  @override
  @JsonKey()
  final int challengeMealsRemaining;
  @override
  @JsonKey()
  final int paywallDismissCount;
// Onboarding commitment
  @override
  @JsonKey()
  final bool committedToLogDaily;
  @override
  @JsonKey()
  final bool isOnboardingCompleted;
  @override
  @JsonKey()
  final FoodLoggingMethod foodLoggingMethod;

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, gender: $gender, birthDate: $birthDate, height: $height, currentWeight: $currentWeight, targetWeight: $targetWeight, weeklyGoal: $weeklyGoal, activityLevel: $activityLevel, mainGoal: $mainGoal, dietaryPreference: $dietaryPreference, sleepDuration: $sleepDuration, waterIntake: $waterIntake, badHabits: $badHabits, motivations: $motivations, calculatedCalories: $calculatedCalories, proteinGrams: $proteinGrams, carbsGrams: $carbsGrams, fatGrams: $fatGrams, weeksToGoal: $weeksToGoal, estimatedGoalDate: $estimatedGoalDate, favoriteFoodKeys: $favoriteFoodKeys, freeMealsRemaining: $freeMealsRemaining, challengeStartedAt: $challengeStartedAt, challengeLastMealAt: $challengeLastMealAt, challengeMealsRemaining: $challengeMealsRemaining, paywallDismissCount: $paywallDismissCount, committedToLogDaily: $committedToLogDaily, isOnboardingCompleted: $isOnboardingCompleted, foodLoggingMethod: $foodLoggingMethod)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.birthDate, birthDate) ||
                other.birthDate == birthDate) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.currentWeight, currentWeight) ||
                other.currentWeight == currentWeight) &&
            (identical(other.targetWeight, targetWeight) ||
                other.targetWeight == targetWeight) &&
            (identical(other.weeklyGoal, weeklyGoal) ||
                other.weeklyGoal == weeklyGoal) &&
            (identical(other.activityLevel, activityLevel) ||
                other.activityLevel == activityLevel) &&
            (identical(other.mainGoal, mainGoal) ||
                other.mainGoal == mainGoal) &&
            (identical(other.dietaryPreference, dietaryPreference) ||
                other.dietaryPreference == dietaryPreference) &&
            (identical(other.sleepDuration, sleepDuration) ||
                other.sleepDuration == sleepDuration) &&
            (identical(other.waterIntake, waterIntake) ||
                other.waterIntake == waterIntake) &&
            const DeepCollectionEquality()
                .equals(other._badHabits, _badHabits) &&
            const DeepCollectionEquality()
                .equals(other._motivations, _motivations) &&
            (identical(other.calculatedCalories, calculatedCalories) ||
                other.calculatedCalories == calculatedCalories) &&
            (identical(other.proteinGrams, proteinGrams) ||
                other.proteinGrams == proteinGrams) &&
            (identical(other.carbsGrams, carbsGrams) ||
                other.carbsGrams == carbsGrams) &&
            (identical(other.fatGrams, fatGrams) ||
                other.fatGrams == fatGrams) &&
            (identical(other.weeksToGoal, weeksToGoal) ||
                other.weeksToGoal == weeksToGoal) &&
            (identical(other.estimatedGoalDate, estimatedGoalDate) ||
                other.estimatedGoalDate == estimatedGoalDate) &&
            const DeepCollectionEquality()
                .equals(other._favoriteFoodKeys, _favoriteFoodKeys) &&
            (identical(other.freeMealsRemaining, freeMealsRemaining) ||
                other.freeMealsRemaining == freeMealsRemaining) &&
            (identical(other.challengeStartedAt, challengeStartedAt) ||
                other.challengeStartedAt == challengeStartedAt) &&
            (identical(other.challengeLastMealAt, challengeLastMealAt) ||
                other.challengeLastMealAt == challengeLastMealAt) &&
            (identical(
                    other.challengeMealsRemaining, challengeMealsRemaining) ||
                other.challengeMealsRemaining == challengeMealsRemaining) &&
            (identical(other.paywallDismissCount, paywallDismissCount) ||
                other.paywallDismissCount == paywallDismissCount) &&
            (identical(other.committedToLogDaily, committedToLogDaily) ||
                other.committedToLogDaily == committedToLogDaily) &&
            (identical(other.isOnboardingCompleted, isOnboardingCompleted) ||
                other.isOnboardingCompleted == isOnboardingCompleted) &&
            (identical(other.foodLoggingMethod, foodLoggingMethod) ||
                other.foodLoggingMethod == foodLoggingMethod));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        gender,
        birthDate,
        height,
        currentWeight,
        targetWeight,
        weeklyGoal,
        activityLevel,
        mainGoal,
        dietaryPreference,
        sleepDuration,
        waterIntake,
        const DeepCollectionEquality().hash(_badHabits),
        const DeepCollectionEquality().hash(_motivations),
        calculatedCalories,
        proteinGrams,
        carbsGrams,
        fatGrams,
        weeksToGoal,
        estimatedGoalDate,
        const DeepCollectionEquality().hash(_favoriteFoodKeys),
        freeMealsRemaining,
        challengeStartedAt,
        challengeLastMealAt,
        challengeMealsRemaining,
        paywallDismissCount,
        committedToLogDaily,
        isOnboardingCompleted,
        foodLoggingMethod
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      __$$UserProfileImplCopyWithImpl<_$UserProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileImplToJson(
      this,
    );
  }
}

abstract class _UserProfile implements UserProfile {
  const factory _UserProfile(
      {required final String id,
      final String name,
      required final Gender gender,
      required final DateTime birthDate,
      required final int height,
      required final double currentWeight,
      required final double targetWeight,
      required final double weeklyGoal,
      required final ActivityLevel activityLevel,
      required final MainGoal mainGoal,
      required final DietaryPreference dietaryPreference,
      final SleepDuration sleepDuration,
      final WaterIntake waterIntake,
      final List<String> badHabits,
      final List<String> motivations,
      required final int calculatedCalories,
      required final int proteinGrams,
      required final int carbsGrams,
      required final int fatGrams,
      final int? weeksToGoal,
      final DateTime? estimatedGoalDate,
      final List<String> favoriteFoodKeys,
      final int freeMealsRemaining,
      final DateTime? challengeStartedAt,
      final DateTime? challengeLastMealAt,
      final int challengeMealsRemaining,
      final int paywallDismissCount,
      final bool committedToLogDaily,
      final bool isOnboardingCompleted,
      final FoodLoggingMethod foodLoggingMethod}) = _$UserProfileImpl;

  factory _UserProfile.fromJson(Map<String, dynamic> json) =
      _$UserProfileImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  Gender get gender;
  @override
  DateTime get birthDate;
  @override
  int get height;
  @override // cm
  double get currentWeight;
  @override // kg
  double get targetWeight;
  @override // kg
  /// Desired weight change per week in kg.
  /// Negative for weight loss, positive for gain.
  /// e.g., -0.5 for losing 0.5kg/week.
  double get weeklyGoal;
  @override
  ActivityLevel get activityLevel;
  @override
  MainGoal get mainGoal;
  @override
  DietaryPreference get dietaryPreference;
  @override
  SleepDuration get sleepDuration;
  @override
  WaterIntake get waterIntake;
  @override
  List<String> get badHabits;
  @override
  List<String> get motivations;
  @override // Calculated values
  int get calculatedCalories;
  @override
  int get proteinGrams;
  @override
  int get carbsGrams;
  @override
  int get fatGrams;
  @override // Time estimate fields
  int? get weeksToGoal;
  @override
  DateTime? get estimatedGoalDate;
  @override // Favoritos (para sync futura)
  List<String> get favoriteFoodKeys;
  @override // Monetization / gating (bootstrapped growth)
  int get freeMealsRemaining;
  @override
  DateTime? get challengeStartedAt;
  @override
  DateTime? get challengeLastMealAt;
  @override
  int get challengeMealsRemaining;
  @override
  int get paywallDismissCount;
  @override // Onboarding commitment
  bool get committedToLogDaily;
  @override
  bool get isOnboardingCompleted;
  @override
  FoodLoggingMethod get foodLoggingMethod;
  @override
  @JsonKey(ignore: true)
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
