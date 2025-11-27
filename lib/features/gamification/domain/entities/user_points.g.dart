// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_points.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserPointsImpl _$$UserPointsImplFromJson(Map<String, dynamic> json) =>
    _$UserPointsImpl(
      totalPoints: (json['totalPoints'] as num).toInt(),
      weeklyPoints: (json['weeklyPoints'] as num).toInt(),
      history: (json['history'] as List<dynamic>)
          .map((e) => PointHistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$UserPointsImplToJson(_$UserPointsImpl instance) =>
    <String, dynamic>{
      'totalPoints': instance.totalPoints,
      'weeklyPoints': instance.weeklyPoints,
      'history': instance.history,
    };

_$PointHistoryEntryImpl _$$PointHistoryEntryImplFromJson(
        Map<String, dynamic> json) =>
    _$PointHistoryEntryImpl(
      reason: json['reason'] as String,
      points: (json['points'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$$PointHistoryEntryImplToJson(
        _$PointHistoryEntryImpl instance) =>
    <String, dynamic>{
      'reason': instance.reason,
      'points': instance.points,
      'date': instance.date.toIso8601String(),
    };
