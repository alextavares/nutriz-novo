import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/models/recipe.dart';
import '../providers/recipes_providers.dart';

class RecipesListScreen extends ConsumerStatefulWidget {
  final String title;
  final String? meal;
  final String? diet;
  final String? tag;
  final int? minKcal;
  final int? maxKcal;
  final bool focusSearch;

  const RecipesListScreen({
    super.key,
    required this.title,
    this.meal,
    this.diet,
    this.tag,
    this.minKcal,
    this.maxKcal,
    this.focusSearch = false,
  });

  @override
  ConsumerState<RecipesListScreen> createState() => _RecipesListScreenState();
}

class _RecipesListScreenState extends ConsumerState<RecipesListScreen> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();

    _controller.addListener(() => setState(() {}));

    if (widget.focusSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mealFilter = _mealFromQuery(widget.meal);
    final dietFilter = _dietFromQuery(widget.diet);
    final query = _controller.text.trim().toLowerCase();

    final recipesAsync = ref.watch(recipesCatalogProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        elevation: 0,
        title: Text(
          widget.title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: recipesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _ErrorState(message: err.toString()),
        data: (recipes) {
          final filtered = recipes
              .where((recipe) {
                if (mealFilter != null && recipe.meal != mealFilter)
                  return false;
                if (dietFilter != null && !recipe.diets.contains(dietFilter)) {
                  return false;
                }
                if (widget.tag != null && widget.tag!.isNotEmpty) {
                  if (!recipe.tags.contains(widget.tag)) return false;
                }
                if (widget.minKcal != null &&
                    recipe.nutrition.calories < widget.minKcal!) {
                  return false;
                }
                if (widget.maxKcal != null &&
                    recipe.nutrition.calories > widget.maxKcal!) {
                  return false;
                }
                if (query.isEmpty) return true;

                final inTitle = recipe.title.toLowerCase().contains(query);
                final inIngredients = recipe.ingredients.any(
                  (i) => i.toLowerCase().contains(query),
                );
                return inTitle || inIngredients;
              })
              .toList(growable: false);

          return ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            children: [
              _SearchField(
                controller: _controller,
                focusNode: _focusNode,
                hintText: 'Buscar por nome ou ingrediente',
              ),
              const SizedBox(height: AppSpacing.md),
              _ActiveFiltersRow(
                meal: mealFilter,
                diet: dietFilter,
                tag: widget.tag,
                minKcal: widget.minKcal,
                maxKcal: widget.maxKcal,
              ),
              const SizedBox(height: AppSpacing.sm),
              if (filtered.isEmpty)
                const _EmptyState()
              else ...[
                Text(
                  '${filtered.length} receita${filtered.length == 1 ? '' : 's'}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final recipe = filtered[index];
                    return _RecipeListTile(
                      recipe: recipe,
                      onTap: () => context.push('/recipes/detail/${recipe.id}'),
                    );
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;

  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: AppColors.textHint),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                isDense: true,
                hintStyle: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              onPressed: controller.clear,
              icon: Icon(Icons.close_rounded, color: AppColors.textHint),
              tooltip: 'Limpar',
            ),
        ],
      ),
    );
  }
}

class _ActiveFiltersRow extends StatelessWidget {
  final RecipeMeal? meal;
  final RecipeDiet? diet;
  final String? tag;
  final int? minKcal;
  final int? maxKcal;

  const _ActiveFiltersRow({
    required this.meal,
    required this.diet,
    required this.tag,
    required this.minKcal,
    required this.maxKcal,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    if (meal != null) {
      chips.add(_FilterChip(label: _mealLabel(meal!)));
    }
    if (diet != null) {
      chips.add(_FilterChip(label: _dietLabel(diet!)));
    }
    if (tag != null && tag!.isNotEmpty) {
      chips.add(_FilterChip(label: _tagLabel(tag!)));
    }
    if (minKcal != null || maxKcal != null) {
      final label = maxKcal == null
          ? '$minKcal+ kcal'
          : '$minKcal–$maxKcal kcal';
      chips.add(_FilterChip(label: label));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: chips,
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;

  const _FilterChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _RecipeListTile extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;

  const _RecipeListTile({required this.recipe, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = recipe.imageUrl != null && recipe.imageUrl!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Image Section
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      child: hasImage
                          ? Image.network(
                              recipe.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _Placeholder(recipe: recipe),
                            )
                          : _Placeholder(recipe: recipe),
                    ),
                  ),
                  // Badges Overlay
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Wrap(
                      spacing: 8,
                      children: recipe.diets.take(2).map((diet) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.textPrimary.withValues(alpha: 0.62),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _dietLabel(diet),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  // Time Badge
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow.withValues(alpha: 0.12),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: AppColors.textPrimary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${recipe.timeMinutes} min',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Content Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        height: 1.2,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _MiniInfo(
                          icon: Icons.local_fire_department_rounded,
                          label: '${recipe.nutrition.calories} kcal',
                          color: AppColors.carbs,
                        ),
                        const SizedBox(width: 16),
                        _MiniInfo(
                          icon: Icons.fitness_center_rounded,
                          label: '${recipe.nutrition.protein}g prot',
                          color: AppColors.protein,
                        ),
                      ],
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

class _Placeholder extends StatelessWidget {
  final Recipe recipe;

  const _Placeholder({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final accent = _mealAccent(recipe.meal);
    return Container(
      color: accent.withValues(alpha: 0.15),
      child: Center(
        child: Icon(
          _mealIcon(recipe.meal),
          size: 48,
          color: accent.withOpacity(0.5),
        ),
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MiniInfo({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(
              Icons.search_off_rounded,
              color: AppColors.textHint,
              size: 34,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Nenhuma receita encontrada',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Tente buscar por outro ingrediente ou remova algum filtro.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
            Icon(Icons.error_outline_rounded, color: AppColors.error, size: 40),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Erro ao carregar receitas',
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

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Card({required this.child, required this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

RecipeMeal? _mealFromQuery(String? value) {
  switch (value) {
    case 'breakfast':
      return RecipeMeal.breakfast;
    case 'lunch':
      return RecipeMeal.lunch;
    case 'dinner':
      return RecipeMeal.dinner;
    case 'snack':
      return RecipeMeal.snack;
    default:
      return null;
  }
}

RecipeDiet? _dietFromQuery(String? value) {
  switch (value) {
    case 'vegetarian':
      return RecipeDiet.vegetarian;
    case 'vegan':
      return RecipeDiet.vegan;
    case 'lowCarb':
      return RecipeDiet.lowCarb;
    case 'glutenFree':
      return RecipeDiet.glutenFree;
    case 'highProtein':
      return RecipeDiet.highProtein;
    case 'lowFat':
      return RecipeDiet.lowFat;
    default:
      return null;
  }
}

String _mealLabel(RecipeMeal meal) {
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

String _tagLabel(String tag) {
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
      return tag;
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
