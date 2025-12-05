import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/diary_repository_impl.dart';
import '../../domain/repositories/diary_repository.dart';
import '../../domain/usecases/get_daily_summary.dart';
import '../../domain/usecases/add_food_to_meal.dart';
import '../../domain/usecases/remove_food_from_meal.dart';
import '../../domain/usecases/update_food_quantity.dart';
import '../../domain/usecases/update_water_intake.dart';
import '../../domain/usecases/log_weight.dart';
import '../../domain/usecases/update_notes.dart';
import '../../../../features/gamification/presentation/providers/gamification_providers.dart';
import 'diary_state.dart';
import '../notifiers/diary_notifier.dart';

final diaryRepositoryProvider = Provider<DiaryRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return DiaryRepositoryImpl(isar);
});

final getDailySummaryUseCaseProvider = Provider<GetDailySummary>((ref) {
  return GetDailySummary(ref.watch(diaryRepositoryProvider));
});

final addFoodToMealUseCaseProvider = Provider<AddFoodToMeal>((ref) {
  return AddFoodToMeal(
    ref.watch(diaryRepositoryProvider),
    ref.watch(awardPointsUseCaseProvider),
  );
});

final removeFoodFromMealUseCaseProvider = Provider<RemoveFoodFromMeal>((ref) {
  return RemoveFoodFromMeal(ref.watch(diaryRepositoryProvider));
});

final updateFoodQuantityUseCaseProvider = Provider<UpdateFoodQuantity>((ref) {
  return UpdateFoodQuantity(ref.watch(diaryRepositoryProvider));
});

final updateWaterIntakeUseCaseProvider = Provider<UpdateWaterIntake>((ref) {
  return UpdateWaterIntake(
    ref.watch(diaryRepositoryProvider),
    ref.watch(awardPointsUseCaseProvider),
  );
});

final logWeightUseCaseProvider = Provider<LogWeight>((ref) {
  return LogWeight(
    ref.watch(diaryRepositoryProvider),
    ref.watch(awardPointsUseCaseProvider),
  );
});

final updateNotesUseCaseProvider = Provider<UpdateNotes>((ref) {
  return UpdateNotes(ref.watch(diaryRepositoryProvider));
});

final diaryNotifierProvider = StateNotifierProvider<DiaryNotifier, DiaryState>((
  ref,
) {
  return DiaryNotifier(
    getDailySummary: ref.watch(getDailySummaryUseCaseProvider),
    addFoodToMeal: ref.watch(addFoodToMealUseCaseProvider),
    removeFoodFromMeal: ref.watch(removeFoodFromMealUseCaseProvider),
    updateFoodQuantity: ref.watch(updateFoodQuantityUseCaseProvider),
    updateWaterIntake: ref.watch(updateWaterIntakeUseCaseProvider),
    logWeight: ref.watch(logWeightUseCaseProvider),
    updateNotes: ref.watch(updateNotesUseCaseProvider),
  );
});
