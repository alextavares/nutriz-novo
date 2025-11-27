// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diary_day.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DiaryDay {
  DateTime get date => throw _privateConstructorUsedError;
  List<Meal> get meals => throw _privateConstructorUsedError;
  WaterVolume get waterIntake => throw _privateConstructorUsedError;
  Calories? get calorieGoal => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DiaryDayCopyWith<DiaryDay> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiaryDayCopyWith<$Res> {
  factory $DiaryDayCopyWith(DiaryDay value, $Res Function(DiaryDay) then) =
      _$DiaryDayCopyWithImpl<$Res, DiaryDay>;
  @useResult
  $Res call(
      {DateTime date,
      List<Meal> meals,
      WaterVolume waterIntake,
      Calories? calorieGoal});

  $WaterVolumeCopyWith<$Res> get waterIntake;
  $CaloriesCopyWith<$Res>? get calorieGoal;
}

/// @nodoc
class _$DiaryDayCopyWithImpl<$Res, $Val extends DiaryDay>
    implements $DiaryDayCopyWith<$Res> {
  _$DiaryDayCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? meals = null,
    Object? waterIntake = null,
    Object? calorieGoal = freezed,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      meals: null == meals
          ? _value.meals
          : meals // ignore: cast_nullable_to_non_nullable
              as List<Meal>,
      waterIntake: null == waterIntake
          ? _value.waterIntake
          : waterIntake // ignore: cast_nullable_to_non_nullable
              as WaterVolume,
      calorieGoal: freezed == calorieGoal
          ? _value.calorieGoal
          : calorieGoal // ignore: cast_nullable_to_non_nullable
              as Calories?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $WaterVolumeCopyWith<$Res> get waterIntake {
    return $WaterVolumeCopyWith<$Res>(_value.waterIntake, (value) {
      return _then(_value.copyWith(waterIntake: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $CaloriesCopyWith<$Res>? get calorieGoal {
    if (_value.calorieGoal == null) {
      return null;
    }

    return $CaloriesCopyWith<$Res>(_value.calorieGoal!, (value) {
      return _then(_value.copyWith(calorieGoal: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DiaryDayImplCopyWith<$Res>
    implements $DiaryDayCopyWith<$Res> {
  factory _$$DiaryDayImplCopyWith(
          _$DiaryDayImpl value, $Res Function(_$DiaryDayImpl) then) =
      __$$DiaryDayImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime date,
      List<Meal> meals,
      WaterVolume waterIntake,
      Calories? calorieGoal});

  @override
  $WaterVolumeCopyWith<$Res> get waterIntake;
  @override
  $CaloriesCopyWith<$Res>? get calorieGoal;
}

/// @nodoc
class __$$DiaryDayImplCopyWithImpl<$Res>
    extends _$DiaryDayCopyWithImpl<$Res, _$DiaryDayImpl>
    implements _$$DiaryDayImplCopyWith<$Res> {
  __$$DiaryDayImplCopyWithImpl(
      _$DiaryDayImpl _value, $Res Function(_$DiaryDayImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? meals = null,
    Object? waterIntake = null,
    Object? calorieGoal = freezed,
  }) {
    return _then(_$DiaryDayImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      meals: null == meals
          ? _value._meals
          : meals // ignore: cast_nullable_to_non_nullable
              as List<Meal>,
      waterIntake: null == waterIntake
          ? _value.waterIntake
          : waterIntake // ignore: cast_nullable_to_non_nullable
              as WaterVolume,
      calorieGoal: freezed == calorieGoal
          ? _value.calorieGoal
          : calorieGoal // ignore: cast_nullable_to_non_nullable
              as Calories?,
    ));
  }
}

/// @nodoc

class _$DiaryDayImpl extends _DiaryDay {
  const _$DiaryDayImpl(
      {required this.date,
      final List<Meal> meals = const [],
      this.waterIntake = const WaterVolume(0),
      this.calorieGoal})
      : _meals = meals,
        super._();

  @override
  final DateTime date;
  final List<Meal> _meals;
  @override
  @JsonKey()
  List<Meal> get meals {
    if (_meals is EqualUnmodifiableListView) return _meals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_meals);
  }

  @override
  @JsonKey()
  final WaterVolume waterIntake;
  @override
  final Calories? calorieGoal;

  @override
  String toString() {
    return 'DiaryDay(date: $date, meals: $meals, waterIntake: $waterIntake, calorieGoal: $calorieGoal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiaryDayImpl &&
            (identical(other.date, date) || other.date == date) &&
            const DeepCollectionEquality().equals(other._meals, _meals) &&
            (identical(other.waterIntake, waterIntake) ||
                other.waterIntake == waterIntake) &&
            (identical(other.calorieGoal, calorieGoal) ||
                other.calorieGoal == calorieGoal));
  }

  @override
  int get hashCode => Object.hash(runtimeType, date,
      const DeepCollectionEquality().hash(_meals), waterIntake, calorieGoal);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DiaryDayImplCopyWith<_$DiaryDayImpl> get copyWith =>
      __$$DiaryDayImplCopyWithImpl<_$DiaryDayImpl>(this, _$identity);
}

abstract class _DiaryDay extends DiaryDay {
  const factory _DiaryDay(
      {required final DateTime date,
      final List<Meal> meals,
      final WaterVolume waterIntake,
      final Calories? calorieGoal}) = _$DiaryDayImpl;
  const _DiaryDay._() : super._();

  @override
  DateTime get date;
  @override
  List<Meal> get meals;
  @override
  WaterVolume get waterIntake;
  @override
  Calories? get calorieGoal;
  @override
  @JsonKey(ignore: true)
  _$$DiaryDayImplCopyWith<_$DiaryDayImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
