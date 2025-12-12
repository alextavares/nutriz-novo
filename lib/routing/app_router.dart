import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../features/diary/presentation/pages/diary_page.dart';
import '../features/fasting/presentation/pages/fasting_screen.dart';
import '../features/diary/domain/entities/diary_day.dart';
import '../features/diary/presentation/pages/nutrition_detail_screen.dart';
import '../features/measurements/presentation/pages/weight_measurement_page.dart';
import '../shared/widgets/main_scaffold.dart';
import '../features/placeholders/placeholder_screens.dart';
import '../features/profile/presentation/pages/profile_screen.dart';
import '../features/diary/presentation/pages/add_food_page.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/gamification/presentation/providers/gamification_providers.dart';
import '../features/profile/data/repositories/profile_repository.dart';
import '../features/splash/presentation/pages/splash_screen.dart';

part 'app_router.g.dart';

/// Provider to track if onboarding has been completed
@riverpod
class OnboardingStatus extends _$OnboardingStatus {
  @override
  Future<bool> build() async {
    final isar = ref.watch(isarProvider);
    final repo = ProfileRepository(isar);
    final profile = await repo.getProfile();
    final isCompleted = profile?.isOnboardingCompleted ?? false;
    print(
      'DEBUG: OnboardingStatus build. Profile found: ${profile != null}, isCompleted: $isCompleted',
    );
    return isCompleted;
  }

  void setCompleted() {
    state = const AsyncValue.data(true);
  }
}

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final shellNavigatorKey = GlobalKey<NavigatorState>();
  final onboardingStatus = ref.watch(onboardingStatusProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final isOnboardingRoute = state.matchedLocation == '/onboarding';
      final isSplashRoute = state.matchedLocation == '/splash';

      // print('DEBUG: Redirect check. Path: ${state.matchedLocation}, OnboardingStatus: $onboardingStatus');

      return onboardingStatus.when(
        data: (isCompleted) {
          // If we're on splash, redirect based on onboarding status
          if (isSplashRoute) {
            return isCompleted ? '/diary' : '/onboarding';
          }
          // If onboarding is completed and trying to access onboarding, redirect to diary
          if (isCompleted && isOnboardingRoute) {
            return '/diary';
          }
          // If onboarding is NOT completed and NOT on onboarding page, redirect to onboarding
          if (!isCompleted && !isOnboardingRoute && !isSplashRoute) {
            return '/onboarding';
          }
          return null; // No redirect needed
        },
        loading: () {
          // While loading, stay on splash screen
          if (!isSplashRoute) {
            return '/splash';
          }
          return null;
        },
        error: (_, _) => '/onboarding', // On error, go to onboarding
      );
    },
    routes: [
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/diary',
            builder: (context, state) => const DiaryPage(),
          ),
          GoRoute(
            path: '/fasting',
            builder: (context, state) => const FastingScreen(),
          ),
          GoRoute(
            path: '/recipes',
            builder: (context, state) => const RecipesScreen(),
          ),
          GoRoute(
            path: '/coach',
            builder: (context, state) => const CoachScreen(),
          ),
          GoRoute(path: '/pro', builder: (context, state) => const ProScreen()),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/nutrition-detail',
        builder: (context, state) {
          final diaryDay = state.extra as DiaryDay;
          return NutritionDetailScreen(diaryDay: diaryDay);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/food-search/:mealType',
        builder: (context, state) {
          final mealType = state.pathParameters['mealType']!;
          return AddFoodPage(mealType: mealType);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/measurements',
        builder: (context, state) => const WeightMeasurementPage(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
    ],
  );
}
