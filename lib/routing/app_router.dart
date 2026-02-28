import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/debug/debug_flags.dart';
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
import '../features/premium/presentation/pages/premium_screen.dart';
import '../features/recipes/presentation/pages/recipes_screen.dart';
import '../features/recipes/presentation/pages/recipes_list_screen.dart';
import '../features/recipes/presentation/pages/recipe_detail_screen.dart';
import '../features/onboarding/presentation/pages/prediction_screen.dart';
import '../features/premium/presentation/pages/hard_paywall_screen.dart';
import '../features/premium/presentation/pages/offer_paywall_screen.dart';
import '../features/legal/presentation/pages/privacy_policy_screen.dart';
import '../features/legal/presentation/pages/terms_of_service_screen.dart';
import '../features/coach/presentation/pages/coach_chat_screen.dart';
import '../features/diet/presentation/pages/diet_plan_screen.dart';
import '../features/diet/presentation/pages/shopping_list_screen.dart';

part 'app_router.g.dart';

/// Provider to track if onboarding has been completed
@riverpod
class OnboardingStatus extends _$OnboardingStatus {
  @override
  Future<bool> build() async {
    ref.keepAlive();
    final isar = ref.watch(isarProvider);
    final repo = ProfileRepository(isar);

    // Guard: on some devices/emulators, first Isar read can occasionally hang
    // (file lock / initialization edge). A short timeout avoids being stuck
    // forever on the splash screen in beta.
    // Increased timeout to 15s to avoid false negatives on slow devices (Davey!).
    final profile = await repo.getProfile().timeout(
      const Duration(seconds: 15),
      onTimeout: () => null,
    );
    final isCompleted = profile?.isOnboardingCompleted ?? false;
    if (DebugFlags.canVerbose) {
      debugPrint(
        'DEBUG: OnboardingStatus build. Profile found: ${profile != null}, isCompleted: $isCompleted',
      );
      debugPrint('DEBUG: OnboardingStatus profileId: ${profile?.id}');
    }
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
  String? lastRedirectLogKey;
  final logRedirects = DebugFlags.canVerbose;

  // Refresh GoRouter redirects when onboarding status changes, without
  // recreating the router (recreating can reset navigation and cause loops).
  final refreshNotifier = ValueNotifier<int>(0);
  ref.onDispose(refreshNotifier.dispose);
  ref.listen<AsyncValue<bool>>(onboardingStatusProvider, (prev, next) {
    // Avoid rebuilding routes during onboarding flow. We only need to refresh
    // redirects when the initial async load resolves (splash -> onboarding/diary).
    final prevWasLoading = prev?.isLoading ?? true;
    final nextIsResolved = next.hasValue || next.hasError;
    if (prevWasLoading && nextIsResolved) {
      refreshNotifier.value = refreshNotifier.value + 1;
    }
  });

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    refreshListenable: refreshNotifier,
    initialLocation: '/splash',
    redirect: (context, state) {
      // Read the latest value on every redirect call to avoid capturing a stale
      // AsyncValue in the router instance (can cause onboarding loops).
      final onboardingStatus = ref.read(onboardingStatusProvider);
      final isOnboardingRoute = state.matchedLocation == '/onboarding';
      final isOnboardingEditRoute = state.matchedLocation == '/onboarding/edit';
      final isSplashRoute = state.matchedLocation == '/splash';

      final isPredictionRoute =
          state.matchedLocation == '/onboarding/prediction';
      final isPaywallRoute = state.matchedLocation == '/premium/paywall';

      if (logRedirects) {
        final key =
            '${state.matchedLocation}|${state.uri}|${onboardingStatus.runtimeType}|${onboardingStatus.asData?.value}|${onboardingStatus.hasError}';
        if (key != lastRedirectLogKey) {
          lastRedirectLogKey = key;
          debugPrint(
            'DEBUG: Router redirect check. loc=${state.matchedLocation} uri=${state.uri} '
            'status=$onboardingStatus',
          );
        }
      }

      return onboardingStatus.when(
        data: (isCompleted) {
          if (logRedirects) {
            debugPrint(
              'DEBUG: Router redirect resolved. loc=${state.matchedLocation} isCompleted=$isCompleted',
            );
          }
          // If we're on splash, redirect based on onboarding status
          if (isSplashRoute) {
            return isCompleted ? '/diary' : '/onboarding';
          }
          // Allow editing onboarding only after completion.
          if (!isCompleted && isOnboardingEditRoute) {
            return '/onboarding';
          }
          // If onboarding is NOT completed and NOT on onboarding page, redirect to onboarding
          if (!isCompleted &&
              !isOnboardingRoute &&
              !isOnboardingEditRoute &&
              !isPredictionRoute &&
              !isPaywallRoute &&
              !isSplashRoute) {
            return '/onboarding';
          }
          // One-way guard: once completed, never stay in first-run onboarding route.
          if (isCompleted && isOnboardingRoute) {
            return '/diary';
          }
          return null; // No redirect needed
        },
        loading: () {
          if (logRedirects) {
            debugPrint(
              'DEBUG: Router redirect loading. loc=${state.matchedLocation}',
            );
          }
          // While loading, avoid bouncing off onboarding (resets its PageView).
          // Avoid bouncing from diary back to splash during transient loading
          // states right after onboarding completion/navigation.
          if (isSplashRoute ||
              isOnboardingRoute ||
              isOnboardingEditRoute ||
              state.matchedLocation == '/diary') {
            return null;
          }
          return '/splash';
        },
        error: (err, stack) {
          if (logRedirects) {
            debugPrint('DEBUG: Router redirect error: $err');
          }
          return '/onboarding';
        },
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
            builder: (context, state) {
              final quickAdd = state.uri.queryParameters['quickAdd'];
              final firstRun = state.uri.queryParameters['firstRun'] == '1';
              return DiaryPage(
                quickAddMealType: quickAdd,
                showFirstMealCta: firstRun,
              );
            },
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
            path: '/diet',
            builder: (context, state) => const DietPlanScreen(),
          ),
          GoRoute(
            path: '/coach',
            builder: (context, state) => const CoachChatScreen(),
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
        path: '/premium',
        builder: (context, state) => const PremiumScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/diet/shopping-list',
        builder: (context, state) => const ShoppingListScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/recipes/list',
        builder: (context, state) {
          final qp = state.uri.queryParameters;

          return RecipesListScreen(
            title: qp['title'] ?? 'Receitas',
            meal: qp['meal'],
            diet: qp['diet'],
            tag: qp['tag'],
            minKcal: int.tryParse(qp['minKcal'] ?? ''),
            maxKcal: int.tryParse(qp['maxKcal'] ?? ''),
            focusSearch: qp['focusSearch'] == '1',
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/recipes/detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return RecipeDetailScreen(recipeId: id);
        },
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
          final qp = state.uri.queryParameters;
          final tab = qp['tab'];
          final focusSearch = qp['focus'] == '1' || qp['focusSearch'] == '1';
          return AddFoodPage(
            mealType: mealType,
            startOnSearch: tab == 'search',
            focusSearch: focusSearch,
          );
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
        path: '/onboarding/edit',
        builder: (context, state) => const OnboardingPage.edit(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/onboarding/prediction',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PredictionScreen(
            currentWeight:
                (extra?['currentWeight'] as num?)?.toDouble() ?? 70.0,
            goalWeight: (extra?['goalWeight'] as num?)?.toDouble() ?? 60.0,
            age: (extra?['age'] as int?) ?? 25,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/premium/paywall',
        builder: (context, state) => const HardPaywallScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/premium/offer',
        builder: (context, state) => const OfferPaywallScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/legal/privacy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/legal/terms',
        builder: (context, state) => const TermsOfServiceScreen(),
      ),
    ],
  );
}
