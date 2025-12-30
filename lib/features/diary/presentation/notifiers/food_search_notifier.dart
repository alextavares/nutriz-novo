import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/food_item.dart';
import '../../data/services/food_service.dart';
import '../../data/services/favorite_food_service.dart';
import '../../../gamification/presentation/providers/gamification_providers.dart';
import '../../../profile/data/repositories/profile_repository.dart';

// State class
class FoodSearchState {
  final String query;
  final List<FoodItem> results;
  final List<FoodItem> favoriteFoods;
  final List<FoodItem> recentFoods;
  final Set<String> favoriteIds;
  final bool isLoading;
  final String? error;

  FoodSearchState({
    this.query = '',
    this.results = const [],
    this.favoriteFoods = const [],
    this.recentFoods = const [],
    this.favoriteIds = const <String>{},
    this.isLoading = false,
    this.error,
  });

  FoodSearchState copyWith({
    String? query,
    List<FoodItem>? results,
    List<FoodItem>? favoriteFoods,
    List<FoodItem>? recentFoods,
    Set<String>? favoriteIds,
    bool? isLoading,
    String? error,
  }) {
    return FoodSearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      favoriteFoods: favoriteFoods ?? this.favoriteFoods,
      recentFoods: recentFoods ?? this.recentFoods,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier
class FoodSearchNotifier extends StateNotifier<FoodSearchState> {
  final FoodService _service;
  final FavoriteFoodService _favorites;
  int _activeSearchId = 0;

  FoodSearchNotifier(this._service, this._favorites) : super(FoodSearchState());

  void setQuery(String query) {
    state = state.copyWith(query: query, error: null);
  }

  Future<void> search(String query) async {
    final searchId = ++_activeSearchId;
    state = state.copyWith(query: query, isLoading: true, error: null);
    try {
      final results = query.trim().isEmpty
          ? await _service.getFrequentFoods()
          : await _service.searchFood(query);
      if (searchId != _activeSearchId) return;
      state = state.copyWith(results: results, isLoading: false);
    } catch (e) {
      if (searchId != _activeSearchId) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadFavorites() async {
    try {
      final favorites = await _favorites.getFavorites();
      final ids = favorites.map(_favorites.buildKey).toSet();
      state = state.copyWith(favoriteFoods: favorites, favoriteIds: ids);
    } catch (e) {
      // ignore loading favorites errors
    }
  }

  Future<void> loadRecents({int limit = 12, int days = 30}) async {
    try {
      final recents = await _service.getRecentFoods(
        limit: limit,
        days: days,
      );
      state = state.copyWith(recentFoods: recents);
    } catch (e) {
      // ignore loading recents errors
    }
  }

  Future<void> toggleFavorite(FoodItem item) async {
    await _favorites.toggleFavorite(item);
    await loadFavorites();
  }

  bool isFavorite(FoodItem item) {
    final key = _favorites.buildKey(item);
    return state.favoriteIds.contains(key);
  }

  Future<void> analyzeImage(File image) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _service.analyzeImage(image);
      if (result != null) {
        state = state.copyWith(results: [result], isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Nenhum alimento identificado',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Providers
  final foodServiceProvider = Provider<FoodService>((ref) {
    final isar = ref.watch(isarProvider);
    return FoodServiceImpl(isar: isar);
  });

  final foodSearchNotifierProvider =
    StateNotifierProvider<FoodSearchNotifier, FoodSearchState>((ref) {
      final service = ref.watch(foodServiceProvider);
      final isar = ref.watch(isarProvider);
      final profileRepository = ProfileRepository(isar);
      final favorites = FavoriteFoodService(
        profileRepository: profileRepository,
      );
      return FoodSearchNotifier(service, favorites);
    });
