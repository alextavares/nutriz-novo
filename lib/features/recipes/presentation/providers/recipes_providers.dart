import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local_recipes_repository.dart';
import '../../domain/models/recipe.dart';

final recipesRepositoryProvider = Provider<RecipesRepository>((ref) {
  return LocalRecipesRepository();
});

final recipesCatalogProvider = FutureProvider<List<Recipe>>((ref) async {
  final repo = ref.watch(recipesRepositoryProvider);
  return repo.getAll();
});

final recipeByIdProvider = FutureProvider.family<Recipe?, String>((ref, id) async {
  final repo = ref.watch(recipesRepositoryProvider);
  return repo.getById(id);
});

