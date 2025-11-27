import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/diary_day.dart';
import '../../../../core/value_objects/weight.dart';

part 'diary_state.freezed.dart';

@freezed
class DiaryState with _$DiaryState {
  const factory DiaryState({
    required DateTime selectedDate,
    @Default(AsyncValue.loading()) AsyncValue<DiaryDay> diaryDay,
    Weight? currentWeight,
  }) = _DiaryState;

  factory DiaryState.initial() => DiaryState(selectedDate: DateTime.now());
}
