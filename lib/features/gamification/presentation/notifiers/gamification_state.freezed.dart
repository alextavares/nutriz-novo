// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gamification_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GamificationState {
  UserLevel get userLevel => throw _privateConstructorUsedError;
  Streak get streak => throw _privateConstructorUsedError;
  UserPoints get userPoints => throw _privateConstructorUsedError;
  List<Achievement> get achievements => throw _privateConstructorUsedError;
  AsyncValue<void> get isLoading => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $GamificationStateCopyWith<GamificationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GamificationStateCopyWith<$Res> {
  factory $GamificationStateCopyWith(
          GamificationState value, $Res Function(GamificationState) then) =
      _$GamificationStateCopyWithImpl<$Res, GamificationState>;
  @useResult
  $Res call(
      {UserLevel userLevel,
      Streak streak,
      UserPoints userPoints,
      List<Achievement> achievements,
      AsyncValue<void> isLoading});

  $UserLevelCopyWith<$Res> get userLevel;
  $StreakCopyWith<$Res> get streak;
  $UserPointsCopyWith<$Res> get userPoints;
}

/// @nodoc
class _$GamificationStateCopyWithImpl<$Res, $Val extends GamificationState>
    implements $GamificationStateCopyWith<$Res> {
  _$GamificationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userLevel = null,
    Object? streak = null,
    Object? userPoints = null,
    Object? achievements = null,
    Object? isLoading = null,
  }) {
    return _then(_value.copyWith(
      userLevel: null == userLevel
          ? _value.userLevel
          : userLevel // ignore: cast_nullable_to_non_nullable
              as UserLevel,
      streak: null == streak
          ? _value.streak
          : streak // ignore: cast_nullable_to_non_nullable
              as Streak,
      userPoints: null == userPoints
          ? _value.userPoints
          : userPoints // ignore: cast_nullable_to_non_nullable
              as UserPoints,
      achievements: null == achievements
          ? _value.achievements
          : achievements // ignore: cast_nullable_to_non_nullable
              as List<Achievement>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as AsyncValue<void>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserLevelCopyWith<$Res> get userLevel {
    return $UserLevelCopyWith<$Res>(_value.userLevel, (value) {
      return _then(_value.copyWith(userLevel: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $StreakCopyWith<$Res> get streak {
    return $StreakCopyWith<$Res>(_value.streak, (value) {
      return _then(_value.copyWith(streak: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $UserPointsCopyWith<$Res> get userPoints {
    return $UserPointsCopyWith<$Res>(_value.userPoints, (value) {
      return _then(_value.copyWith(userPoints: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GamificationStateImplCopyWith<$Res>
    implements $GamificationStateCopyWith<$Res> {
  factory _$$GamificationStateImplCopyWith(_$GamificationStateImpl value,
          $Res Function(_$GamificationStateImpl) then) =
      __$$GamificationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {UserLevel userLevel,
      Streak streak,
      UserPoints userPoints,
      List<Achievement> achievements,
      AsyncValue<void> isLoading});

  @override
  $UserLevelCopyWith<$Res> get userLevel;
  @override
  $StreakCopyWith<$Res> get streak;
  @override
  $UserPointsCopyWith<$Res> get userPoints;
}

/// @nodoc
class __$$GamificationStateImplCopyWithImpl<$Res>
    extends _$GamificationStateCopyWithImpl<$Res, _$GamificationStateImpl>
    implements _$$GamificationStateImplCopyWith<$Res> {
  __$$GamificationStateImplCopyWithImpl(_$GamificationStateImpl _value,
      $Res Function(_$GamificationStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userLevel = null,
    Object? streak = null,
    Object? userPoints = null,
    Object? achievements = null,
    Object? isLoading = null,
  }) {
    return _then(_$GamificationStateImpl(
      userLevel: null == userLevel
          ? _value.userLevel
          : userLevel // ignore: cast_nullable_to_non_nullable
              as UserLevel,
      streak: null == streak
          ? _value.streak
          : streak // ignore: cast_nullable_to_non_nullable
              as Streak,
      userPoints: null == userPoints
          ? _value.userPoints
          : userPoints // ignore: cast_nullable_to_non_nullable
              as UserPoints,
      achievements: null == achievements
          ? _value._achievements
          : achievements // ignore: cast_nullable_to_non_nullable
              as List<Achievement>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as AsyncValue<void>,
    ));
  }
}

/// @nodoc

class _$GamificationStateImpl implements _GamificationState {
  const _$GamificationStateImpl(
      {required this.userLevel,
      required this.streak,
      required this.userPoints,
      final List<Achievement> achievements = const [],
      this.isLoading = const AsyncValue.loading()})
      : _achievements = achievements;

  @override
  final UserLevel userLevel;
  @override
  final Streak streak;
  @override
  final UserPoints userPoints;
  final List<Achievement> _achievements;
  @override
  @JsonKey()
  List<Achievement> get achievements {
    if (_achievements is EqualUnmodifiableListView) return _achievements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_achievements);
  }

  @override
  @JsonKey()
  final AsyncValue<void> isLoading;

  @override
  String toString() {
    return 'GamificationState(userLevel: $userLevel, streak: $streak, userPoints: $userPoints, achievements: $achievements, isLoading: $isLoading)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GamificationStateImpl &&
            (identical(other.userLevel, userLevel) ||
                other.userLevel == userLevel) &&
            (identical(other.streak, streak) || other.streak == streak) &&
            (identical(other.userPoints, userPoints) ||
                other.userPoints == userPoints) &&
            const DeepCollectionEquality()
                .equals(other._achievements, _achievements) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading));
  }

  @override
  int get hashCode => Object.hash(runtimeType, userLevel, streak, userPoints,
      const DeepCollectionEquality().hash(_achievements), isLoading);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$GamificationStateImplCopyWith<_$GamificationStateImpl> get copyWith =>
      __$$GamificationStateImplCopyWithImpl<_$GamificationStateImpl>(
          this, _$identity);
}

abstract class _GamificationState implements GamificationState {
  const factory _GamificationState(
      {required final UserLevel userLevel,
      required final Streak streak,
      required final UserPoints userPoints,
      final List<Achievement> achievements,
      final AsyncValue<void> isLoading}) = _$GamificationStateImpl;

  @override
  UserLevel get userLevel;
  @override
  Streak get streak;
  @override
  UserPoints get userPoints;
  @override
  List<Achievement> get achievements;
  @override
  AsyncValue<void> get isLoading;
  @override
  @JsonKey(ignore: true)
  _$$GamificationStateImplCopyWith<_$GamificationStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
