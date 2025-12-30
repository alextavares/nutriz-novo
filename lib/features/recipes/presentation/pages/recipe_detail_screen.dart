import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/models/recipe.dart';
import '../providers/recipes_providers.dart';

class RecipeDetailScreen extends ConsumerWidget {
  final String recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  void _comingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label em breve.')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipeAsync = ref.watch(recipeByIdProvider(recipeId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: recipeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _ErrorState(message: err.toString()),
        data: (recipe) {
          if (recipe == null) return const _NotFoundState();

          final accent = _mealAccent(recipe.meal);
          final hasImage =
              recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: AppColors.background,
                surfaceTintColor: AppColors.background,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      hasImage
                          ? Image.network(recipe.imageUrl!, fit: BoxFit.cover)
                          : Container(
                              color: accent.withOpacity(0.15),
                              child: Icon(
                                _mealIcon(recipe.meal),
                                size: 80,
                                color: accent.withOpacity(0.5),
                              ),
                            ),
                      // Gradient overlay for text readability
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 16,
                        right: 16,
                        child: Text(
                          recipe.title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.1,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    MediaQuery.of(context).padding.bottom + 120,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _PropsRow(recipe: recipe),
                      const SizedBox(height: AppSpacing.lg),
                      _NutritionRow(recipe: recipe),
                      const SizedBox(height: AppSpacing.lg),
                      const _SectionTitle(title: 'Ingredientes'),
                      const SizedBox(height: AppSpacing.sm),
                      ...recipe.ingredients.map((i) => _BulletLine(text: i)),
                      const SizedBox(height: AppSpacing.lg),
                      const _SectionTitle(title: 'Modo de preparo'),
                      const SizedBox(height: AppSpacing.sm),
                      ...recipe.steps.asMap().entries.map(
                        (e) => _NumberedStep(
                          index: e.key + 1,
                          text: e.value,
                          accent: accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: recipeAsync.maybeWhen(
        data: (recipe) {
          if (recipe == null) return null;
          return SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: FilledButton(
                onPressed: () => _comingSoon(context, 'Adicionar ao diário'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                ),
                child: const Text('Adicionar ao diário'),
              ),
            ),
          );
        },
        orElse: () => null,
      ),
    );
  }
}

class _PropsRow extends StatelessWidget {
  final Recipe recipe;

  const _PropsRow({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      children: [
        _Pill(icon: Icons.schedule_rounded, label: '${recipe.timeMinutes} min'),
        _Pill(
          icon: _difficultyIcon(recipe.difficulty),
          label: _difficultyLabel(recipe.difficulty),
        ),
        ...recipe.diets
            .take(2)
            .map(
              (d) => _Pill(icon: Icons.verified_rounded, label: _dietLabel(d)),
            ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Pill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionRow extends StatelessWidget {
  final Recipe recipe;

  const _NutritionRow({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _NutritionCard(
            label: 'Proteína',
            value: '${recipe.nutrition.protein} g',
            accent: AppColors.protein,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _NutritionCard(
            label: 'Carbo',
            value: '${recipe.nutrition.carbs} g',
            accent: AppColors.carbs,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _NutritionCard(
            label: 'Gordura',
            value: '${recipe.nutrition.fat} g',
            accent: AppColors.fat,
          ),
        ),
      ],
    );
  }
}

class _NutritionCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _NutritionCard({
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
        color: AppColors.surface,
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
            child: Icon(Icons.circle, color: accent, size: 10),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
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

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  final String text;

  const _BulletLine({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 7),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberedStep extends StatelessWidget {
  final int index;
  final String text;
  final Color accent;

  const _NumberedStep({
    required this.index,
    required this.text,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotFoundState extends StatelessWidget {
  const _NotFoundState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, color: AppColors.textHint, size: 44),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Receita não encontrada',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Talvez ela tenha sido removida do catálogo local.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: AppColors.error, size: 44),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Erro ao carregar a receita',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                height: 1.35,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

Color _mealAccent(RecipeMeal meal) {
  switch (meal) {
    case RecipeMeal.breakfast:
      return AppColors.accent;
    case RecipeMeal.lunch:
      return AppColors.primary;
    case RecipeMeal.dinner:
      return AppColors.secondary;
    case RecipeMeal.snack:
      return AppColors.carbs;
  }
}

IconData _mealIcon(RecipeMeal meal) {
  switch (meal) {
    case RecipeMeal.breakfast:
      return Icons.free_breakfast_rounded;
    case RecipeMeal.lunch:
      return Icons.lunch_dining_rounded;
    case RecipeMeal.dinner:
      return Icons.dinner_dining_rounded;
    case RecipeMeal.snack:
      return Icons.cookie_rounded;
  }
}

String _dietLabel(RecipeDiet diet) {
  switch (diet) {
    case RecipeDiet.vegetarian:
      return 'Vegetariana';
    case RecipeDiet.vegan:
      return 'Vegana';
    case RecipeDiet.lowCarb:
      return 'Baixo carbo';
    case RecipeDiet.glutenFree:
      return 'Sem glúten';
    case RecipeDiet.highProtein:
      return 'Alta proteína';
    case RecipeDiet.lowFat:
      return 'Baixa gordura';
  }
}

String _difficultyLabel(RecipeDifficulty difficulty) {
  switch (difficulty) {
    case RecipeDifficulty.easy:
      return 'Fácil';
    case RecipeDifficulty.medium:
      return 'Média';
    case RecipeDifficulty.hard:
      return 'Difícil';
  }
}

IconData _difficultyIcon(RecipeDifficulty difficulty) {
  switch (difficulty) {
    case RecipeDifficulty.easy:
      return Icons.sentiment_satisfied_rounded;
    case RecipeDifficulty.medium:
      return Icons.sentiment_neutral_rounded;
    case RecipeDifficulty.hard:
      return Icons.sentiment_very_dissatisfied_rounded;
  }
}
