// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'macro_nutrients.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MacroNutrients {
  double get carbs => throw _privateConstructorUsedError;
  double get protein => throw _privateConstructorUsedError;
  double get fat => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MacroNutrientsCopyWith<MacroNutrients> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MacroNutrientsCopyWith<$Res> {
  factory $MacroNutrientsCopyWith(
          MacroNutrients value, $Res Function(MacroNutrients) then) =
      _$MacroNutrientsCopyWithImpl<$Res, MacroNutrients>;
  @useResult
  $Res call({double carbs, double protein, double fat});
}

/// @nodoc
class _$MacroNutrientsCopyWithImpl<$Res, $Val extends MacroNutrients>
    implements $MacroNutrientsCopyWith<$Res> {
  _$MacroNutrientsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? carbs = null,
    Object? protein = null,
    Object? fat = null,
  }) {
    return _then(_value.copyWith(
      carbs: null == carbs
          ? _value.carbs
          : carbs // ignore: cast_nullable_to_non_nullable
              as double,
      protein: null == protein
          ? _value.protein
          : protein // ignore: cast_nullable_to_non_nullable
              as double,
      fat: null == fat
          ? _value.fat
          : fat // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MacroNutrientsImplCopyWith<$Res>
    implements $MacroNutrientsCopyWith<$Res> {
  factory _$$MacroNutrientsImplCopyWith(_$MacroNutrientsImpl value,
          $Res Function(_$MacroNutrientsImpl) then) =
      __$$MacroNutrientsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double carbs, double protein, double fat});
}

/// @nodoc
class __$$MacroNutrientsImplCopyWithImpl<$Res>
    extends _$MacroNutrientsCopyWithImpl<$Res, _$MacroNutrientsImpl>
    implements _$$MacroNutrientsImplCopyWith<$Res> {
  __$$MacroNutrientsImplCopyWithImpl(
      _$MacroNutrientsImpl _value, $Res Function(_$MacroNutrientsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? carbs = null,
    Object? protein = null,
    Object? fat = null,
  }) {
    return _then(_$MacroNutrientsImpl(
      carbs: null == carbs
          ? _value.carbs
          : carbs // ignore: cast_nullable_to_non_nullable
              as double,
      protein: null == protein
          ? _value.protein
          : protein // ignore: cast_nullable_to_non_nullable
              as double,
      fat: null == fat
          ? _value.fat
          : fat // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$MacroNutrientsImpl implements _MacroNutrients {
  const _$MacroNutrientsImpl(
      {required this.carbs, required this.protein, required this.fat});

  @override
  final double carbs;
  @override
  final double protein;
  @override
  final double fat;

  @override
  String toString() {
    return 'MacroNutrients(carbs: $carbs, protein: $protein, fat: $fat)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MacroNutrientsImpl &&
            (identical(other.carbs, carbs) || other.carbs == carbs) &&
            (identical(other.protein, protein) || other.protein == protein) &&
            (identical(other.fat, fat) || other.fat == fat));
  }

  @override
  int get hashCode => Object.hash(runtimeType, carbs, protein, fat);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MacroNutrientsImplCopyWith<_$MacroNutrientsImpl> get copyWith =>
      __$$MacroNutrientsImplCopyWithImpl<_$MacroNutrientsImpl>(
          this, _$identity);
}

abstract class _MacroNutrients implements MacroNutrients {
  const factory _MacroNutrients(
      {required final double carbs,
      required final double protein,
      required final double fat}) = _$MacroNutrientsImpl;

  @override
  double get carbs;
  @override
  double get protein;
  @override
  double get fat;
  @override
  @JsonKey(ignore: true)
  _$$MacroNutrientsImplCopyWith<_$MacroNutrientsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
