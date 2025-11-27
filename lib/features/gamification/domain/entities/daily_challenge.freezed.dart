// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_challenge.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DailyChallenge _$DailyChallengeFromJson(Map<String, dynamic> json) {
  return _DailyChallenge.fromJson(json);
}

/// @nodoc
mixin _$DailyChallenge {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  int get rewardPoints => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DailyChallengeCopyWith<DailyChallenge> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyChallengeCopyWith<$Res> {
  factory $DailyChallengeCopyWith(
          DailyChallenge value, $Res Function(DailyChallenge) then) =
      _$DailyChallengeCopyWithImpl<$Res, DailyChallenge>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      int rewardPoints,
      bool isCompleted,
      DateTime date});
}

/// @nodoc
class _$DailyChallengeCopyWithImpl<$Res, $Val extends DailyChallenge>
    implements $DailyChallengeCopyWith<$Res> {
  _$DailyChallengeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? rewardPoints = null,
    Object? isCompleted = null,
    Object? date = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      rewardPoints: null == rewardPoints
          ? _value.rewardPoints
          : rewardPoints // ignore: cast_nullable_to_non_nullable
              as int,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DailyChallengeImplCopyWith<$Res>
    implements $DailyChallengeCopyWith<$Res> {
  factory _$$DailyChallengeImplCopyWith(_$DailyChallengeImpl value,
          $Res Function(_$DailyChallengeImpl) then) =
      __$$DailyChallengeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      int rewardPoints,
      bool isCompleted,
      DateTime date});
}

/// @nodoc
class __$$DailyChallengeImplCopyWithImpl<$Res>
    extends _$DailyChallengeCopyWithImpl<$Res, _$DailyChallengeImpl>
    implements _$$DailyChallengeImplCopyWith<$Res> {
  __$$DailyChallengeImplCopyWithImpl(
      _$DailyChallengeImpl _value, $Res Function(_$DailyChallengeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? rewardPoints = null,
    Object? isCompleted = null,
    Object? date = null,
  }) {
    return _then(_$DailyChallengeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      rewardPoints: null == rewardPoints
          ? _value.rewardPoints
          : rewardPoints // ignore: cast_nullable_to_non_nullable
              as int,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyChallengeImpl implements _DailyChallenge {
  const _$DailyChallengeImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.rewardPoints,
      required this.isCompleted,
      required this.date});

  factory _$DailyChallengeImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyChallengeImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final int rewardPoints;
  @override
  final bool isCompleted;
  @override
  final DateTime date;

  @override
  String toString() {
    return 'DailyChallenge(id: $id, title: $title, description: $description, rewardPoints: $rewardPoints, isCompleted: $isCompleted, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyChallengeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.rewardPoints, rewardPoints) ||
                other.rewardPoints == rewardPoints) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.date, date) || other.date == date));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, title, description, rewardPoints, isCompleted, date);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyChallengeImplCopyWith<_$DailyChallengeImpl> get copyWith =>
      __$$DailyChallengeImplCopyWithImpl<_$DailyChallengeImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyChallengeImplToJson(
      this,
    );
  }
}

abstract class _DailyChallenge implements DailyChallenge {
  const factory _DailyChallenge(
      {required final String id,
      required final String title,
      required final String description,
      required final int rewardPoints,
      required final bool isCompleted,
      required final DateTime date}) = _$DailyChallengeImpl;

  factory _DailyChallenge.fromJson(Map<String, dynamic> json) =
      _$DailyChallengeImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  int get rewardPoints;
  @override
  bool get isCompleted;
  @override
  DateTime get date;
  @override
  @JsonKey(ignore: true)
  _$$DailyChallengeImplCopyWith<_$DailyChallengeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
