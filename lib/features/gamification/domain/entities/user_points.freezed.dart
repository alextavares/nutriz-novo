// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_points.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserPoints _$UserPointsFromJson(Map<String, dynamic> json) {
  return _UserPoints.fromJson(json);
}

/// @nodoc
mixin _$UserPoints {
  int get totalPoints => throw _privateConstructorUsedError;
  int get weeklyPoints => throw _privateConstructorUsedError;
  List<PointHistoryEntry> get history => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserPointsCopyWith<UserPoints> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserPointsCopyWith<$Res> {
  factory $UserPointsCopyWith(
          UserPoints value, $Res Function(UserPoints) then) =
      _$UserPointsCopyWithImpl<$Res, UserPoints>;
  @useResult
  $Res call(
      {int totalPoints, int weeklyPoints, List<PointHistoryEntry> history});
}

/// @nodoc
class _$UserPointsCopyWithImpl<$Res, $Val extends UserPoints>
    implements $UserPointsCopyWith<$Res> {
  _$UserPointsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalPoints = null,
    Object? weeklyPoints = null,
    Object? history = null,
  }) {
    return _then(_value.copyWith(
      totalPoints: null == totalPoints
          ? _value.totalPoints
          : totalPoints // ignore: cast_nullable_to_non_nullable
              as int,
      weeklyPoints: null == weeklyPoints
          ? _value.weeklyPoints
          : weeklyPoints // ignore: cast_nullable_to_non_nullable
              as int,
      history: null == history
          ? _value.history
          : history // ignore: cast_nullable_to_non_nullable
              as List<PointHistoryEntry>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserPointsImplCopyWith<$Res>
    implements $UserPointsCopyWith<$Res> {
  factory _$$UserPointsImplCopyWith(
          _$UserPointsImpl value, $Res Function(_$UserPointsImpl) then) =
      __$$UserPointsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalPoints, int weeklyPoints, List<PointHistoryEntry> history});
}

/// @nodoc
class __$$UserPointsImplCopyWithImpl<$Res>
    extends _$UserPointsCopyWithImpl<$Res, _$UserPointsImpl>
    implements _$$UserPointsImplCopyWith<$Res> {
  __$$UserPointsImplCopyWithImpl(
      _$UserPointsImpl _value, $Res Function(_$UserPointsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalPoints = null,
    Object? weeklyPoints = null,
    Object? history = null,
  }) {
    return _then(_$UserPointsImpl(
      totalPoints: null == totalPoints
          ? _value.totalPoints
          : totalPoints // ignore: cast_nullable_to_non_nullable
              as int,
      weeklyPoints: null == weeklyPoints
          ? _value.weeklyPoints
          : weeklyPoints // ignore: cast_nullable_to_non_nullable
              as int,
      history: null == history
          ? _value._history
          : history // ignore: cast_nullable_to_non_nullable
              as List<PointHistoryEntry>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserPointsImpl implements _UserPoints {
  const _$UserPointsImpl(
      {required this.totalPoints,
      required this.weeklyPoints,
      required final List<PointHistoryEntry> history})
      : _history = history;

  factory _$UserPointsImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserPointsImplFromJson(json);

  @override
  final int totalPoints;
  @override
  final int weeklyPoints;
  final List<PointHistoryEntry> _history;
  @override
  List<PointHistoryEntry> get history {
    if (_history is EqualUnmodifiableListView) return _history;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_history);
  }

  @override
  String toString() {
    return 'UserPoints(totalPoints: $totalPoints, weeklyPoints: $weeklyPoints, history: $history)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserPointsImpl &&
            (identical(other.totalPoints, totalPoints) ||
                other.totalPoints == totalPoints) &&
            (identical(other.weeklyPoints, weeklyPoints) ||
                other.weeklyPoints == weeklyPoints) &&
            const DeepCollectionEquality().equals(other._history, _history));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, totalPoints, weeklyPoints,
      const DeepCollectionEquality().hash(_history));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserPointsImplCopyWith<_$UserPointsImpl> get copyWith =>
      __$$UserPointsImplCopyWithImpl<_$UserPointsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserPointsImplToJson(
      this,
    );
  }
}

abstract class _UserPoints implements UserPoints {
  const factory _UserPoints(
      {required final int totalPoints,
      required final int weeklyPoints,
      required final List<PointHistoryEntry> history}) = _$UserPointsImpl;

  factory _UserPoints.fromJson(Map<String, dynamic> json) =
      _$UserPointsImpl.fromJson;

  @override
  int get totalPoints;
  @override
  int get weeklyPoints;
  @override
  List<PointHistoryEntry> get history;
  @override
  @JsonKey(ignore: true)
  _$$UserPointsImplCopyWith<_$UserPointsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PointHistoryEntry _$PointHistoryEntryFromJson(Map<String, dynamic> json) {
  return _PointHistoryEntry.fromJson(json);
}

/// @nodoc
mixin _$PointHistoryEntry {
  String get reason => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PointHistoryEntryCopyWith<PointHistoryEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PointHistoryEntryCopyWith<$Res> {
  factory $PointHistoryEntryCopyWith(
          PointHistoryEntry value, $Res Function(PointHistoryEntry) then) =
      _$PointHistoryEntryCopyWithImpl<$Res, PointHistoryEntry>;
  @useResult
  $Res call({String reason, int points, DateTime date});
}

/// @nodoc
class _$PointHistoryEntryCopyWithImpl<$Res, $Val extends PointHistoryEntry>
    implements $PointHistoryEntryCopyWith<$Res> {
  _$PointHistoryEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reason = null,
    Object? points = null,
    Object? date = null,
  }) {
    return _then(_value.copyWith(
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PointHistoryEntryImplCopyWith<$Res>
    implements $PointHistoryEntryCopyWith<$Res> {
  factory _$$PointHistoryEntryImplCopyWith(_$PointHistoryEntryImpl value,
          $Res Function(_$PointHistoryEntryImpl) then) =
      __$$PointHistoryEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String reason, int points, DateTime date});
}

/// @nodoc
class __$$PointHistoryEntryImplCopyWithImpl<$Res>
    extends _$PointHistoryEntryCopyWithImpl<$Res, _$PointHistoryEntryImpl>
    implements _$$PointHistoryEntryImplCopyWith<$Res> {
  __$$PointHistoryEntryImplCopyWithImpl(_$PointHistoryEntryImpl _value,
      $Res Function(_$PointHistoryEntryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reason = null,
    Object? points = null,
    Object? date = null,
  }) {
    return _then(_$PointHistoryEntryImpl(
      reason: null == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PointHistoryEntryImpl implements _PointHistoryEntry {
  const _$PointHistoryEntryImpl(
      {required this.reason, required this.points, required this.date});

  factory _$PointHistoryEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$PointHistoryEntryImplFromJson(json);

  @override
  final String reason;
  @override
  final int points;
  @override
  final DateTime date;

  @override
  String toString() {
    return 'PointHistoryEntry(reason: $reason, points: $points, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PointHistoryEntryImpl &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.date, date) || other.date == date));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, reason, points, date);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PointHistoryEntryImplCopyWith<_$PointHistoryEntryImpl> get copyWith =>
      __$$PointHistoryEntryImplCopyWithImpl<_$PointHistoryEntryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PointHistoryEntryImplToJson(
      this,
    );
  }
}

abstract class _PointHistoryEntry implements PointHistoryEntry {
  const factory _PointHistoryEntry(
      {required final String reason,
      required final int points,
      required final DateTime date}) = _$PointHistoryEntryImpl;

  factory _PointHistoryEntry.fromJson(Map<String, dynamic> json) =
      _$PointHistoryEntryImpl.fromJson;

  @override
  String get reason;
  @override
  int get points;
  @override
  DateTime get date;
  @override
  @JsonKey(ignore: true)
  _$$PointHistoryEntryImplCopyWith<_$PointHistoryEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
