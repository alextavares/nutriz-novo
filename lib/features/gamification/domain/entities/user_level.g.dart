// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_level.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserLevelImpl _$$UserLevelImplFromJson(Map<String, dynamic> json) =>
    _$UserLevelImpl(
      currentLevel: (json['currentLevel'] as num).toInt(),
      currentXp: (json['currentXp'] as num).toInt(),
      xpToNextLevel: (json['xpToNextLevel'] as num).toInt(),
      title: json['title'] as String,
    );

Map<String, dynamic> _$$UserLevelImplToJson(_$UserLevelImpl instance) =>
    <String, dynamic>{
      'currentLevel': instance.currentLevel,
      'currentXp': instance.currentXp,
      'xpToNextLevel': instance.xpToNextLevel,
      'title': instance.title,
    };
