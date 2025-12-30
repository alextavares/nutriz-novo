import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../domain/entities/diary_day.dart';
import '../../domain/entities/meal.dart';
import '../../../profile/presentation/notifiers/profile_notifier.dart';

class NutritionDetailScreen extends ConsumerWidget {
  final DiaryDay diaryDay;

  const NutritionDetailScreen({super.key, required this.diaryDay});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileNotifierProvider);
    final goalCalories = profile.calculatedCalories;
    final consumedCalories = diaryDay.totalCalories.value.toInt();
    final burnedCalories = 0; // TODO: conectar quando existir fonte real
    final remainingCalories = goalCalories - consumedCalories + burnedCalories;
    final macros = diaryDay.totalMacros;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _relativeDateTitle(diaryDay.date),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              _dateSubtitle(diaryDay.date),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              MediaQuery.of(context).padding.bottom + 140,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  const SectionHeader(title: 'Meta do dia'),
                  _GoalCard(
                    consumedCalories: consumedCalories,
                    goalCalories: goalCalories,
                    remainingCalories: remainingCalories,
                    carbs: macros.carbs,
                    protein: macros.protein,
                    fat: macros.fat,
                    carbsGoal: profile.carbsGrams.toDouble(),
                    proteinGoal: profile.proteinGrams.toDouble(),
                    fatGoal: profile.fatGrams.toDouble(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const SectionHeader(title: 'Refeições'),
                  _MealsBreakdownCard(diaryDay: diaryDay),
                  const SizedBox(height: AppSpacing.lg),
                  SectionHeader(
                    title: 'Informações nutricionais',
                    actionLabel: 'Desbloquear Pro',
                    onAction: () => context.push('/premium'),
                  ),
                  _ProLockedCard(
                    title: 'Fatos nutricionais',
                    subtitle: 'Vitaminas, minerais, fibras e outros detalhes.',
                    onTap: () => context.push('/premium'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const SectionHeader(title: 'Vitaminas e minerais'),
                  _ProLockedListCard(
                    onTap: () => context.push('/premium'),
                    groups: const [
                      _ProGroup(
                        title: 'Vitaminas',
                        items: [
                          'Vitamina A',
                          'Vitamina B1 (Tiamina)',
                          'Vitamina B12',
                          'Vitamina C',
                          'Vitamina D',
                          'Vitamina K',
                        ],
                      ),
                      _ProGroup(
                        title: 'Minerais',
                        items: [
                          'Cálcio',
                          'Ferro',
                          'Magnésio',
                          'Potássio',
                          'Sódio',
                          'Zinco',
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: _PrimaryButton(
            label: 'Adicionar alimento',
            onPressed: () => _showMealPicker(context),
          ),
        ),
      ),
    );
  }

  void _showMealPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Adicionar em…',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final type in MealType.values)
                _MealPickerTile(
                  type: type,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.push('/food-search/${type.name}?tab=search&focus=1');
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  static String _relativeDateTitle(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = d.difference(today).inDays;
    if (diff == 0) return 'Hoje';
    if (diff == -1) return 'Ontem';
    if (diff == 1) return 'Amanhã';

    const weekdays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return weekdays[(d.weekday - 1).clamp(0, 6)];
  }

  static String _dateSubtitle(DateTime date) {
    const months = [
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
    return '${date.day} ${months[(date.month - 1).clamp(0, 11)]}';
  }

  static _MacroGoals _estimateMacroGoals(int calories) {
    final carbs = (calories * 0.40) / 4;
    final protein = (calories * 0.30) / 4;
    final fat = (calories * 0.30) / 9;
    return _MacroGoals(carbs: carbs, protein: protein, fat: fat);
  }
}

class _MacroGoals {
  final double carbs;
  final double protein;
  final double fat;

  const _MacroGoals({
    required this.carbs,
    required this.protein,
    required this.fat,
  });
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Card({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _GoalCard extends StatelessWidget {
  final int consumedCalories;
  final int goalCalories;
  final int remainingCalories;
  final double carbs;
  final double protein;
  final double fat;
  final double carbsGoal;
  final double proteinGoal;
  final double fatGoal;

  const _GoalCard({
    required this.consumedCalories,
    required this.goalCalories,
    required this.remainingCalories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.carbsGoal,
    required this.proteinGoal,
    required this.fatGoal,
  });

  @override
  Widget build(BuildContext context) {
    final isOver = remainingCalories < 0;
    final remainingValue = isOver ? remainingCalories.abs() : remainingCalories;

    return _Card(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOver ? 'Excedido' : 'Restante',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isOver ? AppColors.error : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$remainingValue',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color:
                                isOver ? AppColors.error : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            'kcal',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _MiniStat(label: 'Consumido', value: consumedCalories),
              const SizedBox(width: 14),
              _MiniStat(label: 'Meta', value: goalCalories),
            ],
          ),
          const SizedBox(height: 16),
          _SlimProgressRow(
            label: 'Calorias',
            value: consumedCalories.toDouble(),
            goal: goalCalories.toDouble(),
            unit: 'kcal',
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          _SlimProgressRow(
            label: 'Carboidratos',
            value: carbs,
            goal: carbsGoal,
            unit: 'g',
            color: AppColors.carbs,
          ),
          const SizedBox(height: 12),
          _SlimProgressRow(
            label: 'Proteínas',
            value: protein,
            goal: proteinGoal,
            unit: 'g',
            color: AppColors.protein,
          ),
          const SizedBox(height: 12),
          _SlimProgressRow(
            label: 'Gorduras',
            value: fat,
            goal: fatGoal,
            unit: 'g',
            color: AppColors.fat,
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$value kcal',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _SlimProgressRow extends StatelessWidget {
  final String label;
  final double value;
  final double goal;
  final String unit;
  final Color color;

  const _SlimProgressRow({
    required this.label,
    required this.value,
    required this.goal,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final safeGoal = goal <= 0 ? 1 : goal;
    final progress = (value / safeGoal).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              '${value.toStringAsFixed(0)} / ${goal.toStringAsFixed(0)} $unit',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _MealsBreakdownCard extends StatefulWidget {
  final DiaryDay diaryDay;

  const _MealsBreakdownCard({required this.diaryDay});

  @override
  State<_MealsBreakdownCard> createState() => _MealsBreakdownCardState();
}

class _MealsBreakdownCardState extends State<_MealsBreakdownCard> {
  MealType _selected = MealType.breakfast;

  @override
  Widget build(BuildContext context) {
    final meals = widget.diaryDay.getMealsByType(_selected);
    final calories = meals.fold<double>(0, (sum, m) => sum + m.totalCalories.value);
    final macros = meals.fold(
      const _MacroGoals(carbs: 0, protein: 0, fat: 0),
      (sum, m) => _MacroGoals(
        carbs: sum.carbs + m.totalMacros.carbs,
        protein: sum.protein + m.totalMacros.protein,
        fat: sum.fat + m.totalMacros.fat,
      ),
    );

    return _Card(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final type in MealType.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(_mealLabel(type)),
                      selected: type == _selected,
                      onSelected: (_) => setState(() => _selected = type),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: type == _selected
                            ? AppColors.primaryDark
                            : AppColors.textSecondary,
                      ),
                      avatar: Icon(
                        _mealIcon(type),
                        size: 18,
                        color: type == _selected
                            ? AppColors.primary
                            : AppColors.textHint,
                      ),
                      side: BorderSide(color: AppColors.border),
                      backgroundColor: AppColors.surfaceVariant,
                      selectedColor: AppColors.primaryLight.withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _FactRow(label: 'Calorias', value: calories, unit: 'kcal'),
          const Divider(height: 22),
          _FactRow(label: 'Carboidratos', value: macros.carbs, unit: 'g'),
          const Divider(height: 22),
          _FactRow(label: 'Proteínas', value: macros.protein, unit: 'g'),
          const Divider(height: 22),
          _FactRow(label: 'Gorduras', value: macros.fat, unit: 'g'),
        ],
      ),
    );
  }

  static String _mealLabel(MealType type) {
    return switch (type) {
      MealType.breakfast => 'Café',
      MealType.lunch => 'Almoço',
      MealType.dinner => 'Jantar',
      MealType.snack => 'Lanches',
    };
  }

  static IconData _mealIcon(MealType type) {
    return switch (type) {
      MealType.breakfast => Icons.wb_sunny_rounded,
      MealType.lunch => Icons.restaurant_rounded,
      MealType.dinner => Icons.nights_stay_rounded,
      MealType.snack => Icons.local_cafe_rounded,
    };
  }
}

class _FactRow extends StatelessWidget {
  final String label;
  final double value;
  final String unit;

  const _FactRow({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          '${value.toStringAsFixed(0)} $unit',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ProLockedCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProLockedCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
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
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const _ProPill(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProGroup {
  final String title;
  final List<String> items;

  const _ProGroup({required this.title, required this.items});
}

class _ProLockedListCard extends StatelessWidget {
  final List<_ProGroup> groups;
  final VoidCallback onTap;

  const _ProLockedListCard({
    required this.groups,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final group in groups) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          group.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const _ProPill(compact: true),
                    ],
                  ),
                ),
                for (final item in group.items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.premium.withValues(alpha: 0.45),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Divider(height: 18),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProPill extends StatelessWidget {
  final bool compact;

  const _ProPill({this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.premium.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.premium.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_rounded,
            size: compact ? 14 : 16,
            color: AppColors.textPrimary.withValues(alpha: 0.85),
          ),
          const SizedBox(width: 6),
          Text(
            'Pro',
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
        ),
        child: Text(label),
      ),
    );
  }
}

class _MealPickerTile extends StatelessWidget {
  final MealType type;
  final VoidCallback onTap;

  const _MealPickerTile({required this.type, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final label = switch (type) {
      MealType.breakfast => 'Café da manhã',
      MealType.lunch => 'Almoço',
      MealType.dinner => 'Jantar',
      MealType.snack => 'Lanches',
    };
    final icon = switch (type) {
      MealType.breakfast => Icons.wb_sunny_rounded,
      MealType.lunch => Icons.restaurant_rounded,
      MealType.dinner => Icons.nights_stay_rounded,
      MealType.snack => Icons.local_cafe_rounded,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: AppColors.surfaceVariant,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryDark),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
