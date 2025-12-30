import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../domain/models/recipe.dart';
import '../providers/recipes_providers.dart';

void _pushRecipesList(
  BuildContext context, {
  String? title,
  String? meal,
  String? diet,
  String? tag,
  int? minKcal,
  int? maxKcal,
  bool focusSearch = false,
}) {
  final params = <String, String>{};
  if (title != null && title.isNotEmpty) params['title'] = title;
  if (meal != null && meal.isNotEmpty) params['meal'] = meal;
  if (diet != null && diet.isNotEmpty) params['diet'] = diet;
  if (tag != null && tag.isNotEmpty) params['tag'] = tag;
  if (minKcal != null) params['minKcal'] = minKcal.toString();
  if (maxKcal != null) params['maxKcal'] = maxKcal.toString();
  if (focusSearch) params['focusSearch'] = '1';

  context.push(
    Uri(
      path: '/recipes/list',
      queryParameters: params.isEmpty ? null : params,
    ).toString(),
  );
}

void _pushRecipeDetail(BuildContext context, String id) {
  context.push('/recipes/detail/$id');
}

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

  void _comingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label em breve.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          surfaceTintColor: AppColors.background,
          elevation: 0,
          title: Text(
            'Receitas',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => _pushRecipesList(
                context,
                title: 'Buscar receitas',
                focusSearch: true,
              ),
              icon: Icon(
                Icons.search_rounded,
                color: AppColors.textPrimary.withValues(alpha: 0.55),
              ),
              tooltip: 'Buscar',
            ),
            IconButton(
              onPressed: () => _comingSoon(context, 'Filtros'),
              icon: Icon(
                Icons.tune_rounded,
                color: AppColors.textPrimary.withValues(alpha: 0.55),
              ),
              tooltip: 'Filtrar',
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
            tabs: const [
              Tab(text: 'DESCOBRIR'),
              Tab(text: 'FAVORITAS'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const _DiscoverTab(),
            const _FavoritesTab(),
          ],
        ),
      ),
    );
  }
}

class _DiscoverTab extends ConsumerWidget {
  const _DiscoverTab();

  void _onCategoryTap(BuildContext context, String label) {
    switch (label) {
      case 'Café':
        _pushRecipesList(context, title: 'Café da manhã', meal: 'breakfast');
        return;
      case 'Almoço':
        _pushRecipesList(context, title: 'Almoço', meal: 'lunch');
        return;
      case 'Jantar':
        _pushRecipesList(context, title: 'Jantar', meal: 'dinner');
        return;
      case 'Lanches':
        _pushRecipesList(context, title: 'Lanches', meal: 'snack');
        return;
      case 'Vegano':
        _pushRecipesList(context, title: 'Vegano', diet: 'vegan');
        return;
      case 'Proteína':
        _pushRecipesList(context, title: 'Alta proteína', diet: 'highProtein');
        return;
      case 'Leve':
        _pushRecipesList(context, title: 'Baixa gordura', diet: 'lowFat');
        return;
    }
  }

  void _onCalorieRangeTap(BuildContext context, String rangeLabel) {
    final parsed = _parseCalorieRange(rangeLabel);
    _pushRecipesList(
      context,
      title: '$rangeLabel kcal',
      minKcal: parsed.$1,
      maxKcal: parsed.$2,
    );
  }

  void _onMealTap(BuildContext context, String mealLabel) {
    switch (mealLabel) {
      case 'Café da manhã':
        _pushRecipesList(context, title: mealLabel, meal: 'breakfast');
        return;
      case 'Almoço':
        _pushRecipesList(context, title: mealLabel, meal: 'lunch');
        return;
      case 'Jantar':
        _pushRecipesList(context, title: mealLabel, meal: 'dinner');
        return;
      case 'Lanches':
        _pushRecipesList(context, title: mealLabel, meal: 'snack');
        return;
    }
  }

  void _onDietTap(BuildContext context, String label) {
    switch (label) {
      case 'Vegetariana':
        _pushRecipesList(context, title: label, diet: 'vegetarian');
        return;
      case 'Vegana':
        _pushRecipesList(context, title: label, diet: 'vegan');
        return;
      case 'Baixo carbo':
        _pushRecipesList(context, title: label, diet: 'lowCarb');
        return;
      case 'Sem glúten':
        _pushRecipesList(context, title: label, diet: 'glutenFree');
        return;
      case 'Alta proteína':
        _pushRecipesList(context, title: label, diet: 'highProtein');
        return;
      case 'Baixa gordura':
        _pushRecipesList(context, title: label, diet: 'lowFat');
        return;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final recipesAsync = ref.watch(recipesCatalogProvider);

    return Stack(
      children: [
        const _DecorativeBackground(),
        ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            bottomPadding + 160,
          ),
          children: [
            _SearchBarCard(
              onTap: () => _pushRecipesList(
                context,
                title: 'Buscar receitas',
                focusSearch: true,
              ),
              hintText: 'Buscar receitas ou ingredientes',
            ),
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader(title: 'Categorias populares'),
            _CategoryTilesRow(onTap: (label) => _onCategoryTap(context, label)),
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(
              title: 'Destaques',
              actionLabel: 'Ver tudo',
              onAction: () => _pushRecipesList(context, title: 'Destaques'),
            ),
            recipesAsync.when(
              loading: () => const _FeaturedRecipesSkeleton(),
              error: (error, stackTrace) => const _InlineMessageCard(
                icon: Icons.cloud_off_rounded,
                title: 'Sem receitas',
                subtitle: 'Não foi possível carregar o catálogo local.',
              ),
              data: (recipes) => _FeaturedRecipesRow(recipes: recipes),
            ),
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(
              title: 'Por faixa de calorias',
              actionLabel: 'Ver mais',
              onAction: () => _pushRecipesList(context, title: 'Por calorias'),
            ),
            _CalorieRangeGrid(
              onTap: (range) => _onCalorieRangeTap(context, range),
            ),
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader(title: 'Escolha sua refeição'),
            _MealGrid(onTap: (meal) => _onMealTap(context, meal)),
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader(title: 'Escolha sua dieta'),
            _DietGrid(onTap: (diet) => _onDietTap(context, diet)),
            const SizedBox(height: AppSpacing.lg),
            SectionHeader(
              title: 'Coleções',
              actionLabel: 'Ver mais',
              onAction: () => _pushRecipesList(context, title: 'Coleções'),
            ),
            recipesAsync.when(
              loading: () => const _CollectionsSkeleton(),
              error: (error, stackTrace) => const _InlineMessageCard(
                icon: Icons.cloud_off_rounded,
                title: 'Sem coleções',
                subtitle: 'Não foi possível carregar o catálogo local.',
              ),
              data: (recipes) => _CollectionsGrid(
                recipes: recipes,
                onTap: (tag) => _pushRecipesList(
                  context,
                  title: _collectionTitleFromTag(tag),
                  tag: tag,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const _InfoCard(
              icon: Icons.auto_awesome_rounded,
              title: 'Sugestões personalizadas',
              subtitle: 'Em breve: recomendações com base nas suas metas.',
              accent: AppColors.premium,
            ),
          ],
        ),
      ],
    );
  }
}

class _SearchBarCard extends StatelessWidget {
  final VoidCallback onTap;
  final String hintText;

  const _SearchBarCard({required this.onTap, required this.hintText});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _Card(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: AppColors.textHint),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hintText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Icon(Icons.tune_rounded, color: AppColors.textHint),
        ],
      ),
    );
  }
}

class _FeaturedRecipesSkeleton extends StatelessWidget {
  const _FeaturedRecipesSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 256,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 2,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          return Container(
            width: 240,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              border: Border.all(color: AppColors.border),
            ),
            child: Container(
              margin: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FeaturedRecipesRow extends StatelessWidget {
  final List<Recipe> recipes;

  const _FeaturedRecipesRow({required this.recipes});

  @override
  Widget build(BuildContext context) {
    final featured = recipes.take(6).toList(growable: false);

    if (featured.isEmpty) {
      return const _InlineMessageCard(
        icon: Icons.menu_book_rounded,
        title: 'Catálogo vazio',
        subtitle: 'Adicione receitas em assets/data/recipes.json.',
      );
    }

    return SizedBox(
      height: 256,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: featured.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final recipe = featured[index];
          return _FeaturedRecipeCard(
            recipe: recipe,
            onTap: () => _pushRecipeDetail(context, recipe.id),
          );
        },
      ),
    );
  }
}

class _FeaturedRecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;

  const _FeaturedRecipeCard({required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = _mealAccentFromMeal(recipe.meal);
    final mealLabel = _mealLabelFromMeal(recipe.meal);

    return SizedBox(
      width: 240,
      child: _Card(
        onTap: onTap,
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RecipeCoverPlaceholder(
                accent: accent,
                icon: _mealIconFromMeal(recipe.meal),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mealLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      recipe.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${recipe.nutrition.calories} kcal • ${recipe.timeMinutes} min',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeCoverPlaceholder extends StatelessWidget {
  final Color accent;
  final IconData icon;

  const _RecipeCoverPlaceholder({required this.accent, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accent.withValues(alpha: 0.30),
              AppColors.surface,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -28,
              bottom: -28,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Center(
              child: Icon(
                icon,
                size: 36,
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;

  const _SmallPill({
    required this.icon,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
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

class _InlineMessageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InlineMessageCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _Card(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, color: AppColors.textSecondary),
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
                    height: 1.35,
                    fontWeight: FontWeight.w600,
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

class _CollectionsSkeleton extends StatelessWidget {
  const _CollectionsSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 0.86,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(color: AppColors.border),
          ),
          child: Container(
            margin: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        );
      },
    );
  }
}

class _CategoryTilesRow extends StatelessWidget {
  final ValueChanged<String>? onTap;

  const _CategoryTilesRow({this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.free_breakfast_rounded, 'Café', AppColors.accent),
      (Icons.ramen_dining_rounded, 'Almoço', AppColors.primary),
      (Icons.dinner_dining_rounded, 'Jantar', AppColors.secondary),
      (Icons.emoji_food_beverage_rounded, 'Lanches', AppColors.premium),
      (Icons.grass_rounded, 'Vegano', AppColors.primaryDark),
      (Icons.fitness_center_rounded, 'Proteína', AppColors.protein),
      (Icons.spa_rounded, 'Leve', AppColors.fat),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final item = items[index];
          return _CategoryTile(
            icon: item.$1,
            label: item.$2,
            accent: item.$3,
            onTap: onTap == null ? null : () => onTap!(item.$2),
          );
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback? onTap;

  const _CategoryTile({
    required this.icon,
    required this.label,
    required this.accent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: accent),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalorieRangeGrid extends StatelessWidget {
  final ValueChanged<String>? onTap;

  const _CalorieRangeGrid({this.onTap});

  @override
  Widget build(BuildContext context) {
    const ranges = [
      (_CalorieRange('50–150', Icons.emoji_food_beverage_rounded, AppColors.accent)),
      (_CalorieRange('150–250', Icons.soup_kitchen_rounded, AppColors.primary)),
      (_CalorieRange('250–350', Icons.lunch_dining_rounded, AppColors.secondary)),
      (_CalorieRange('350–500', Icons.restaurant_rounded, AppColors.protein)),
      (_CalorieRange('500–650', Icons.local_pizza_rounded, AppColors.fat)),
      (_CalorieRange('650+', Icons.cake_rounded, AppColors.premium)),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.05,
      ),
      itemCount: ranges.length,
      itemBuilder: (context, index) => _CalorieRangeCard(
        data: ranges[index],
        onTap: onTap == null ? null : () => onTap!(ranges[index].range),
      ),
    );
  }
}

class _CalorieRange {
  final String range;
  final IconData icon;
  final Color accent;

  const _CalorieRange(this.range, this.icon, this.accent);
}

class _CalorieRangeCard extends StatelessWidget {
  final _CalorieRange data;
  final VoidCallback? onTap;

  const _CalorieRangeCard({required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _Card(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -18,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: data.accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -10,
            bottom: -16,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: data.accent.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: data.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, color: data.accent, size: 18),
              ),
              const Spacer(),
              Text(
                data.range,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'kcal',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MealGrid extends StatelessWidget {
  final ValueChanged<String>? onTap;

  const _MealGrid({this.onTap});

  @override
  Widget build(BuildContext context) {
    const meals = [
      (_MealPick('Café da manhã', 'Ideias rápidas e leves', Icons.free_breakfast_rounded, AppColors.accent)),
      (_MealPick('Almoço', 'Pratos equilibrados', Icons.lunch_dining_rounded, AppColors.primary)),
      (_MealPick('Jantar', 'Conforto sem exagero', Icons.dinner_dining_rounded, AppColors.secondary)),
      (_MealPick('Lanches', 'Snacks inteligentes', Icons.cookie_rounded, AppColors.premium)),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.65,
      ),
      itemCount: meals.length,
      itemBuilder: (context, index) => _MealCard(
        data: meals[index],
        onTap: onTap == null ? null : () => onTap!(meals[index].title),
      ),
    );
  }
}

class _MealPick {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;

  const _MealPick(this.title, this.subtitle, this.icon, this.accent);
}

class _MealCard extends StatelessWidget {
  final _MealPick data;
  final VoidCallback? onTap;

  const _MealCard({required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _Card(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Stack(
        children: [
          Positioned(
            right: -26,
            top: -26,
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: data.accent.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -30,
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: data.accent.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      data.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: data.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(data.icon, color: data.accent),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DietGrid extends StatelessWidget {
  final ValueChanged<String>? onTap;

  const _DietGrid({this.onTap});

  @override
  Widget build(BuildContext context) {
    const diets = [
      _DietPick('Vegetariana', Icons.spa_rounded, AppColors.primary),
      _DietPick('Vegana', Icons.grass_rounded, AppColors.primaryDark),
      _DietPick(
        'Baixo carbo',
        Icons.local_fire_department_rounded,
        AppColors.secondary,
      ),
      _DietPick('Sem glúten', Icons.no_food_rounded, AppColors.accent),
      _DietPick(
        'Alta proteína',
        Icons.fitness_center_rounded,
        AppColors.protein,
      ),
      _DietPick(
        'Baixa gordura',
        Icons.water_drop_rounded,
        AppColors.fat,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.1,
      ),
      itemCount: diets.length,
      itemBuilder: (context, index) {
        final item = diets[index];
        return _DietCard(
          data: item,
          onTap: onTap == null ? null : () => onTap!(item.label),
        );
      },
    );
  }
}

class _DietPick {
  final String label;
  final IconData icon;
  final Color accent;

  const _DietPick(this.label, this.icon, this.accent);
}

class _DietCard extends StatelessWidget {
  final _DietPick data;
  final VoidCallback? onTap;

  const _DietCard({required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _Card(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          Positioned(
            right: -22,
            bottom: -22,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: data.accent.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: data.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, color: data.accent, size: 18),
              ),
              const Spacer(),
              Text(
                data.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CollectionsGrid extends StatelessWidget {
  final List<Recipe> recipes;
  final ValueChanged<String>? onTap;

  const _CollectionsGrid({required this.recipes, this.onTap});

  @override
  Widget build(BuildContext context) {
    const collections = [
      _RecipeCollection(
        tag: 'world',
        title: 'Ao redor do mundo',
        subtitle: 'Sabores para variar sua rotina.',
        icon: Icons.public_rounded,
        accent: AppColors.accent,
      ),
      _RecipeCollection(
        tag: 'mexican',
        title: 'Sabores do México',
        subtitle: 'Picante, fresco e cheio de cor.',
        icon: Icons.local_fire_department_rounded,
        accent: AppColors.secondary,
      ),
      _RecipeCollection(
        tag: 'quick',
        title: 'Rápidas do dia',
        subtitle: 'Prontas em poucos minutos.',
        icon: Icons.timer_rounded,
        accent: AppColors.primary,
      ),
      _RecipeCollection(
        tag: 'seasonal',
        title: 'Ingredientes da estação',
        subtitle: 'Receitas com alimentos em alta.',
        icon: Icons.eco_rounded,
        accent: AppColors.primaryDark,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 0.86,
      ),
      itemCount: collections.length,
      itemBuilder: (context, index) {
        final item = collections[index];
        final count = recipes.where((r) => r.tags.contains(item.tag)).length;
        return _PhotoCollectionCard(
          collection: item,
          count: count,
          onTap: onTap == null ? null : () => onTap!(item.tag),
        );
      },
    );
  }
}

class _RecipeCollection {
  final String tag;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;

  const _RecipeCollection({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });
}

class _PhotoCollectionCard extends StatelessWidget {
  final _RecipeCollection collection;
  final int count;
  final VoidCallback? onTap;

  const _PhotoCollectionCard({
    required this.collection,
    required this.count,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final countLabel = '$count receita${count == 1 ? '' : 's'}';

    return _Card(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusXl),
              ),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            collection.accent.withValues(alpha: 0.20),
                            AppColors.surface,
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -28,
                            right: -26,
                            child: Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                color: collection.accent.withValues(alpha: 0.10),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -40,
                            left: -34,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: collection.accent.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Center(
                            child: Icon(
                              collection.icon,
                              size: 44,
                              color: collection.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.00),
                            Colors.black.withValues(alpha: 0.18),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        countLabel,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(
                        collection.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      'Ver receitas',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecorativeBackground extends StatelessWidget {
  const _DecorativeBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -140,
            right: -160,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 240,
            left: -180,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            right: -190,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
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

class _FavoritesTab extends StatelessWidget {
  const _FavoritesTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.favorite_rounded,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Sem favoritas ainda',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Explore receitas e salve as que você mais gostar.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () => DefaultTabController.of(context).animateTo(0),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w900),
              ),
              child: const Text('Explorar receitas'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const _Card({required this.child, required this.padding, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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

String _mealLabelFromMeal(RecipeMeal meal) {
  switch (meal) {
    case RecipeMeal.breakfast:
      return 'Café da manhã';
    case RecipeMeal.lunch:
      return 'Almoço';
    case RecipeMeal.dinner:
      return 'Jantar';
    case RecipeMeal.snack:
      return 'Lanches';
  }
}

Color _mealAccentFromMeal(RecipeMeal meal) {
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

IconData _mealIconFromMeal(RecipeMeal meal) {
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

String _collectionTitleFromTag(String tag) {
  switch (tag) {
    case 'world':
      return 'Ao redor do mundo';
    case 'mexican':
      return 'Sabores do México';
    case 'quick':
      return 'Rápidas do dia';
    case 'seasonal':
      return 'Ingredientes da estação';
    default:
      return 'Coleções';
  }
}

(int, int?) _parseCalorieRange(String label) {
  final normalized = label.replaceAll(' ', '');

  if (normalized.endsWith('+')) {
    final min = int.tryParse(normalized.substring(0, normalized.length - 1));
    return (min ?? 0, null);
  }

  final parts = normalized.contains('–')
      ? normalized.split('–')
      : normalized.contains('-')
          ? normalized.split('-')
          : <String>[];

  if (parts.length == 2) {
    final min = int.tryParse(parts[0]) ?? 0;
    final max = int.tryParse(parts[1]) ?? 0;
    return (min, max);
  }

  final single = int.tryParse(normalized) ?? 0;
  return (single, single);
}
