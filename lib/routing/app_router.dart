import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../features/diary/presentation/pages/diary_page.dart';
import '../features/diary/presentation/pages/food_search_page.dart';
import '../features/diary/domain/entities/meal.dart';
import '../features/fasting/presentation/pages/fasting_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: '/diary', // Start at Diary for now
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Home'))),
      ),
      GoRoute(path: '/diary', builder: (context, state) => const DiaryPage()),
      GoRoute(
        path: '/food-search/:mealType',
        builder: (context, state) {
          final mealTypeStr = state.pathParameters['mealType']!;
          final mealType = MealType.values.firstWhere(
            (e) => e.name == mealTypeStr,
            orElse: () => MealType.breakfast,
          );
          return FoodSearchPage(mealType: mealType);
        },
      ),
      GoRoute(
        path: '/fasting',
        builder: (context, state) => const FastingScreen(),
      ),
    ],
  );
}
