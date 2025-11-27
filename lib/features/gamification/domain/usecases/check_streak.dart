import '../repositories/gamification_repository.dart';
import '../../../../core/extensions/datetime_extensions.dart';

class CheckStreak {
  final GamificationRepository _repository;

  CheckStreak(this._repository);

  Future<void> call() async {
    final streak = await _repository.getStreak();
    final now = DateTime.now();
    final lastActivity = streak.lastActivityDate;

    if (now.isToday) return; // Já contou hoje

    final difference = now.difference(lastActivity).inDays;

    if (difference == 1) {
      // Dia consecutivo
      final newStreak = streak.copyWith(
        currentStreak: streak.currentStreak + 1,
        bestStreak: (streak.currentStreak + 1) > streak.bestStreak
            ? (streak.currentStreak + 1)
            : streak.bestStreak,
        lastActivityDate: now,
      );
      await _repository.saveStreak(newStreak);
    } else if (difference > 1) {
      // Quebrou o streak (verificar freeze depois)
      final newStreak = streak.copyWith(
        currentStreak: 1, // Reinicia
        lastActivityDate: now,
      );
      await _repository.saveStreak(newStreak);
    }
  }
}
