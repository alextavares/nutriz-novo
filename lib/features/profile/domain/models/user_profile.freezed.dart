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
  DietaryPreference get dietaryPreference =>
      throw _privateConstructorUsedError; // Calculated values
  int get calculatedCalories => throw _privateConstructorUsedError;
  int get proteinGrams => throw _privateConstructorUsedError;
  int get carbsGrams => throw _privateConstructorUsedError;
  int get fatGrams =>
      throw _privateConstructorUsedError; // Time estimate fields
  int? get weeksToGoal => throw _privateConstructorUsedError;
  DateTime? get estimatedGoalDate => throw _privateConstructorUsedError;
  bool get isOnboardingCompleted => throw _privateConstructorUsedError;

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
      Gender gender,
      DateTime birthDate,
      int height,
      double currentWeight,
      double targetWeight,
      double weeklyGoal,
      ActivityLevel activityLevel,
      MainGoal mainGoal,
      DietaryPreference dietaryPreference,
      int calculatedCalories,
      int proteinGrams,
      int carbsGrams,
      int fatGrams,
      int? weeksToGoal,
      DateTime? estimatedGoalDate,
      bool isOnboardingCompleted});
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
    Object? gender = null,
    Object? birthDate = null,
    Object? height = null,
    Object? currentWeight = null,
    Object? targetWeight = null,
    Object? weeklyGoal = null,
    Object? activityLevel = null,
    Object? mainGoal = null,
    Object? dietaryPreference = null,
    Object? calculatedCalories = null,
    Object? proteinGrams = null,
    Object? carbsGrams = null,
    Object? fatGrams = null,
    Object? weeksToGoal = freezed,
    Object? estimatedGoalDate = freezed,
    Object? isOnboardingCompleted = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
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
      isOnboardingCompleted: null == isOnboardingCompleted
          ? _value.isOnboardingCompleted
          : isOnboardingCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
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
      Gender gender,
      DateTime birthDate,
      int height,
      double currentWeight,
      double targetWeight,
      double weeklyGoal,
      ActivityLevel activityLevel,
      MainGoal mainGoal,
      DietaryPreference dietaryPreference,
      int calculatedCalories,
      int proteinGrams,
      int carbsGrams,
      int fatGrams,
      int? weeksToGoal,
      DateTime? estimatedGoalDate,
      bool isOnboardingCompleted});
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
    Object? gender = null,
    Object? birthDate = null,
    Object? height = null,
    Object? currentWeight = null,
    Object? targetWeight = null,
    Object? weeklyGoal = null,
    Object? activityLevel = null,
    Object? mainGoal = null,
    Object? dietaryPreference = null,
    Object? calculatedCalories = null,
    Object? proteinGrams = null,
    Object? carbsGrams = null,
    Object? fatGrams = null,
    Object? weeksToGoal = freezed,
    Object? estimatedGoalDate = freezed,
    Object? isOnboardingCompleted = null,
  }) {
    return _then(_$UserProfileImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
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
      isOnboardingCompleted: null == isOnboardingCompleted
          ? _value.isOnboardingCompleted
          : isOnboardingCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileImpl implements _UserProfile {
  const _$UserProfileImpl(
      {required this.id,
      required this.gender,
      required this.birthDate,
      required this.height,
      required this.currentWeight,
      required this.targetWeight,
      required this.weeklyGoal,
      required this.activityLevel,
      required this.mainGoal,
      required this.dietaryPreference,
      required this.calculatedCalories,
      required this.proteinGrams,
      required this.carbsGrams,
      required this.fatGrams,
      this.weeksToGoal,
      this.estimatedGoalDate,
      this.isOnboardingCompleted = false});

  factory _$UserProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileImplFromJson(json);

  @override
  final String id;
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
  @override
  @JsonKey()
  final bool isOnboardingCompleted;

  @override
  String toString() {
    return 'UserProfile(id: $id, gender: $gender, birthDate: $birthDate, height: $height, currentWeight: $currentWeight, targetWeight: $targetWeight, weeklyGoal: $weeklyGoal, activityLevel: $activityLevel, mainGoal: $mainGoal, dietaryPreference: $dietaryPreference, calculatedCalories: $calculatedCalories, proteinGrams: $proteinGrams, carbsGrams: $carbsGrams, fatGrams: $fatGrams, weeksToGoal: $weeksToGoal, estimatedGoalDate: $estimatedGoalDate, isOnboardingCompleted: $isOnboardingCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
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
            (identical(other.isOnboardingCompleted, isOnboardingCompleted) ||
                other.isOnboardingCompleted == isOnboardingCompleted));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      gender,
      birthDate,
      height,
      currentWeight,
      targetWeight,
      weeklyGoal,
      activityLevel,
      mainGoal,
      dietaryPreference,
      calculatedCalories,
      proteinGrams,
      carbsGrams,
      fatGrams,
      weeksToGoal,
      estimatedGoalDate,
      isOnboardingCompleted);

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
      required final Gender gender,
      required final DateTime birthDate,
      required final int height,
      required final double currentWeight,
      required final double targetWeight,
      required final double weeklyGoal,
      required final ActivityLevel activityLevel,
      required final MainGoal mainGoal,
      required final DietaryPreference dietaryPreference,
      required final int calculatedCalories,
      required final int proteinGrams,
      required final int carbsGrams,
      required final int fatGrams,
      final int? weeksToGoal,
      final DateTime? estimatedGoalDate,
      final bool isOnboardingCompleted}) = _$UserProfileImpl;

  factory _UserProfile.fromJson(Map<String, dynamic> json) =
      _$UserProfileImpl.fromJson;

  @override
  String get id;
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
  @override
  bool get isOnboardingCompleted;
  @override
  @JsonKey(ignore: true)
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
