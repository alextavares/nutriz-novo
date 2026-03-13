import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

import '../../../../shared/widgets/animations/entry_animation.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../domain/entities/meal.dart';
import '../providers/diary_providers.dart';

import '../widgets/daily_summary_header_improved.dart';

import '../widgets/meal_section_improved.dart';

import '../widgets/notes_card.dart';
import '../widgets/quick_weight_log_card.dart';

import '../widgets/water_tracker_connected.dart';
import '../widgets/edit_quantity_sheet.dart';
import '../../../profile/presentation/notifiers/profile_notifier.dart';
import 'package:nutriz/core/analytics/analytics_providers.dart';
import 'package:nutriz/core/monetization/meal_log_gate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiaryPage extends ConsumerStatefulWidget {
  final String? quickAddMealType;
  final bool showFirstMealCta;

  const DiaryPage({
    super.key,
    this.quickAddMealType,
    this.showFirstMealCta = false,
  });

  @override
  ConsumerState<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends ConsumerState<DiaryPage> {
  bool _handledQuickAdd = false;
  bool _loggedView = false;
  final Set<String> _dismissedFirstMealCtaDates = {};
  final Set<String> _loggedChallengeBannerDates = {};
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 10000);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeHandleQuickAdd();

    if (!_loggedView) {
      _loggedView = true;
      final s = ref.read(diaryNotifierProvider);
      ref.read(analyticsServiceProvider).logEvent('diary_view', {
        'date': s.selectedDate.toIso8601String().split('T').first,
      });
      _checkAndLogD1Retention();
    }
  }

  Future<void> _checkAndLogD1Retention() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasLoggedD1 = prefs.getBool('has_logged_d1') ?? false;
      if (hasLoggedD1) return;

      final firstOpenStr = prefs.getString('first_open_date');
      final todayStr = DateTime.now().toIso8601String().split('T').first;

      if (firstOpenStr == null) {
        await prefs.setString('first_open_date', todayStr);
      } else if (firstOpenStr != todayStr) {
        // Different day from first open means D1 retention
        await prefs.setBool('has_logged_d1', true);
        unawaited(
          ref.read(analyticsServiceProvider).logEvent('d1_retained', {}),
        );
      }
    } catch (_) {
      // Ignore errors silently for analytics
    }
  }

  void _maybeHandleQuickAdd() {
    if (_handledQuickAdd) return;
    final quickAdd = widget.quickAddMealType;
    if (quickAdd == null || quickAdd.isEmpty) return;

    final isValid = MealType.values.any((e) => e.name == quickAdd);
    if (!isValid) return;

    _handledQuickAdd = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final profile = ref.read(profileNotifierProvider);
      final gate = ref.read(mealLogGateProvider);
      final reason = gate.peekBlockReason(profile, DateTime.now());
      if (reason == MealLogBlockReason.challengeUsedToday) {
        ref.read(analyticsServiceProvider).logEvent(
          'challenge_used_today_blocked',
          {'source': 'diary_quick_add'},
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Você já registrou a refeição do desafio hoje. Volte amanhã.',
            ),
            action: SnackBarAction(
              label: 'Premium',
              onPressed: () => context.push('/premium'),
            ),
          ),
        );
        return;
      }
      if (reason == MealLogBlockReason.locked) {
        context.push('/premium');
        return;
      }
      ref.read(analyticsServiceProvider).logEvent('meal_add_tap', {
        'meal_type': quickAdd,
        'source': 'quick_add',
      });
      context.push('/food-search/$quickAdd?tab=search&focus=1');
    });
  }

  String _suggestFirstMealType() {
    final hour = DateTime.now().hour;
    if (hour < 11) return MealType.breakfast.name;
    if (hour < 16) return MealType.lunch.name;
    if (hour < 21) return MealType.dinner.name;
    return MealType.snack.name;
  }

  void _onMealAddTap(MealType mealType) {
    final profile = ref.read(profileNotifierProvider);
    final gate = ref.read(mealLogGateProvider);
    final reason = gate.peekBlockReason(profile, DateTime.now());
    if (reason == MealLogBlockReason.challengeUsedToday) {
      ref.read(analyticsServiceProvider).logEvent(
        'challenge_used_today_blocked',
        {'source': 'diary_add_button'},
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Você já registrou a refeição do desafio hoje. Volte amanhã.',
          ),
          action: SnackBarAction(
            label: 'Premium',
            onPressed: () => context.push('/premium'),
          ),
        ),
      );
      return;
    }
    if (reason == MealLogBlockReason.locked) {
      context.push('/premium');
      return;
    }
    ref.read(analyticsServiceProvider).logEvent('meal_add_tap', {
      'meal_type': mealType.name,
      'source': 'manual',
    });
    context.push('/food-search/${mealType.name}?tab=search&focus=1');
  }

  Widget _buildFirstMealCta({
    required bool show,
    required String title,
    required String subtitle,
    required String dateKey,
  }) {
    if (!show) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    final mealType = _suggestFirstMealType();
                    final profile = ref.read(profileNotifierProvider);
                    final gate = ref.read(mealLogGateProvider);
                    final reason = gate.peekBlockReason(
                      profile,
                      DateTime.now(),
                    );
                    if (reason == MealLogBlockReason.challengeUsedToday) {
                      ref.read(analyticsServiceProvider).logEvent(
                        'challenge_used_today_blocked',
                        {'source': 'diary_first_meal_cta'},
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Você já registrou a refeição do desafio hoje. Volte amanhã.',
                          ),
                          action: SnackBarAction(
                            label: 'Premium',
                            onPressed: () => context.push('/premium'),
                          ),
                        ),
                      );
                      return;
                    }
                    if (reason == MealLogBlockReason.locked) {
                      context.push('/premium');
                      return;
                    }
                    ref
                        .read(analyticsServiceProvider)
                        .logEvent('first_meal_cta_tap', {
                          'meal_type': mealType,
                          'source': 'diary_empty_day',
                          'date': dateKey,
                        });
                    context.push('/food-search/$mealType?tab=search&focus=1');
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Adicionar alimento'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              TextButton(
                onPressed: () {
                  ref.read(analyticsServiceProvider).logEvent(
                    'first_meal_cta_dismiss',
                    {'source': 'diary_empty_day', 'date': dateKey},
                  );
                  setState(() => _dismissedFirstMealCtaDates.add(dateKey));
                },
                child: Text(
                  'Agora não',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary.withValues(alpha: 0.65),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFirstMealCtaCollapsed({
    required bool show,
    required String dateKey,
  }) {
    if (!show) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () {
          final mealType = _suggestFirstMealType();
          final profile = ref.read(profileNotifierProvider);
          final gate = ref.read(mealLogGateProvider);
          final reason = gate.peekBlockReason(profile, DateTime.now());
          if (reason == MealLogBlockReason.challengeUsedToday) {
            ref.read(analyticsServiceProvider).logEvent(
              'challenge_used_today_blocked',
              {'source': 'diary_first_meal_collapsed'},
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Você já registrou a refeição do desafio hoje. Volte amanhã.',
                ),
                action: SnackBarAction(
                  label: 'Premium',
                  onPressed: () => context.push('/premium'),
                ),
              ),
            );
            return;
          }
          if (reason == MealLogBlockReason.locked) {
            context.push('/premium');
            return;
          }
          ref.read(analyticsServiceProvider).logEvent(
            'first_meal_cta_reopen_tap',
            {
              'meal_type': mealType,
              'source': 'diary_empty_day',
              'date': dateKey,
            },
          );
          context.push('/food-search/$mealType?tab=search&focus=1');
        },
        icon: Icon(
          Icons.add_circle_outline_rounded,
          size: 18,
          color: AppColors.textPrimary.withValues(alpha: 0.55),
        ),
        label: Text(
          'Registrar refeição',
          style: TextStyle(
            color: AppColors.textPrimary.withValues(alpha: 0.55),
            fontWeight: FontWeight.w900,
            fontSize: 13,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  void _onMealRemoveTap(MealType mealType, String mealId) {
    final profile = ref.read(profileNotifierProvider);
    final gate = ref.read(mealLogGateProvider);
    if (gate.isReadOnlyLocked(profile)) {
      context.push('/premium');
      return;
    }
    ref.read(analyticsServiceProvider).logEvent('meal_item_removed', {
      'meal_type': mealType.name,
      'source': 'swipe',
      'meal_id': mealId,
    });
    ref.read(diaryNotifierProvider.notifier).removeFoodFromMeal(mealId);
  }

  @override
  Widget build(BuildContext context) {
    final diaryState = ref.watch(diaryNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          final today = DateTime.now();
          final diff = index - 10000;
          final newDate = today.add(Duration(days: diff));
          ref.read(diaryNotifierProvider.notifier).changeDate(newDate);
          ref.read(analyticsServiceProvider).logEvent('date_changed', {
            'date': newDate.toIso8601String().split('T').first,
          });
        },
        itemBuilder: (context, index) {
          return diaryState.diaryDay.when(
            data: (day) {
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final dayDate = DateTime(
                day.date.year,
                day.date.month,
                day.date.day,
              );
              final isFuture = dayDate.isAfter(today);
              final dateKey = dayDate.toIso8601String().split('T').first;
              final isToday = dayDate == today;

              final isEmptyDay = day.totalCalories.isZero;
              final canShowEmptyDayCta =
                  !isFuture &&
                  isEmptyDay &&
                  (widget.quickAddMealType == null ||
                      widget.quickAddMealType!.isEmpty);
              final dismissedForDay = _dismissedFirstMealCtaDates.contains(
                dateKey,
              );
              final showFirstMealCta = canShowEmptyDayCta && !dismissedForDay;
              final showCollapsedCta = canShowEmptyDayCta && dismissedForDay;
              final useCompactChallengeBanner = canShowEmptyDayCta;
              final profile = ref.watch(profileNotifierProvider);
              final gate = ref.watch(mealLogGateProvider);
              final isReadOnlyLocked = gate.isReadOnlyLocked(profile);
              final startedAt = profile.challengeStartedAt;
              final challengeDaysSinceStart = startedAt == null
                  ? null
                  : DateTime(today.year, today.month, today.day)
                        .difference(
                          DateTime(
                            startedAt.year,
                            startedAt.month,
                            startedAt.day,
                          ),
                        )
                        .inDays;
              final challengeActive =
                  startedAt != null && (challengeDaysSinceStart ?? 99) <= 2;
              final challengeDayIndex = challengeActive
                  ? (challengeDaysSinceStart! + 1).clamp(1, 3)
                  : null;
              final lastMealAt = profile.challengeLastMealAt;
              final usedChallengeToday =
                  lastMealAt != null &&
                  DateTime(today.year, today.month, today.day) ==
                      DateTime(
                        lastMealAt.year,
                        lastMealAt.month,
                        lastMealAt.day,
                      );
              final remainingProtein =
                  (profile.proteinGrams - day.totalMacros.protein)
                      .round()
                      .clamp(0, 9999);

              if (isToday &&
                  challengeActive &&
                  !_loggedChallengeBannerDates.contains(dateKey)) {
                _loggedChallengeBannerDates.add(dateKey);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  ref
                      .read(analyticsServiceProvider)
                      .logEvent('challenge_banner_view', {
                        'day': challengeDayIndex,
                        'meals_remaining': profile.challengeMealsRemaining,
                        'used_today': usedChallengeToday,
                        'remaining_protein_g': remainingProtein,
                      });
                });
              }

              return ListView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 120,
                ),
                children: [
                  // Full-bleed gradient header
                  DailySummaryHeaderImproved(
                    diaryDay: day,
                    calorieGoal: ref
                        .watch(profileNotifierProvider)
                        .calculatedCalories,
                    onDetailsTap: () =>
                        context.push('/nutrition-detail', extra: day),
                    onPreviousDay: () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                    onNextDay: () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                    dateLabel: _getFormattedDateHeader(dayDate),
                    profileIcon: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      icon: const Icon(
                        Icons.account_circle_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => context.go('/profile'),
                    ),
                  ),

                  // Content below the gradient
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.md),
                        if (isToday &&
                            challengeActive &&
                            challengeDayIndex != null &&
                            !useCompactChallengeBanner) ...[
                          const SizedBox(height: AppSpacing.sm),
                          _ChallengeBanner(
                            dayIndex: challengeDayIndex,
                            mealsRemaining: profile.challengeMealsRemaining,
                            usedToday: usedChallengeToday,
                            remainingProteinGrams: remainingProtein,
                            compact: false,
                            onLogMealTap: () {
                              ref
                                  .read(analyticsServiceProvider)
                                  .logEvent('challenge_banner_log_meal_tap', {
                                    'day': challengeDayIndex,
                                    'used_today': usedChallengeToday,
                                  });
                              if (usedChallengeToday) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Você já registrou a refeição do desafio hoje. Volte amanhã.',
                                    ),
                                    action: SnackBarAction(
                                      label: 'Premium',
                                      onPressed: () => context.push('/premium'),
                                    ),
                                  ),
                                );
                                return;
                              }
                              final mealType = _suggestFirstMealType();
                              context.push(
                                '/food-search/$mealType?tab=search&focus=1',
                              );
                            },
                            onTipsTap: () {
                              ref.read(analyticsServiceProvider).logEvent(
                                'challenge_banner_tips_tap',
                                {'day': challengeDayIndex},
                              );
                              _showChallengeTipsSheet(
                                context,
                                remainingProteinGrams: remainingProtein,
                              );
                            },
                            onPremiumTap: () => context.push('/premium'),
                          ),
                        ] else if (isReadOnlyLocked) ...[
                          const SizedBox(height: AppSpacing.sm),
                          _ReadOnlyBanner(
                            onCtaTap: () => context.push('/premium'),
                          ),
                        ],
                        if (showFirstMealCta) ...[
                          _buildFirstMealCta(
                            show: true,
                            title: isToday
                                ? 'Comece pelo que você já comeu hoje'
                                : 'Registre uma refeição neste dia',
                            subtitle: isToday
                                ? 'Registre uma refeição e veja o que ainda falta no seu dia.'
                                : 'Adicione uma refeição para atualizar calorias, proteína e restantes.',
                            dateKey: dateKey,
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ] else if (showCollapsedCta) ...[
                          const SizedBox(height: AppSpacing.xs),
                          _buildFirstMealCtaCollapsed(
                            show: true,
                            dateKey: dateKey,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                        if (isToday &&
                            challengeActive &&
                            challengeDayIndex != null &&
                            useCompactChallengeBanner) ...[
                          _ChallengeBanner(
                            dayIndex: challengeDayIndex,
                            mealsRemaining: profile.challengeMealsRemaining,
                            usedToday: usedChallengeToday,
                            remainingProteinGrams: remainingProtein,
                            compact: true,
                            onLogMealTap: () {
                              ref
                                  .read(analyticsServiceProvider)
                                  .logEvent('challenge_banner_log_meal_tap', {
                                    'day': challengeDayIndex,
                                    'used_today': usedChallengeToday,
                                    'compact': true,
                                  });
                              if (usedChallengeToday) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Você já registrou a refeição do desafio hoje. Volte amanhã.',
                                    ),
                                    action: SnackBarAction(
                                      label: 'Premium',
                                      onPressed: () => context.push('/premium'),
                                    ),
                                  ),
                                );
                                return;
                              }
                              final mealType = _suggestFirstMealType();
                              context.push(
                                '/food-search/$mealType?tab=search&focus=1',
                              );
                            },
                            onTipsTap: () {
                              ref.read(analyticsServiceProvider).logEvent(
                                'challenge_banner_tips_tap',
                                {'day': challengeDayIndex, 'compact': true},
                              );
                              _showChallengeTipsSheet(
                                context,
                                remainingProteinGrams: remainingProtein,
                              );
                            },
                            onPremiumTap: () => context.push('/premium'),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],

                        // Nutrition Section Header
                        EntryAnimation(
                          delay: const Duration(milliseconds: 200),
                          child: SectionHeader(
                            title: 'Nutrição',
                            actionLabel: 'Ver mais',
                            onAction: () =>
                                context.push('/nutrition-detail', extra: day),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // Meals
                        EntryAnimation(
                          delay: const Duration(milliseconds: 300),
                          child: MealSectionImproved(
                            mealType: MealType.breakfast,
                            title: 'Café da Manhã',
                            meals: day.getMealsByType(MealType.breakfast),
                            onAddPressed: () =>
                                _onMealAddTap(MealType.breakfast),
                            onRemoveFood: (mealId) {
                              _onMealRemoveTap(MealType.breakfast, mealId);
                            },
                            onFoodTap: (meal, foodItem) =>
                                _showEditSheet(context, ref, meal, foodItem),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        EntryAnimation(
                          delay: const Duration(milliseconds: 400),
                          child: MealSectionImproved(
                            mealType: MealType.lunch,
                            title: 'Almoço',
                            meals: day.getMealsByType(MealType.lunch),
                            onAddPressed: () => _onMealAddTap(MealType.lunch),
                            onRemoveFood: (mealId) {
                              _onMealRemoveTap(MealType.lunch, mealId);
                            },
                            onFoodTap: (meal, foodItem) =>
                                _showEditSheet(context, ref, meal, foodItem),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        EntryAnimation(
                          delay: const Duration(milliseconds: 500),
                          child: MealSectionImproved(
                            mealType: MealType.dinner,
                            title: 'Jantar',
                            meals: day.getMealsByType(MealType.dinner),
                            onAddPressed: () => _onMealAddTap(MealType.dinner),
                            onRemoveFood: (mealId) {
                              _onMealRemoveTap(MealType.dinner, mealId);
                            },
                            onFoodTap: (meal, foodItem) =>
                                _showEditSheet(context, ref, meal, foodItem),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        EntryAnimation(
                          delay: const Duration(milliseconds: 600),
                          child: MealSectionImproved(
                            mealType: MealType.snack,
                            title: 'Lanches',
                            meals: day.getMealsByType(MealType.snack),
                            onAddPressed: () => _onMealAddTap(MealType.snack),
                            onRemoveFood: (mealId) {
                              _onMealRemoveTap(MealType.snack, mealId);
                            },
                            onFoodTap: (meal, foodItem) =>
                                _showEditSheet(context, ref, meal, foodItem),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Water Section
                        EntryAnimation(
                          delay: const Duration(milliseconds: 680),
                          child: const SectionHeader(title: 'Água'),
                        ),
                        EntryAnimation(
                          delay: const Duration(milliseconds: 700),
                          child: WaterTrackerConnected(date: day.date),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Quick Weight Log
                        EntryAnimation(
                          delay: const Duration(milliseconds: 780),
                          child: SectionHeader(
                            title: 'Medidas',
                            actionLabel: 'Ver mais',
                            onAction: () => context.push('/measurements'),
                          ),
                        ),
                        EntryAnimation(
                          delay: const Duration(milliseconds: 800),
                          child: QuickWeightLogCard(
                            currentWeight: profile.currentWeight,
                            startWeight: profile.startWeight,
                            goalWeight: profile.targetWeight,
                            onWeightChanged: (newWeight) {
                              ref
                                  .read(profileNotifierProvider.notifier)
                                  .updateWeight(newWeight);
                              ref.read(analyticsServiceProvider).logEvent(
                                'weight_logged',
                                {
                                  'source': 'diary_quick_log',
                                  'weight': newWeight,
                                },
                              );
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
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, st) => _DiaryErrorState(
              onRetry: () => ref
                  .read(diaryNotifierProvider.notifier)
                  .loadDate(diaryState.selectedDate),
            ),
          );
        },
      ),
    );
  }

  String _getDateTitle(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) {
      return 'Hoje';
    } else if (checkDate == today.subtract(const Duration(days: 1))) {
      return 'Ontem';
    } else if (checkDate == today.add(const Duration(days: 1))) {
      return 'Amanhã';
    } else {
      // Formato: Seg, 12 out
      final weekdays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
      final months = [
        'jan',
        'fev',
        'mar',
        'abr',
        'mai',
        'jun',
        'jul',
        'ago',
        'set',
        'out',
        'nov',
        'dez',
      ];
      return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
    }
  }

  String _getFormattedDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);

    final months = [
      'JAN',
      'FEV',
      'MAR',
      'ABR',
      'MAI',
      'JUN',
      'JUL',
      'AGO',
      'SET',
      'OUT',
      'NOV',
      'DEZ',
    ];
    final monthStr = months[date.month - 1];
    final dateSuffix = '${date.day} $monthStr';

    if (checkDate == today) {
      return 'HOJE, $dateSuffix';
    } else if (checkDate == today.subtract(const Duration(days: 1))) {
      return 'ONTEM, $dateSuffix';
    } else if (checkDate == today.add(const Duration(days: 1))) {
      return 'AMANHÃ, $dateSuffix';
    } else {
      final weekdays = ['SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SÁB', 'DOM'];
      final weekdayStr = weekdays[date.weekday - 1];
      return '$weekdayStr, $dateSuffix';
    }
  }

  int _weekOfYear(DateTime date) {
    final wday = (date.weekday + 6) % 7; // Monday=0..Sunday=6
    final thursday = date.add(Duration(days: 3 - wday));

    final firstThursday = DateTime(thursday.year, 1, 4);
    final firstWday = (firstThursday.weekday + 6) % 7;
    final firstWeekThursday = firstThursday.add(Duration(days: 3 - firstWday));

    return 1 + (thursday.difference(firstWeekThursday).inDays / 7).floor();
  }

  void _showEditSheet(
    BuildContext context,
    WidgetRef ref,
    Meal meal,
    FoodItem foodItem,
  ) {
    final profile = ref.read(profileNotifierProvider);
    final gate = ref.read(mealLogGateProvider);
    if (gate.isReadOnlyLocked(profile)) {
      context.push('/premium');
      return;
    }
    ref.read(analyticsServiceProvider).logEvent('portion_edit_view', {
      'meal_type': meal.type.name,
      'source': 'diary',
      'meal_id': meal.id,
    });
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
        carbsPerServing: foodItem.food.macros.carbs,
        proteinPerServing: foodItem.food.macros.protein,
        fatPerServing: foodItem.food.macros.fat,
        onSave: (newQuantity) {
          final p = ref.read(profileNotifierProvider);
          final g = ref.read(mealLogGateProvider);
          if (g.isReadOnlyLocked(p)) {
            Navigator.of(context).pop();
            context.push('/premium');
            return;
          }
          ref
              .read(diaryNotifierProvider.notifier)
              .updateFoodQuantity(meal.id, newQuantity);
        },
        onDelete: () {
          final p = ref.read(profileNotifierProvider);
          final g = ref.read(mealLogGateProvider);
          if (g.isReadOnlyLocked(p)) {
            Navigator.of(context).pop();
            context.push('/premium');
            return;
          }
          ref.read(analyticsServiceProvider).logEvent('meal_item_removed', {
            'meal_type': meal.type.name,
            'source': 'sheet',
            'meal_id': meal.id,
          });
          ref.read(diaryNotifierProvider.notifier).removeFoodFromMeal(meal.id);
        },
      ),
    );
  }

  void _showChallengeTipsSheet(
    BuildContext context, {
    required int remainingProteinGrams,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dica do desafio (proteína)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Faltam ~${remainingProteinGrams.clamp(0, 9999)}g para a sua meta de proteína hoje.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const _ChallengeTipRow(
                title: 'Opções rápidas',
                subtitle:
                    'Ovos • iogurte grego • frango/peixe • cottage • whey.',
              ),
              const SizedBox(height: AppSpacing.sm),
              const _ChallengeTipRow(
                title: 'Regra simples',
                subtitle: 'Inclua 1 porção de proteína em cada refeição.',
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    context.push('/premium');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.premium,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  child: const Text('Desbloquear IA por foto'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Fechar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReadOnlyBanner extends StatelessWidget {
  final VoidCallback onCtaTap;

  const _ReadOnlyBanner({required this.onCtaTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const title = 'Modo leitura';
    const subtitle =
        'Para registrar mais refeições e usar IA por foto, desbloqueie o Premium.';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.premium.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.premium,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: onCtaTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.premium,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    child: const Text('Desbloquear'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeBanner extends StatelessWidget {
  final int dayIndex;
  final int mealsRemaining;
  final bool usedToday;
  final int remainingProteinGrams;
  final bool compact;
  final VoidCallback onLogMealTap;
  final VoidCallback onTipsTap;
  final VoidCallback onPremiumTap;

  const _ChallengeBanner({
    required this.dayIndex,
    required this.mealsRemaining,
    required this.usedToday,
    required this.remainingProteinGrams,
    this.compact = false,
    required this.onLogMealTap,
    required this.onTipsTap,
    required this.onPremiumTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (dayIndex / 3).clamp(0.0, 1.0);
    final title = mealsRemaining <= 0 ? 'Desafio concluído' : 'Desafio 3 dias';
    final subtitle = mealsRemaining <= 0
        ? 'Você completou os 3 dias. Desbloqueie o Premium para continuar sem limites.'
        : usedToday
        ? 'Você já registrou a refeição de hoje. Volte amanhã para continuar.'
        : 'Hoje: registre 1 refeição e foque em proteína (faltam ~${remainingProteinGrams.clamp(0, 9999)}g).';

    return Container(
      padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.premium.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emoji_events_outlined,
                  color: AppColors.premium,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Dia $dayIndex de 3 • $mealsRemaining restante(s)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (compact)
                TextButton(onPressed: onTipsTap, child: const Text('Dicas')),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.black.withValues(alpha: 0.06),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.premium,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (!compact) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: mealsRemaining <= 0
                        ? onPremiumTap
                        : onLogMealTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    child: Text(
                      mealsRemaining <= 0
                          ? 'Desbloquear'
                          : usedToday
                          ? 'Voltar amanhã'
                          : 'Registrar refeição de hoje',
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                TextButton(
                  onPressed: onTipsTap,
                  child: Text(
                    'Dicas',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary.withValues(alpha: 0.65),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onPremiumTap,
                  child: Text(
                    'Premium',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary.withValues(alpha: 0.65),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ChallengeTipRow extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ChallengeTipRow({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiaryErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _DiaryErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                color: AppColors.textSecondary,
                size: 32,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Não foi possível carregar seu diário.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tente novamente. Se continuar, feche e reabra o app.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Tentar novamente'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
