import 'package:freezed_annotation/freezed_annotation.dart';

part 'diary_entry_model.freezed.dart';
part 'diary_entry_model.g.dart';

@freezed
class DiaryEntryModel with _$DiaryEntryModel {
  const factory DiaryEntryModel({
    required String id,
    required DateTime date,
    required List<String> mealIds,
  }) = _DiaryEntryModel;

  factory DiaryEntryModel.fromJson(Map<String, dynamic> json) => _$DiaryEntryModelFromJson(json);
}
