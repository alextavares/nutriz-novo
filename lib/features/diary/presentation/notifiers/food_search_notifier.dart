import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/food_item.dart';
import '../../data/services/food_service.dart';

// State class
class FoodSearchState {
  final String query;
  final List<FoodItem> results;
  final bool isLoading;
  final String? error;

  FoodSearchState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
    this.error,
  });

  FoodSearchState copyWith({
    String? query,
    List<FoodItem>? results,
    bool? isLoading,
    String? error,
  }) {
    return FoodSearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier
class FoodSearchNotifier extends StateNotifier<FoodSearchState> {
  final FoodService _service;

  FoodSearchNotifier(this._service) : super(FoodSearchState());

  Future<void> search(String query) async {
    state = state.copyWith(query: query, isLoading: true, error: null);
    try {
      final results = await _service.searchFood(query);
      state = state.copyWith(results: results, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> analyzeImage(File image) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _service.analyzeImage(image);
      if (result != null) {
        state = state.copyWith(results: [result], isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: 'No food detected');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Providers
final foodServiceProvider = Provider<FoodService>((ref) => FoodServiceImpl());

final foodSearchNotifierProvider =
    StateNotifierProvider<FoodSearchNotifier, FoodSearchState>((ref) {
      final service = ref.watch(foodServiceProvider);
      return FoodSearchNotifier(service);
    });
