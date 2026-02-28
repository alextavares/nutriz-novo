import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/dialogs/confirm_dialog.dart';
import '../../domain/models/user_profile.dart';
import '../notifiers/profile_notifier.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _comingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label em breve.')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(profileNotifierProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Perfil',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _comingSoon(context, 'Ajuda'),
            icon: Icon(
              Icons.help_outline_rounded,
              color: AppColors.textPrimary.withValues(alpha: 0.55),
            ),
            tooltip: 'Ajuda',
          ),
          IconButton(
            onPressed: () => _comingSoon(context, 'Configurações'),
            icon: Icon(
              Icons.settings_outlined,
              color: AppColors.textPrimary.withValues(alpha: 0.55),
            ),
            tooltip: 'Configurações',
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          bottomPadding + 160,
        ),
        children: [
          _ProfileHeaderCard(
            profile: profile,
            onEdit: () => _comingSoon(context, 'Editar perfil'),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(
            title: 'Meu progresso',
            actionLabel: 'Detalhes',
            onAction: () => _comingSoon(context, 'Análise'),
          ),
          _ProgressCard(profile: profile),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(
            title: 'Minhas metas',
            actionLabel: 'Editar',
            onAction: () => context.push('/onboarding/edit'),
          ),
          _GoalsCard(profile: profile),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Configurações'),
          _SettingsCardList(
            onTap: (label) {
              if (label == 'Refazer personalização') {
                showDialog<void>(
                  context: context,
                  builder: (_) => ConfirmDialog(
                    title: 'Refazer personalização?',
                    message:
                        'Você vai responder as perguntas novamente para recalcular suas metas. Seus registros do diário não serão apagados.',
                    confirmLabel: 'Refazer agora',
                    onConfirm: () {
                      Navigator.of(context).pop();
                      context.go('/onboarding');
                    },
                  ),
                );
                return;
              }
              _comingSoon(context, label);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          const _InfoCard(
            icon: Icons.health_and_safety_rounded,
            title: 'Rastreamento automático',
            subtitle:
                'Em breve: conecte apps de saúde para registrar atividades automaticamente.',
            accent: AppColors.accent,
          ),
        ],
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onEdit;

  const _ProfileHeaderCard({required this.profile, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final age = _calculateAge(profile.birthDate);
    final goalLabel = _mainGoalLabel(profile.mainGoal);
    final dietLabel = _dietLabel(profile.dietaryPreference);
    final activityLabel = _activityLabel(profile.activityLevel);

    return _Card(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary.withValues(alpha: 0.16),
                child: const Text(
                  'A',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            'Alexandre Tavares',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: onEdit,
                          icon: Icon(
                            Icons.edit_rounded,
                            color: AppColors.textPrimary.withValues(
                              alpha: 0.55,
                            ),
                          ),
                          tooltip: 'Editar',
                        ),
                      ],
                    ),
                    Text(
                      '$age anos • $goalLabel',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _InfoChip(
                          icon: Icons.flag_rounded,
                          label: goalLabel,
                          accent: AppColors.primary,
                        ),
                        _InfoChip(
                          icon: Icons.restaurant_rounded,
                          label: dietLabel,
                          accent: AppColors.secondary,
                        ),
                        _InfoChip(
                          icon: Icons.directions_run_rounded,
                          label: activityLabel,
                          accent: AppColors.accent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  icon: Icons.local_fire_department_rounded,
                  label: 'Calorias',
                  value: '${profile.calculatedCalories} kcal',
                  accent: AppColors.secondary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MiniStat(
                  icon: Icons.fitness_center_rounded,
                  label: 'Proteína',
                  value: '${profile.proteinGrams} g',
                  accent: AppColors.protein,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MiniStat(
                  icon: Icons.grain_rounded,
                  label: 'Carbo',
                  value: '${profile.carbsGrams} g',
                  accent: AppColors.carbs,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  icon: Icons.water_drop_rounded,
                  label: 'Gordura',
                  value: '${profile.fatGrams} g',
                  accent: AppColors.fat,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MiniStat(
                  icon: Icons.straighten_rounded,
                  label: 'Altura',
                  value: '${profile.height} cm',
                  accent: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MiniStat(
                  icon: Icons.calendar_month_rounded,
                  label: 'Meta',
                  value: '${_formatKg(profile.targetWeight)} kg',
                  accent: AppColors.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: accent),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final UserProfile profile;

  const _ProgressCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final diffKg = (profile.currentWeight - profile.targetWeight).abs();
    final isOnTarget = diffKg < 0.01;
    final progress = _estimatedProgress(profile);

    final subtitle = _progressSubtitle(profile);
    final headline = isOnTarget
        ? 'Meta atingida'
        : 'Você está a ${_formatKg(diffKg)} kg da meta';

    return _Card(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            headline,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceVariant,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_formatKg(profile.currentWeight)} kg',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_formatKg(profile.weeklyGoal)} kg/sem',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${_formatKg(profile.targetWeight)} kg',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalsCard extends StatelessWidget {
  final UserProfile profile;

  const _GoalsCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final items = [
      _GoalItem(
        icon: Icons.flag_rounded,
        label: 'Objetivo',
        value: _mainGoalLabel(profile.mainGoal),
      ),
      _GoalItem(
        icon: Icons.restaurant_rounded,
        label: 'Preferência',
        value: _dietLabel(profile.dietaryPreference),
      ),
      _GoalItem(
        icon: Icons.directions_run_rounded,
        label: 'Atividade',
        value: _activityLabel(profile.activityLevel),
      ),
      _GoalItem(
        icon: Icons.local_fire_department_rounded,
        label: 'Calorias',
        value: '${profile.calculatedCalories} kcal',
      ),
      _GoalItem(
        icon: Icons.tune_rounded,
        label: 'Macros',
        value:
            'P ${profile.proteinGrams}g • C ${profile.carbsGrams}g • G ${profile.fatGrams}g',
      ),
      _GoalItem(
        icon: Icons.calendar_month_rounded,
        label: 'Meta semanal',
        value: '${_formatKg(profile.weeklyGoal)} kg/sem',
      ),
    ];

    return _Card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _GoalsRow(item: items[i]),
            if (i != items.length - 1)
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                color: AppColors.border,
              ),
          ],
        ],
      ),
    );
  }
}

class _GoalItem {
  final IconData icon;
  final String label;
  final String value;

  const _GoalItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _GoalsRow extends StatelessWidget {
  final _GoalItem item;

  const _GoalsRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(item.icon, color: AppColors.textSecondary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
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

class _SettingsCardList extends StatelessWidget {
  final ValueChanged<String> onTap;

  const _SettingsCardList({required this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.person_outline_rounded, 'Conta'),
      (Icons.notifications_outlined, 'Lembretes'),
      (Icons.straighten_rounded, 'Unidades'),
      (Icons.tune_rounded, 'Refazer personalização'),
      (Icons.help_outline_rounded, 'Ajuda e FAQ'),
    ];

    return _Card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _SettingsRow(
              icon: items[i].$1,
              title: items[i].$2,
              onTap: () => onTap(items[i].$2),
            ),
            if (i != items.length - 1)
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                color: AppColors.border,
              ),
          ],
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(icon, color: AppColors.textSecondary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textPrimary.withValues(alpha: 0.25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
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

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Card({required this.child, required this.padding});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: Ink(
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.10),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

int _calculateAge(DateTime birthDate) {
  final today = DateTime.now();
  var age = today.year - birthDate.year;
  if (today.month < birthDate.month ||
      (today.month == birthDate.month && today.day < birthDate.day)) {
    age--;
  }
  return age;
}

String _formatKg(double value) {
  final format = NumberFormat('##0.0');
  return format.format(value);
}

String? _progressSubtitle(UserProfile profile) {
  final weeks = profile.weeksToGoal;
  if (weeks == null || weeks <= 0) return null;

  final date = profile.estimatedGoalDate;
  if (date == null) return 'Estimativa: $weeks semanas';

  final formattedDate = DateFormat('dd/MM').format(date);
  return 'Estimativa: $weeks semanas • $formattedDate';
}

double _estimatedProgress(UserProfile profile) {
  final start = profile.startWeight;
  final current = profile.currentWeight;
  final target = profile.targetWeight;

  if (start == target) {
    return (current == target) ? 1.0 : 0.0;
  }

  final totalDiff = (start - target).abs();
  if (totalDiff == 0) return 0.0;

  final currentDiff = (start - current).abs();

  final isLoss = target < start;
  // If moving in the wrong direction, 0 progress
  if (isLoss && current > start) return 0.0;
  if (!isLoss && current < start) return 0.0;

  final raw = currentDiff / totalDiff;

  return raw.clamp(0.0, 1.0);
}

String _mainGoalLabel(MainGoal goal) {
  switch (goal) {
    case MainGoal.loseWeight:
      return 'Perder peso';
    case MainGoal.maintain:
      return 'Manter';
    case MainGoal.buildMuscle:
      return 'Ganhar massa';
  }
}

String _dietLabel(DietaryPreference preference) {
  switch (preference) {
    case DietaryPreference.artificialIntelligence:
      return 'IA';
    case DietaryPreference.balanced:
      return 'Equilibrada';
    case DietaryPreference.highProtein:
      return 'Alta proteína';
    case DietaryPreference.lowCarb:
      return 'Low carb';
    case DietaryPreference.keto:
      return 'Cetogênica';
    case DietaryPreference.mediterranean:
      return 'Mediterrânea';
    case DietaryPreference.paleo:
      return 'Paleo';
    case DietaryPreference.lowFat:
      return 'Baixa gordura';
    case DietaryPreference.dash:
      return 'Dash';
    case DietaryPreference.pescetarian:
      return 'Pescetariana';
    case DietaryPreference.vegetarian:
      return 'Vegetariana';
    case DietaryPreference.vegan:
      return 'Vegana';
  }
}

String _activityLabel(ActivityLevel level) {
  switch (level) {
    case ActivityLevel.sedentary:
      return 'Sedentário';
    case ActivityLevel.low:
      return 'Leve';
    case ActivityLevel.active:
      return 'Ativo';
    case ActivityLevel.veryActive:
      return 'Muito ativo';
  }
}
