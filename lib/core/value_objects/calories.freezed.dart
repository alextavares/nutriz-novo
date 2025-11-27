// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calories.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Calories {
  double get value => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CaloriesCopyWith<Calories> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CaloriesCopyWith<$Res> {
  factory $CaloriesCopyWith(Calories value, $Res Function(Calories) then) =
      _$CaloriesCopyWithImpl<$Res, Calories>;
  @useResult
  $Res call({double value});
}

/// @nodoc
class _$CaloriesCopyWithImpl<$Res, $Val extends Calories>
    implements $CaloriesCopyWith<$Res> {
  _$CaloriesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
  }) {
    return _then(_value.copyWith(
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CaloriesImplCopyWith<$Res>
    implements $CaloriesCopyWith<$Res> {
  factory _$$CaloriesImplCopyWith(
          _$CaloriesImpl value, $Res Function(_$CaloriesImpl) then) =
      __$$CaloriesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double value});
}

/// @nodoc
class __$$CaloriesImplCopyWithImpl<$Res>
    extends _$CaloriesCopyWithImpl<$Res, _$CaloriesImpl>
    implements _$$CaloriesImplCopyWith<$Res> {
  __$$CaloriesImplCopyWithImpl(
      _$CaloriesImpl _value, $Res Function(_$CaloriesImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? value = null,
  }) {
    return _then(_$CaloriesImpl(
      null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$CaloriesImpl extends _Calories {
  const _$CaloriesImpl(this.value) : super._();

  @override
  final double value;

  @override
  String toString() {
    return 'Calories(value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CaloriesImpl &&
            (identical(other.value, value) || other.value == value));
  }

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CaloriesImplCopyWith<_$CaloriesImpl> get copyWith =>
      __$$CaloriesImplCopyWithImpl<_$CaloriesImpl>(this, _$identity);
}

abstract class _Calories extends Calories {
  const factory _Calories(final double value) = _$CaloriesImpl;
  const _Calories._() : super._();

  @override
  double get value;
  @override
  @JsonKey(ignore: true)
  _$$CaloriesImplCopyWith<_$CaloriesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
