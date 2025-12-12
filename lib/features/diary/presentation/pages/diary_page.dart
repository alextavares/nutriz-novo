import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

import '../../../../shared/widgets/animations/entry_animation.dart';
import '../../../../shared/widgets/gamification/streak_flame.dart';
import 'package:isar/isar.dart';
import '../../../../features/gamification/presentation/providers/gamification_providers.dart';
import '../../../../features/profile/data/models/user_profile_schema.dart';
import '../../../../routing/app_router.dart';
import '../../domain/entities/meal.dart';
import '../providers/diary_providers.dart';

import '../widgets/daily_summary_header_improved.dart';

import '../widgets/meal_section_improved.dart';

import '../widgets/notes_card.dart';
import '../widgets/quick_weight_log_card.dart';

import '../widgets/water_tracker_connected.dart';
import '../widgets/edit_quantity_sheet.dart';
import '../../../profile/presentation/notifiers/profile_notifier.dart';

class DiaryPage extends ConsumerWidget {
  const DiaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diaryState = ref.watch(diaryNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light grey background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        titleSpacing: AppSpacing.md,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Row(
              children: [
                const Icon(Icons.diamond, color: Colors.blue, size: 20),
                const SizedBox(width: 4),
                const Text(
                  '0',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Streak Flame
                const StreakFlame(
                  streakDays: 1,
                ), // TODO: Connect to real streak
                const SizedBox(width: AppSpacing.md),
                IconButton(
                  icon: const Icon(
                    Icons.account_circle_outlined,
                    color: AppColors.textPrimary,
                    size: 28,
                  ),
                  onPressed: () =>
                      context.push('/food-search/${MealType.breakfast.name}'),
                ),
              ],
            ),
          ),
        ],
      ),
      body: PageView.builder(
        controller: PageController(initialPage: 10000),
        onPageChanged: (index) {
          final today = DateTime.now();
          final diff = index - 10000;
          final newDate = today.add(Duration(days: diff));
          ref.read(diaryNotifierProvider.notifier).changeDate(newDate);
        },
        itemBuilder: (context, index) {
          return diaryState.diaryDay.when(
            data: (day) => ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                150, // Bottom padding for floating nav bar
              ),
              children: [
                // Main Title
                Text(
                  _getDateTitle(day.date),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Week 163',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Summary Card
                EntryAnimation(
                  delay: const Duration(milliseconds: 100),
                  child: DailySummaryHeaderImproved(
                    diaryDay: day,
                    calorieGoal: ref
                        .watch(profileNotifierProvider)
                        .calculatedCalories,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Nutrition Section Header
                EntryAnimation(
                  delay: const Duration(milliseconds: 200),
                  child: _buildSectionHeader('Nutrition', 'More', () {}),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Meals
                EntryAnimation(
                  delay: const Duration(milliseconds: 300),
                  child: MealSectionImproved(
                    title: 'Café da Manhã',
                    meals: day.getMealsByType(MealType.breakfast),
                    onAddPressed: () {
                      context.push('/food-search/${MealType.breakfast.name}');
                    },
                    onRemoveFood: (mealId) {
                      ref
                          .read(diaryNotifierProvider.notifier)
                          .removeFoodFromMeal(mealId);
                    },
                    onFoodTap: (meal, foodItem) =>
                        _showEditSheet(context, ref, meal, foodItem),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                EntryAnimation(
                  delay: const Duration(milliseconds: 400),
                  child: MealSectionImproved(
                    title: 'Almoço',
                    meals: day.getMealsByType(MealType.lunch),
                    onAddPressed: () {
                      context.push('/food-search/${MealType.lunch.name}');
                    },
                    onRemoveFood: (mealId) {
                      ref
                          .read(diaryNotifierProvider.notifier)
                          .removeFoodFromMeal(mealId);
                    },
                    onFoodTap: (meal, foodItem) =>
                        _showEditSheet(context, ref, meal, foodItem),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                EntryAnimation(
                  delay: const Duration(milliseconds: 500),
                  child: MealSectionImproved(
                    title: 'Jantar',
                    meals: day.getMealsByType(MealType.dinner),
                    onAddPressed: () {
                      context.push('/food-search/${MealType.dinner.name}');
                    },
                    onRemoveFood: (mealId) {
                      ref
                          .read(diaryNotifierProvider.notifier)
                          .removeFoodFromMeal(mealId);
                    },
                    onFoodTap: (meal, foodItem) =>
                        _showEditSheet(context, ref, meal, foodItem),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                EntryAnimation(
                  delay: const Duration(milliseconds: 600),
                  child: MealSectionImproved(
                    title: 'Lanches',
                    meals: day.getMealsByType(MealType.snack),
                    onAddPressed: () {
                      context.push('/food-search/${MealType.snack.name}');
                    },
                    onRemoveFood: (mealId) {
                      ref
                          .read(diaryNotifierProvider.notifier)
                          .removeFoodFromMeal(mealId);
                    },
                    onFoodTap: (meal, foodItem) =>
                        _showEditSheet(context, ref, meal, foodItem),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Water Section
                EntryAnimation(
                  delay: const Duration(milliseconds: 700),
                  child: WaterTrackerConnected(date: day.date),
                ),
                const SizedBox(height: AppSpacing.md),

                // Quick Weight Log
                EntryAnimation(
                  delay: const Duration(milliseconds: 800),
                  child: QuickWeightLogCard(
                    currentWeight: 72.5, // TODO: Connect to real data
                    startWeight: 75.0,
                    goalWeight: 68.0,
                    onWeightChanged: (newWeight) {
                      // TODO: Save weight
                    },
                    onTapMore: () {
                      context.push('/measurements');
                    },
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Measurements Section (Old - pode remover depois)
                // EntryAnimation(
                //   delay: const Duration(milliseconds: 800),
                //   child: MeasurementsCard(
                //     currentWeight: 72.5,
                //     startWeight: 75.0,
                //     goalWeight: 68.0,
                //     onTap: () {
                //       // Navigate to measurements details
                //     },
                //   ),
                // ),
                const SizedBox(height: AppSpacing.md),

                // Notes Section
                EntryAnimation(
                  delay: const Duration(milliseconds: 900),
                  child: NotesCard(
                    initialNote: day.notes,
                    onSave: (note) {
                      ref
                          .read(diaryNotifierProvider.notifier)
                          .updateNotes(note);
                    },
                  ),
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => Center(child: Text('Erro: $err')),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String actionText,
    VoidCallback onAction,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            actionText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  String _getDateTitle(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) {
      return 'Today!';
    } else if (checkDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (checkDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else {
      // Format: Mon, 12 Oct
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
    }
  }

  void _showEditSheet(
    BuildContext context,
    WidgetRef ref,
    Meal meal,
    FoodItem foodItem,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditQuantitySheet(
        foodName: foodItem.food.name,
        currentQuantity: foodItem.quantity,
        servingSize: foodItem.food.servingSize,
        servingUnit: foodItem.food.servingUnit,
        caloriesPerServing: foodItem.food.calories.value.toInt(),
        onSave: (newQuantity) {
          ref
              .read(diaryNotifierProvider.notifier)
              .updateFoodQuantity(meal.id, newQuantity);
        },
        onDelete: () {
          ref.read(diaryNotifierProvider.notifier).removeFoodFromMeal(meal.id);
        },
      ),
    );
  }
}
