// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diary_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DiaryState {
  DateTime get selectedDate => throw _privateConstructorUsedError;
  AsyncValue<DiaryDay> get diaryDay => throw _privateConstructorUsedError;
  Weight? get currentWeight => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DiaryStateCopyWith<DiaryState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiaryStateCopyWith<$Res> {
  factory $DiaryStateCopyWith(
          DiaryState value, $Res Function(DiaryState) then) =
      _$DiaryStateCopyWithImpl<$Res, DiaryState>;
  @useResult
  $Res call(
      {DateTime selectedDate,
      AsyncValue<DiaryDay> diaryDay,
      Weight? currentWeight});

  $WeightCopyWith<$Res>? get currentWeight;
}

/// @nodoc
class _$DiaryStateCopyWithImpl<$Res, $Val extends DiaryState>
    implements $DiaryStateCopyWith<$Res> {
  _$DiaryStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedDate = null,
    Object? diaryDay = null,
    Object? currentWeight = freezed,
  }) {
    return _then(_value.copyWith(
      selectedDate: null == selectedDate
          ? _value.selectedDate
          : selectedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      diaryDay: null == diaryDay
          ? _value.diaryDay
          : diaryDay // ignore: cast_nullable_to_non_nullable
              as AsyncValue<DiaryDay>,
      currentWeight: freezed == currentWeight
          ? _value.currentWeight
          : currentWeight // ignore: cast_nullable_to_non_nullable
              as Weight?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $WeightCopyWith<$Res>? get currentWeight {
    if (_value.currentWeight == null) {
      return null;
    }

    return $WeightCopyWith<$Res>(_value.currentWeight!, (value) {
      return _then(_value.copyWith(currentWeight: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DiaryStateImplCopyWith<$Res>
    implements $DiaryStateCopyWith<$Res> {
  factory _$$DiaryStateImplCopyWith(
          _$DiaryStateImpl value, $Res Function(_$DiaryStateImpl) then) =
      __$$DiaryStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime selectedDate,
      AsyncValue<DiaryDay> diaryDay,
      Weight? currentWeight});

  @override
  $WeightCopyWith<$Res>? get currentWeight;
}

/// @nodoc
class __$$DiaryStateImplCopyWithImpl<$Res>
    extends _$DiaryStateCopyWithImpl<$Res, _$DiaryStateImpl>
    implements _$$DiaryStateImplCopyWith<$Res> {
  __$$DiaryStateImplCopyWithImpl(
      _$DiaryStateImpl _value, $Res Function(_$DiaryStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedDate = null,
    Object? diaryDay = null,
    Object? currentWeight = freezed,
  }) {
    return _then(_$DiaryStateImpl(
      selectedDate: null == selectedDate
          ? _value.selectedDate
          : selectedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      diaryDay: null == diaryDay
          ? _value.diaryDay
          : diaryDay // ignore: cast_nullable_to_non_nullable
              as AsyncValue<DiaryDay>,
      currentWeight: freezed == currentWeight
          ? _value.currentWeight
          : currentWeight // ignore: cast_nullable_to_non_nullable
              as Weight?,
    ));
  }
}

/// @nodoc

class _$DiaryStateImpl implements _DiaryState {
  const _$DiaryStateImpl(
      {required this.selectedDate,
      this.diaryDay = const AsyncValue.loading(),
      this.currentWeight});

  @override
  final DateTime selectedDate;
  @override
  @JsonKey()
  final AsyncValue<DiaryDay> diaryDay;
  @override
  final Weight? currentWeight;

  @override
  String toString() {
    return 'DiaryState(selectedDate: $selectedDate, diaryDay: $diaryDay, currentWeight: $currentWeight)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiaryStateImpl &&
            (identical(other.selectedDate, selectedDate) ||
                other.selectedDate == selectedDate) &&
            (identical(other.diaryDay, diaryDay) ||
                other.diaryDay == diaryDay) &&
            (identical(other.currentWeight, currentWeight) ||
                other.currentWeight == currentWeight));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, selectedDate, diaryDay, currentWeight);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DiaryStateImplCopyWith<_$DiaryStateImpl> get copyWith =>
      __$$DiaryStateImplCopyWithImpl<_$DiaryStateImpl>(this, _$identity);
}

abstract class _DiaryState implements DiaryState {
  const factory _DiaryState(
      {required final DateTime selectedDate,
      final AsyncValue<DiaryDay> diaryDay,
      final Weight? currentWeight}) = _$DiaryStateImpl;

  @override
  DateTime get selectedDate;
  @override
  AsyncValue<DiaryDay> get diaryDay;
  @override
  Weight? get currentWeight;
  @override
  @JsonKey(ignore: true)
  _$$DiaryStateImplCopyWith<_$DiaryStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
