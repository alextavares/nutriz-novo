import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/food.dart';
import '../notifiers/food_search_notifier.dart';

import '../../data/repositories/diary_repository_impl.dart';
import '../../domain/repositories/diary_repository.dart';
import '../../domain/usecases/get_daily_summary.dart';
import '../../domain/usecases/add_food_to_meal.dart';
import '../../domain/usecases/update_water_intake.dart';
import '../../domain/usecases/log_weight.dart';
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

final diaryNotifierProvider = StateNotifierProvider<DiaryNotifier, DiaryState>((
  ref,
) {
  return DiaryNotifier(
    getDailySummary: ref.watch(getDailySummaryUseCaseProvider),
    addFoodToMeal: ref.watch(addFoodToMealUseCaseProvider),
    updateWaterIntake: ref.watch(updateWaterIntakeUseCaseProvider),
    logWeight: ref.watch(logWeightUseCaseProvider),
  );
});

final foodSearchNotifierProvider =
    StateNotifierProvider<FoodSearchNotifier, List<Food>>((ref) {
      return FoodSearchNotifier();
    });
