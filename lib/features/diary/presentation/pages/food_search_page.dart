import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/meal.dart';
import '../notifiers/food_search_notifier.dart';
import '../providers/diary_providers.dart';

class FoodSearchPage extends ConsumerStatefulWidget {
  final MealType mealType;

  const FoodSearchPage({super.key, required this.mealType});

  @override
  ConsumerState<FoodSearchPage> createState() => _FoodSearchPageState();
}

class _FoodSearchPageState extends ConsumerState<FoodSearchPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(foodSearchNotifierProvider);
    final foods = state.results;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Adicionar ao ${widget.mealType.name}',
        ), // Melhorar display name depois
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar alimentos...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                ref.read(foodSearchNotifierProvider.notifier).search(value);
              },
            ),
          ),
          if (state.isLoading)
            const LinearProgressIndicator()
          else if (state.error != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Erro: ${state.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: ListView.separated(
              itemCount: foods.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final food = foods[index];
                return ListTile(
                  title: Text(food.name, style: AppTypography.bodyLarge),
                  subtitle: Text(
                    '${food.calories} kcal / ${food.servingSize}',
                    style: AppTypography.caption,
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.add_circle,
                      color: AppColors.primary,
                    ),
                    onPressed: () {
                      // Adiciona o alimento e volta
                      ref
                          .read(diaryNotifierProvider.notifier)
                          .addFoodToMeal(
                            widget.mealType,
                            food.toDomain(),
                            1.0, // Default 1 serving for now
                          );
                      context.pop();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
