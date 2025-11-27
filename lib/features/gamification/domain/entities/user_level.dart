import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_level.freezed.dart';
part 'user_level.g.dart';

@freezed
class UserLevel with _$UserLevel {
  const factory UserLevel({
    required int currentLevel,
    required int currentXp,
    required int xpToNextLevel,
    required String title, // Ex: "Novato", "Aprendiz", "Mestre"
  }) = _UserLevel;

  factory UserLevel.fromJson(Map<String, dynamic> json) =>
      _$UserLevelFromJson(json);

  factory UserLevel.initial() => const UserLevel(
    currentLevel: 1,
    currentXp: 0,
    xpToNextLevel: 100,
    title: 'Novato',
  );
}
