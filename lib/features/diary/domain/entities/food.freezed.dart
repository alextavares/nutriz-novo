// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'food.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Food {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  Calories get calories => throw _privateConstructorUsedError;
  MacroNutrients get macros => throw _privateConstructorUsedError;
  double get servingSize =>
      throw _privateConstructorUsedError; // em gramas ou ml
  String get servingUnit => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $FoodCopyWith<Food> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FoodCopyWith<$Res> {
  factory $FoodCopyWith(Food value, $Res Function(Food) then) =
      _$FoodCopyWithImpl<$Res, Food>;
  @useResult
  $Res call(
      {String id,
      String name,
      Calories calories,
      MacroNutrients macros,
      double servingSize,
      String servingUnit});

  $CaloriesCopyWith<$Res> get calories;
  $MacroNutrientsCopyWith<$Res> get macros;
}

/// @nodoc
class _$FoodCopyWithImpl<$Res, $Val extends Food>
    implements $FoodCopyWith<$Res> {
  _$FoodCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? calories = null,
    Object? macros = null,
    Object? servingSize = null,
    Object? servingUnit = null,
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
      calories: null == calories
          ? _value.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as Calories,
      macros: null == macros
          ? _value.macros
          : macros // ignore: cast_nullable_to_non_nullable
              as MacroNutrients,
      servingSize: null == servingSize
          ? _value.servingSize
          : servingSize // ignore: cast_nullable_to_non_nullable
              as double,
      servingUnit: null == servingUnit
          ? _value.servingUnit
          : servingUnit // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $CaloriesCopyWith<$Res> get calories {
    return $CaloriesCopyWith<$Res>(_value.calories, (value) {
      return _then(_value.copyWith(calories: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $MacroNutrientsCopyWith<$Res> get macros {
    return $MacroNutrientsCopyWith<$Res>(_value.macros, (value) {
      return _then(_value.copyWith(macros: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FoodImplCopyWith<$Res> implements $FoodCopyWith<$Res> {
  factory _$$FoodImplCopyWith(
          _$FoodImpl value, $Res Function(_$FoodImpl) then) =
      __$$FoodImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      Calories calories,
      MacroNutrients macros,
      double servingSize,
      String servingUnit});

  @override
  $CaloriesCopyWith<$Res> get calories;
  @override
  $MacroNutrientsCopyWith<$Res> get macros;
}

/// @nodoc
class __$$FoodImplCopyWithImpl<$Res>
    extends _$FoodCopyWithImpl<$Res, _$FoodImpl>
    implements _$$FoodImplCopyWith<$Res> {
  __$$FoodImplCopyWithImpl(_$FoodImpl _value, $Res Function(_$FoodImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? calories = null,
    Object? macros = null,
    Object? servingSize = null,
    Object? servingUnit = null,
  }) {
    return _then(_$FoodImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      calories: null == calories
          ? _value.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as Calories,
      macros: null == macros
          ? _value.macros
          : macros // ignore: cast_nullable_to_non_nullable
              as MacroNutrients,
      servingSize: null == servingSize
          ? _value.servingSize
          : servingSize // ignore: cast_nullable_to_non_nullable
              as double,
      servingUnit: null == servingUnit
          ? _value.servingUnit
          : servingUnit // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$FoodImpl implements _Food {
  const _$FoodImpl(
      {required this.id,
      required this.name,
      required this.calories,
      required this.macros,
      required this.servingSize,
      required this.servingUnit});

  @override
  final String id;
  @override
  final String name;
  @override
  final Calories calories;
  @override
  final MacroNutrients macros;
  @override
  final double servingSize;
// em gramas ou ml
  @override
  final String servingUnit;

  @override
  String toString() {
    return 'Food(id: $id, name: $name, calories: $calories, macros: $macros, servingSize: $servingSize, servingUnit: $servingUnit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FoodImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.calories, calories) ||
                other.calories == calories) &&
            (identical(other.macros, macros) || other.macros == macros) &&
            (identical(other.servingSize, servingSize) ||
                other.servingSize == servingSize) &&
            (identical(other.servingUnit, servingUnit) ||
                other.servingUnit == servingUnit));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, calories, macros, servingSize, servingUnit);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FoodImplCopyWith<_$FoodImpl> get copyWith =>
      __$$FoodImplCopyWithImpl<_$FoodImpl>(this, _$identity);
}

abstract class _Food implements Food {
  const factory _Food(
      {required final String id,
      required final String name,
      required final Calories calories,
      required final MacroNutrients macros,
      required final double servingSize,
      required final String servingUnit}) = _$FoodImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  Calories get calories;
  @override
  MacroNutrients get macros;
  @override
  double get servingSize;
  @override // em gramas ou ml
  String get servingUnit;
  @override
  @JsonKey(ignore: true)
  _$$FoodImplCopyWith<_$FoodImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
