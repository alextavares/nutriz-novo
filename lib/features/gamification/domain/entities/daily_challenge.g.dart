// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_challenge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DailyChallengeImpl _$$DailyChallengeImplFromJson(Map<String, dynamic> json) =>
    _$DailyChallengeImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      rewardPoints: (json['rewardPoints'] as num).toInt(),
      isCompleted: json['isCompleted'] as bool,
      date: DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$$DailyChallengeImplToJson(
        _$DailyChallengeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'rewardPoints': instance.rewardPoints,
      'isCompleted': instance.isCompleted,
      'date': instance.date.toIso8601String(),
    };
