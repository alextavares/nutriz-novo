import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/monetization/promo_offer.dart';
import '../../../premium/presentation/providers/subscription_provider.dart';
import '../../domain/models/diet_meal.dart';
import '../../domain/models/diet_plan.dart';
import '../providers/diet_ai_providers.dart';
import '../providers/diet_providers.dart';

enum DietViewMode { weekly, daily }

class DietPlanScreen extends ConsumerStatefulWidget {
  const DietPlanScreen({super.key});

  @override
  ConsumerState<DietPlanScreen> createState() => _DietPlanScreenState();
}

class _DietPlanScreenState extends ConsumerState<DietPlanScreen> {
  DietViewMode _mode = DietViewMode.weekly;

  @override
  Widget build(BuildContext context) {
    final isPro = ref.watch(subscriptionProvider).isPro;
    final weekAsync = ref.watch(dietWeekProvider);
    final catalogAsync = ref.watch(dietCatalogProvider);
    final selectedDay = ref.watch(dietSelectedDayProvider);
    final isReplacingDayAi = ref.watch(dietReplaceInProgressProvider);
    final replacingMeals = ref.watch(dietReplaceMealInProgressProvider);
    final isBusyAi = isReplacingDayAi || replacingMeals.isNotEmpty;

    final today = DateUtils.dateOnly(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Plano'),
        actions: [
          IconButton(
            tooltip: 'Lista de compras',
            onPressed: () => context.push('/diet/shopping-list'),
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
          if (isPro)
            TextButton.icon(
              onPressed: isBusyAi
                  ? null
                  : () async {
                      await ref.read(dietPlanActionsProvider).replaceWeek();
                    },
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Trocar semana'),
            ),
          IconButton(
            tooltip: 'Copiar',
            onPressed: weekAsync.hasValue
                ? () => _copyPlan(context, weekAsync.value!, selectedDay)
                : null,
            icon: const Icon(Icons.ios_share),
          ),
        ],
      ),
      body: weekAsync.when(
        data: (week) {
          final catalog = catalogAsync.asData?.value ?? const <DietMeal>[];
          final byId = {for (final m in catalog) m.id: m};

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: _ModeToggle(
                  mode: _mode,
                  onChanged: (mode) => setState(() => _mode = mode),
                ),
              ),
              Expanded(
                child: _mode == DietViewMode.weekly
                    ? _WeeklyView(
                        week: week,
                        mealsById: byId,
                        isPro: isPro,
                        today: today,
                        onTapLocked: () => _openPaywall(context),
                        onTapDay: (d) => ref
                            .read(dietSelectedDayProvider.notifier)
                            .state = d,
                      )
                    : _DailyView(
                        week: week,
                        selectedDay: selectedDay,
                        mealsById: byId,
                        isPro: isPro,
                        today: today,
                        isReplacingDayAi: isReplacingDayAi,
                        isBusyAi: isBusyAi,
                        onTapLocked: () => _openPaywall(context),
                        onTogglePin: (d, t) =>
                            ref.read(dietPlanActionsProvider).toggleMealPin(d, t),
                        onSelectDay: (d) => ref
                            .read(dietSelectedDayProvider.notifier)
                            .state = d,
                        onReplaceDay: () async {
                          if (!isPro) {
                            _openPaywall(context);
                            return;
                          }
                          try {
                            await ref
                                .read(dietAiActionsProvider)
                                .replaceDayAi(selectedDay);
                          } catch (_) {
                            await ref
                                .read(dietPlanActionsProvider)
                                .replaceDay(selectedDay);
                          }
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Erro ao carregar plano: $e'),
          ),
        ),
      ),
    );
  }

  void _openPaywall(BuildContext context) {
    ref.read(promoOfferProvider.notifier).ensureActive(
      duration: const Duration(minutes: 10),
      discountPercent: 75,
      source: 'diet_plan_locked',
    );
    context.push('/premium');
  }

  Future<void> _copyPlan(
    BuildContext context,
    DietPlanWeek week,
    DateTime day,
  ) async {
    final d = DateUtils.dateOnly(day);
    final dayPlan = week.days.firstWhere(
      (x) => DateUtils.isSameDay(x.date, d),
      orElse: () => week.days.first,
    );
    final catalog = ref.read(dietCatalogProvider).asData?.value ?? const <DietMeal>[];
    final byId = {for (final m in catalog) m.id: m};

    final lines = <String>[
      'Plano do dia ${d.day}/${d.month}',
      '',
      for (final t in DietMealType.values)
        '${dietMealTypeLabel(t)}: ${byId[dayPlan.mealIdsByType[t]]?.title ?? '—'}',
    ];
    await Clipboard.setData(ClipboardData(text: lines.join('\n')));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plano copiado.')),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final DietViewMode mode;
  final ValueChanged<DietViewMode> onChanged;

  const _ModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<DietViewMode>(
      segments: const [
        ButtonSegment(value: DietViewMode.weekly, label: Text('Plano semanal'), icon: Icon(Icons.calendar_view_week)),
        ButtonSegment(value: DietViewMode.daily, label: Text('Plano diário'), icon: Icon(Icons.today)),
      ],
      selected: {mode},
      onSelectionChanged: (set) => onChanged(set.first),
      showSelectedIcon: false,
    );
  }
}

class _WeeklyView extends StatelessWidget {
  final DietPlanWeek week;
  final Map<String, DietMeal> mealsById;
  final bool isPro;
  final DateTime today;
  final VoidCallback onTapLocked;
  final ValueChanged<DateTime> onTapDay;

  const _WeeklyView({
    required this.week,
    required this.mealsById,
    required this.isPro,
    required this.today,
    required this.onTapLocked,
    required this.onTapDay,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: week.days.length,
      itemBuilder: (context, index) {
        final day = week.days[index];
        final isToday = DateUtils.isSameDay(day.date, today);
        final locked = !isPro && !isToday;
        if (locked) {
          return _LockedDayCard(day: day.date, onTap: onTapLocked);
        }

        final breakfast = mealsById[day.mealIdsByType[DietMealType.breakfast]]?.title ?? '—';
        final lunch = mealsById[day.mealIdsByType[DietMealType.lunch]]?.title ?? '—';
        final dinner = mealsById[day.mealIdsByType[DietMealType.dinner]]?.title ?? '—';
        final snack = mealsById[day.mealIdsByType[DietMealType.snack]]?.title ?? '—';

        return InkWell(
          onTap: () => onTapDay(day.date),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F6FA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _weekdayLabel(day.date),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _MiniMealPill(text: breakfast),
                    _MiniMealPill(text: lunch),
                    _MiniMealPill(text: dinner),
                    _MiniMealPill(text: snack),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _weekdayLabel(DateTime date) {
    const labels = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    final i = date.weekday % 7;
    return '${labels[i]} • ${date.day}/${date.month}';
  }
}

class _LockedDayCard extends StatelessWidget {
  final DateTime day;
  final VoidCallback onTap;

  const _LockedDayCard({required this.day, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '+ Desbloqueie o plano semanal',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const Icon(Icons.lock, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}

class _MiniMealPill extends StatelessWidget {
  final String text;

  const _MiniMealPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _DailyView extends StatelessWidget {
  final DietPlanWeek week;
  final DateTime selectedDay;
  final Map<String, DietMeal> mealsById;
  final bool isPro;
  final DateTime today;
  final bool isReplacingDayAi;
  final bool isBusyAi;
  final VoidCallback onTapLocked;
  final void Function(DateTime day, DietMealType type) onTogglePin;
  final ValueChanged<DateTime> onSelectDay;
  final VoidCallback onReplaceDay;

  const _DailyView({
    required this.week,
    required this.selectedDay,
    required this.mealsById,
    required this.isPro,
    required this.today,
    required this.isReplacingDayAi,
    required this.isBusyAi,
    required this.onTapLocked,
    required this.onTogglePin,
    required this.onSelectDay,
    required this.onReplaceDay,
  });

  @override
  Widget build(BuildContext context) {
    final d = DateUtils.dateOnly(selectedDay);
    final isToday = DateUtils.isSameDay(d, today);
    final locked = !isPro && !isToday;

    final plan = week.days.firstWhere(
      (x) => DateUtils.isSameDay(x.date, d),
      orElse: () => week.days.first,
    );

    final meals = DietMealType.values
        .map((t) => mealsById[plan.mealIdsByType[t]])
        .whereType<DietMeal>()
        .toList(growable: false);

    final totalKcal = meals.fold<int>(0, (acc, m) => acc + m.kcal);
    final p = meals.fold<int>(0, (acc, m) => acc + m.proteinG);
    final c = meals.fold<int>(0, (acc, m) => acc + m.carbsG);
    final f = meals.fold<int>(0, (acc, m) => acc + m.fatG);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _WeekdaySelector(
          weekStart: week.weekStart,
          selectedDay: d,
          onSelect: onSelectDay,
          locked: locked,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                'Plano do dia',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
            TextButton.icon(
              onPressed: (locked || isBusyAi) ? null : onReplaceDay,
              icon: isReplacingDayAi
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Trocar dia (IA)'),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F6FA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MacroChip(icon: Icons.local_fire_department, label: '${totalKcal}kcal'),
              _MacroChip(icon: Icons.fitness_center, label: '${p}g P'),
              _MacroChip(icon: Icons.grain, label: '${c}g C'),
              _MacroChip(icon: Icons.water_drop, label: '${f}g G'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (locked)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
            ),
            child: const Text(
              'Desbloqueie o plano completo da semana no Premium.',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        if (!locked)
          ...DietMealType.values.map((type) {
            final meal = mealsById[plan.mealIdsByType[type]];
            if (meal == null) return const SizedBox.shrink();
            return _MealCard(
              day: d,
              type: type,
              meal: meal,
              canUseAi: isPro,
              isBusyAi: isBusyAi,
              onTapLocked: onTapLocked,
              isPinned: plan.lockedTypes.contains(type),
              onTogglePin: () => onTogglePin(d, type),
            );
          }),
      ],
    );
  }
}

class _WeekdaySelector extends StatelessWidget {
  final DateTime weekStart;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onSelect;
  final bool locked;

  const _WeekdaySelector({
    required this.weekStart,
    required this.selectedDay,
    required this.onSelect,
    required this.locked,
  });

  @override
  Widget build(BuildContext context) {
    const labels = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = DateUtils.dateOnly(weekStart.add(Duration(days: index)));
          final isSelected = DateUtils.isSameDay(day, selectedDay);
          return ChoiceChip(
            label: Text(labels[day.weekday % 7]),
            selected: isSelected,
            onSelected: locked && !isSelected ? null : (_) => onSelect(day),
          );
        },
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MacroChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black54),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
      ],
    );
  }
}

class _MealCard extends ConsumerWidget {
  final DateTime day;
  final DietMealType type;
  final DietMeal meal;
  final bool canUseAi;
  final bool isBusyAi;
  final VoidCallback onTapLocked;
  final bool isPinned;
  final VoidCallback onTogglePin;

  const _MealCard({
    required this.day,
    required this.type,
    required this.meal,
    required this.canUseAi,
    required this.isBusyAi,
    required this.onTapLocked,
    required this.isPinned,
    required this.onTogglePin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = dietReplaceMealKey(day, type);
    final isReplacingMeal =
        ref.watch(dietReplaceMealInProgressProvider).contains(key);

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  dietMealTypeLabel(type),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              IconButton(
                tooltip: isPinned ? 'Desfixar' : 'Fixar refeição',
                onPressed: isReplacingMeal ? null : onTogglePin,
                icon: Icon(
                  isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  color: isPinned ? AppColors.primary : Colors.black54,
                ),
              ),
              TextButton.icon(
                onPressed: (isBusyAi || isReplacingMeal)
                    ? null
                    : () async {
                        if (!canUseAi) {
                          onTapLocked();
                          return;
                        }
                        if (isPinned) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Essa refeição está fixada. Desfixe para trocar.'),
                            ),
                          );
                          return;
                        }
                        final hints = await showModalBottomSheet<Set<DietReplaceHint>>(
                          context: context,
                          showDragHandle: true,
                          builder: (ctx) => _ReplaceMealSheet(type: type),
                        );
                        if (hints == null) return;
                        await ref
                            .read(dietAiActionsProvider)
                            .replaceMealAi(day, type, hints: hints);
                      },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  visualDensity: VisualDensity.compact,
                ),
                icon: isReplacingMeal
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome, size: 18),
                label: Text(isReplacingMeal ? 'Trocando…' : 'Trocar (IA)'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${meal.kcal}kcal • ${meal.proteinG}P ${meal.carbsG}C ${meal.fatG}G',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            meal.title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 10),
          ...meal.ingredients.take(2).map(
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontWeight: FontWeight.w900)),
                  Expanded(child: Text(i)),
                ],
              ),
            ),
          ),
          if (meal.ingredients.length > 2)
            Text(
              '+ ${meal.ingredients.length - 2} itens',
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.6),
                fontWeight: FontWeight.w700,
              ),
            ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                showDragHandle: true,
                isScrollControlled: true,
                builder: (ctx) => _MealDetailsSheet(meal: meal),
              ),
              icon: const Icon(Icons.info_outline_rounded, size: 18),
              label: const Text('Ver detalhes'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MealDetailsSheet extends StatelessWidget {
  final DietMeal meal;

  const _MealDetailsSheet({required this.meal});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                meal.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                '${meal.kcal}kcal • ${meal.proteinG}P ${meal.carbsG}C ${meal.fatG}G',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              const Text('Ingredientes', style: TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              for (final i in meal.ingredients)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontWeight: FontWeight.w900)),
                      Expanded(child: Text(i)),
                    ],
                  ),
                ),
              const SizedBox(height: 14),
              const Text('Como preparar', style: TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              for (final s in meal.steps)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('• $s'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReplaceMealSheet extends StatefulWidget {
  final DietMealType type;

  const _ReplaceMealSheet({required this.type});

  @override
  State<_ReplaceMealSheet> createState() => _ReplaceMealSheetState();
}

class _ReplaceMealSheetState extends State<_ReplaceMealSheet> {
  final Set<DietReplaceHint> _selected = <DietReplaceHint>{};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trocar ${dietMealTypeLabel(widget.type).toLowerCase()}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Escolha preferências para esta troca (opcional).',
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: DietReplaceHint.values.map((hint) {
              final selected = _selected.contains(hint);
              return FilterChip(
                selected: selected,
                label: Text(dietReplaceHintLabel(hint)),
                onSelected: (v) {
                  setState(() {
                    if (v) {
                      _selected.add(hint);
                      if (hint == DietReplaceHint.vegan) {
                        _selected.add(DietReplaceHint.vegetarian);
                      }
                      if (hint == DietReplaceHint.vegetarian) {
                        _selected.remove(DietReplaceHint.vegan);
                      }
                    } else {
                      _selected.remove(hint);
                    }
                  });
                },
              );
            }).toList(growable: false),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).pop(Set<DietReplaceHint>.from(_selected)),
                  child: const Text('Trocar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
