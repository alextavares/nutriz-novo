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

/// @nodoc
mixin _$UserProfile {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  Gender get gender => throw _privateConstructorUsedError;
  DateTime get birthDate => throw _privateConstructorUsedError;
  Height get height => throw _privateConstructorUsedError;
  Weight get startWeight => throw _privateConstructorUsedError;
  Weight get currentWeight => throw _privateConstructorUsedError;
  UserGoal get goal => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;

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
      Height height,
      Weight startWeight,
      Weight currentWeight,
      UserGoal goal,
      String? photoUrl});

  $HeightCopyWith<$Res> get height;
  $WeightCopyWith<$Res> get startWeight;
  $WeightCopyWith<$Res> get currentWeight;
  $UserGoalCopyWith<$Res> get goal;
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
    Object? startWeight = null,
    Object? currentWeight = null,
    Object? goal = null,
    Object? photoUrl = freezed,
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
              as Height,
      startWeight: null == startWeight
          ? _value.startWeight
          : startWeight // ignore: cast_nullable_to_non_nullable
              as Weight,
      currentWeight: null == currentWeight
          ? _value.currentWeight
          : currentWeight // ignore: cast_nullable_to_non_nullable
              as Weight,
      goal: null == goal
          ? _value.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as UserGoal,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $HeightCopyWith<$Res> get height {
    return $HeightCopyWith<$Res>(_value.height, (value) {
      return _then(_value.copyWith(height: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $WeightCopyWith<$Res> get startWeight {
    return $WeightCopyWith<$Res>(_value.startWeight, (value) {
      return _then(_value.copyWith(startWeight: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $WeightCopyWith<$Res> get currentWeight {
    return $WeightCopyWith<$Res>(_value.currentWeight, (value) {
      return _then(_value.copyWith(currentWeight: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $UserGoalCopyWith<$Res> get goal {
    return $UserGoalCopyWith<$Res>(_value.goal, (value) {
      return _then(_value.copyWith(goal: value) as $Val);
    });
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
      Height height,
      Weight startWeight,
      Weight currentWeight,
      UserGoal goal,
      String? photoUrl});

  @override
  $HeightCopyWith<$Res> get height;
  @override
  $WeightCopyWith<$Res> get startWeight;
  @override
  $WeightCopyWith<$Res> get currentWeight;
  @override
  $UserGoalCopyWith<$Res> get goal;
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
    Object? startWeight = null,
    Object? currentWeight = null,
    Object? goal = null,
    Object? photoUrl = freezed,
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
              as Height,
      startWeight: null == startWeight
          ? _value.startWeight
          : startWeight // ignore: cast_nullable_to_non_nullable
              as Weight,
      currentWeight: null == currentWeight
          ? _value.currentWeight
          : currentWeight // ignore: cast_nullable_to_non_nullable
              as Weight,
      goal: null == goal
          ? _value.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as UserGoal,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$UserProfileImpl extends _UserProfile {
  const _$UserProfileImpl(
      {required this.id,
      required this.name,
      required this.gender,
      required this.birthDate,
      required this.height,
      required this.startWeight,
      required this.currentWeight,
      required this.goal,
      this.photoUrl})
      : super._();

  @override
  final String id;
  @override
  final String name;
  @override
  final Gender gender;
  @override
  final DateTime birthDate;
  @override
  final Height height;
  @override
  final Weight startWeight;
  @override
  final Weight currentWeight;
  @override
  final UserGoal goal;
  @override
  final String? photoUrl;

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, gender: $gender, birthDate: $birthDate, height: $height, startWeight: $startWeight, currentWeight: $currentWeight, goal: $goal, photoUrl: $photoUrl)';
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
            (identical(other.startWeight, startWeight) ||
                other.startWeight == startWeight) &&
            (identical(other.currentWeight, currentWeight) ||
                other.currentWeight == currentWeight) &&
            (identical(other.goal, goal) || other.goal == goal) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, gender, birthDate,
      height, startWeight, currentWeight, goal, photoUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      __$$UserProfileImplCopyWithImpl<_$UserProfileImpl>(this, _$identity);
}

abstract class _UserProfile extends UserProfile {
  const factory _UserProfile(
      {required final String id,
      required final String name,
      required final Gender gender,
      required final DateTime birthDate,
      required final Height height,
      required final Weight startWeight,
      required final Weight currentWeight,
      required final UserGoal goal,
      final String? photoUrl}) = _$UserProfileImpl;
  const _UserProfile._() : super._();

  @override
  String get id;
  @override
  String get name;
  @override
  Gender get gender;
  @override
  DateTime get birthDate;
  @override
  Height get height;
  @override
  Weight get startWeight;
  @override
  Weight get currentWeight;
  @override
  UserGoal get goal;
  @override
  String? get photoUrl;
  @override
  @JsonKey(ignore: true)
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
