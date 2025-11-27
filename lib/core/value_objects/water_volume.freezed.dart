// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'water_volume.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$WaterVolume {
  double get valueMl => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $WaterVolumeCopyWith<WaterVolume> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WaterVolumeCopyWith<$Res> {
  factory $WaterVolumeCopyWith(
          WaterVolume value, $Res Function(WaterVolume) then) =
      _$WaterVolumeCopyWithImpl<$Res, WaterVolume>;
  @useResult
  $Res call({double valueMl});
}

/// @nodoc
class _$WaterVolumeCopyWithImpl<$Res, $Val extends WaterVolume>
    implements $WaterVolumeCopyWith<$Res> {
  _$WaterVolumeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? valueMl = null,
  }) {
    return _then(_value.copyWith(
      valueMl: null == valueMl
          ? _value.valueMl
          : valueMl // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WaterVolumeImplCopyWith<$Res>
    implements $WaterVolumeCopyWith<$Res> {
  factory _$$WaterVolumeImplCopyWith(
          _$WaterVolumeImpl value, $Res Function(_$WaterVolumeImpl) then) =
      __$$WaterVolumeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double valueMl});
}

/// @nodoc
class __$$WaterVolumeImplCopyWithImpl<$Res>
    extends _$WaterVolumeCopyWithImpl<$Res, _$WaterVolumeImpl>
    implements _$$WaterVolumeImplCopyWith<$Res> {
  __$$WaterVolumeImplCopyWithImpl(
      _$WaterVolumeImpl _value, $Res Function(_$WaterVolumeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? valueMl = null,
  }) {
    return _then(_$WaterVolumeImpl(
      null == valueMl
          ? _value.valueMl
          : valueMl // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$WaterVolumeImpl extends _WaterVolume {
  const _$WaterVolumeImpl(this.valueMl) : super._();

  @override
  final double valueMl;

  @override
  String toString() {
    return 'WaterVolume(valueMl: $valueMl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WaterVolumeImpl &&
            (identical(other.valueMl, valueMl) || other.valueMl == valueMl));
  }

  @override
  int get hashCode => Object.hash(runtimeType, valueMl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WaterVolumeImplCopyWith<_$WaterVolumeImpl> get copyWith =>
      __$$WaterVolumeImplCopyWithImpl<_$WaterVolumeImpl>(this, _$identity);
}

abstract class _WaterVolume extends WaterVolume {
  const factory _WaterVolume(final double valueMl) = _$WaterVolumeImpl;
  const _WaterVolume._() : super._();

  @override
  double get valueMl;
  @override
  @JsonKey(ignore: true)
  _$$WaterVolumeImplCopyWith<_$WaterVolumeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
