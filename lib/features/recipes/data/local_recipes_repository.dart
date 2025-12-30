import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/models/recipe.dart';

abstract class RecipesRepository {
  Future<List<Recipe>> getAll();
  Future<Recipe?> getById(String id);
}

class LocalRecipesRepository implements RecipesRepository {
  final String assetPath;

  List<Recipe>? _cache;

  LocalRecipesRepository({
    this.assetPath = 'assets/data/recipes.json',
  });

  @override
  Future<List<Recipe>> getAll() async {
    if (_cache != null) return _cache!;

    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('recipes.json inválido: raiz precisa ser um objeto.');
    }

    final items = decoded['recipes'];
    if (items is! List) {
      throw const FormatException('recipes.json inválido: "recipes" precisa ser uma lista.');
    }

    final recipes = <Recipe>[];
    for (final item in items) {
      if (item is! Map) continue;
      recipes.add(Recipe.fromJson(item.cast<String, dynamic>()));
    }

    _cache = List.unmodifiable(recipes);
    return _cache!;
  }

  @override
  Future<Recipe?> getById(String id) async {
    final recipes = await getAll();
    for (final recipe in recipes) {
      if (recipe.id == id) return recipe;
    }
    return null;
  }
}
