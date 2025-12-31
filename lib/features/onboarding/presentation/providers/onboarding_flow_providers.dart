import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Keeps the current onboarding PageView index stable even if the route/widget
/// is recreated by GoRouter refresh/redirects.
///
/// Keyed by `isEditMode` so the edit flow doesn't resume at a stale index from
/// the first-run flow (and vice-versa).
final onboardingCurrentPageProvider = StateProvider.family<int, bool>(
  (ref, isEditMode) => 0,
);
