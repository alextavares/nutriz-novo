// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DiaryEntryModelImpl _$$DiaryEntryModelImplFromJson(
        Map<String, dynamic> json) =>
    _$DiaryEntryModelImpl(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      mealIds:
          (json['mealIds'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$DiaryEntryModelImplToJson(
        _$DiaryEntryModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'mealIds': instance.mealIds,
    };
