// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_level.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserLevel _$UserLevelFromJson(Map<String, dynamic> json) {
  return _UserLevel.fromJson(json);
}

/// @nodoc
mixin _$UserLevel {
  int get currentLevel => throw _privateConstructorUsedError;
  int get currentXp => throw _privateConstructorUsedError;
  int get xpToNextLevel => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserLevelCopyWith<UserLevel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserLevelCopyWith<$Res> {
  factory $UserLevelCopyWith(UserLevel value, $Res Function(UserLevel) then) =
      _$UserLevelCopyWithImpl<$Res, UserLevel>;
  @useResult
  $Res call({int currentLevel, int currentXp, int xpToNextLevel, String title});
}

/// @nodoc
class _$UserLevelCopyWithImpl<$Res, $Val extends UserLevel>
    implements $UserLevelCopyWith<$Res> {
  _$UserLevelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentLevel = null,
    Object? currentXp = null,
    Object? xpToNextLevel = null,
    Object? title = null,
  }) {
    return _then(_value.copyWith(
      currentLevel: null == currentLevel
          ? _value.currentLevel
          : currentLevel // ignore: cast_nullable_to_non_nullable
              as int,
      currentXp: null == currentXp
          ? _value.currentXp
          : currentXp // ignore: cast_nullable_to_non_nullable
              as int,
      xpToNextLevel: null == xpToNextLevel
          ? _value.xpToNextLevel
          : xpToNextLevel // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserLevelImplCopyWith<$Res>
    implements $UserLevelCopyWith<$Res> {
  factory _$$UserLevelImplCopyWith(
          _$UserLevelImpl value, $Res Function(_$UserLevelImpl) then) =
      __$$UserLevelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int currentLevel, int currentXp, int xpToNextLevel, String title});
}

/// @nodoc
class __$$UserLevelImplCopyWithImpl<$Res>
    extends _$UserLevelCopyWithImpl<$Res, _$UserLevelImpl>
    implements _$$UserLevelImplCopyWith<$Res> {
  __$$UserLevelImplCopyWithImpl(
      _$UserLevelImpl _value, $Res Function(_$UserLevelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentLevel = null,
    Object? currentXp = null,
    Object? xpToNextLevel = null,
    Object? title = null,
  }) {
    return _then(_$UserLevelImpl(
      currentLevel: null == currentLevel
          ? _value.currentLevel
          : currentLevel // ignore: cast_nullable_to_non_nullable
              as int,
      currentXp: null == currentXp
          ? _value.currentXp
          : currentXp // ignore: cast_nullable_to_non_nullable
              as int,
      xpToNextLevel: null == xpToNextLevel
          ? _value.xpToNextLevel
          : xpToNextLevel // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserLevelImpl implements _UserLevel {
  const _$UserLevelImpl(
      {required this.currentLevel,
      required this.currentXp,
      required this.xpToNextLevel,
      required this.title});

  factory _$UserLevelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserLevelImplFromJson(json);

  @override
  final int currentLevel;
  @override
  final int currentXp;
  @override
  final int xpToNextLevel;
  @override
  final String title;

  @override
  String toString() {
    return 'UserLevel(currentLevel: $currentLevel, currentXp: $currentXp, xpToNextLevel: $xpToNextLevel, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserLevelImpl &&
            (identical(other.currentLevel, currentLevel) ||
                other.currentLevel == currentLevel) &&
            (identical(other.currentXp, currentXp) ||
                other.currentXp == currentXp) &&
            (identical(other.xpToNextLevel, xpToNextLevel) ||
                other.xpToNextLevel == xpToNextLevel) &&
            (identical(other.title, title) || other.title == title));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, currentLevel, currentXp, xpToNextLevel, title);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserLevelImplCopyWith<_$UserLevelImpl> get copyWith =>
      __$$UserLevelImplCopyWithImpl<_$UserLevelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserLevelImplToJson(
      this,
    );
  }
}

abstract class _UserLevel implements UserLevel {
  const factory _UserLevel(
      {required final int currentLevel,
      required final int currentXp,
      required final int xpToNextLevel,
      required final String title}) = _$UserLevelImpl;

  factory _UserLevel.fromJson(Map<String, dynamic> json) =
      _$UserLevelImpl.fromJson;

  @override
  int get currentLevel;
  @override
  int get currentXp;
  @override
  int get xpToNextLevel;
  @override
  String get title;
  @override
  @JsonKey(ignore: true)
  _$$UserLevelImplCopyWith<_$UserLevelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
