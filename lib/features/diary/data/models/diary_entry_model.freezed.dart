// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diary_entry_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DiaryEntryModel _$DiaryEntryModelFromJson(Map<String, dynamic> json) {
  return _DiaryEntryModel.fromJson(json);
}

/// @nodoc
mixin _$DiaryEntryModel {
  String get id => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  List<String> get mealIds => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DiaryEntryModelCopyWith<DiaryEntryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiaryEntryModelCopyWith<$Res> {
  factory $DiaryEntryModelCopyWith(
          DiaryEntryModel value, $Res Function(DiaryEntryModel) then) =
      _$DiaryEntryModelCopyWithImpl<$Res, DiaryEntryModel>;
  @useResult
  $Res call({String id, DateTime date, List<String> mealIds});
}

/// @nodoc
class _$DiaryEntryModelCopyWithImpl<$Res, $Val extends DiaryEntryModel>
    implements $DiaryEntryModelCopyWith<$Res> {
  _$DiaryEntryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? mealIds = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      mealIds: null == mealIds
          ? _value.mealIds
          : mealIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DiaryEntryModelImplCopyWith<$Res>
    implements $DiaryEntryModelCopyWith<$Res> {
  factory _$$DiaryEntryModelImplCopyWith(_$DiaryEntryModelImpl value,
          $Res Function(_$DiaryEntryModelImpl) then) =
      __$$DiaryEntryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, DateTime date, List<String> mealIds});
}

/// @nodoc
class __$$DiaryEntryModelImplCopyWithImpl<$Res>
    extends _$DiaryEntryModelCopyWithImpl<$Res, _$DiaryEntryModelImpl>
    implements _$$DiaryEntryModelImplCopyWith<$Res> {
  __$$DiaryEntryModelImplCopyWithImpl(
      _$DiaryEntryModelImpl _value, $Res Function(_$DiaryEntryModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? mealIds = null,
  }) {
    return _then(_$DiaryEntryModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      mealIds: null == mealIds
          ? _value._mealIds
          : mealIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DiaryEntryModelImpl implements _DiaryEntryModel {
  const _$DiaryEntryModelImpl(
      {required this.id,
      required this.date,
      required final List<String> mealIds})
      : _mealIds = mealIds;

  factory _$DiaryEntryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiaryEntryModelImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime date;
  final List<String> _mealIds;
  @override
  List<String> get mealIds {
    if (_mealIds is EqualUnmodifiableListView) return _mealIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mealIds);
  }

  @override
  String toString() {
    return 'DiaryEntryModel(id: $id, date: $date, mealIds: $mealIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiaryEntryModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            const DeepCollectionEquality().equals(other._mealIds, _mealIds));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, date, const DeepCollectionEquality().hash(_mealIds));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DiaryEntryModelImplCopyWith<_$DiaryEntryModelImpl> get copyWith =>
      __$$DiaryEntryModelImplCopyWithImpl<_$DiaryEntryModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DiaryEntryModelImplToJson(
      this,
    );
  }
}

abstract class _DiaryEntryModel implements DiaryEntryModel {
  const factory _DiaryEntryModel(
      {required final String id,
      required final DateTime date,
      required final List<String> mealIds}) = _$DiaryEntryModelImpl;

  factory _DiaryEntryModel.fromJson(Map<String, dynamic> json) =
      _$DiaryEntryModelImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get date;
  @override
  List<String> get mealIds;
  @override
  @JsonKey(ignore: true)
  _$$DiaryEntryModelImplCopyWith<_$DiaryEntryModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
