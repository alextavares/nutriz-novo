import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutriz/core/analytics/analytics_providers.dart';
import 'package:nutriz/features/gamification/presentation/providers/gamification_providers.dart';
import 'package:nutriz/features/premium/presentation/providers/subscription_provider.dart';
import 'package:nutriz/features/profile/data/repositories/profile_repository.dart';
import 'package:nutriz/features/profile/domain/models/user_profile.dart';
import 'package:nutriz/features/profile/presentation/notifiers/profile_notifier.dart';

final mealLogGateProvider = Provider<MealLogGate>((ref) {
  return MealLogGate(ref);
});

enum MealLogBlockReason {
  locked,
  challengeUsedToday,
}

class MealLogDecision {
  final bool allowed;
  final MealLogBlockReason? blockReason;
  final bool consumedFreeMeal;
  final bool consumedChallengeMeal;
  final bool challengeCompletedNow;

  const MealLogDecision({
    required this.allowed,
    required this.blockReason,
    required this.consumedFreeMeal,
    required this.consumedChallengeMeal,
    required this.challengeCompletedNow,
  });

  const MealLogDecision.blocked(MealLogBlockReason reason)
    : allowed = false,
      blockReason = reason,
      consumedFreeMeal = false,
      consumedChallengeMeal = false,
      challengeCompletedNow = false;
}

class MealLogGate {
  MealLogGate(this._ref);

  final Ref _ref;

  MealLogBlockReason? peekBlockReason(UserProfile profile, DateTime now) {
    final subscription = _ref.read(subscriptionProvider);
    if (subscription.isPro) return null;

    if (profile.freeMealsRemaining > 0) return null;

    final challengeActive = !_isChallengeExpired(profile, now);
    final canUseChallengeToday = _canUseChallengeMealToday(profile, now);
    if (challengeActive && profile.challengeMealsRemaining > 0) {
      if (canUseChallengeToday) return null;
      return MealLogBlockReason.challengeUsedToday;
    }

    return MealLogBlockReason.locked;
  }

  Future<MealLogDecision> tryConsumeAllowance() async {
    final subscription = _ref.read(subscriptionProvider);
    if (subscription.isPro) {
      return const MealLogDecision(
        allowed: true,
        blockReason: null,
        consumedFreeMeal: false,
        consumedChallengeMeal: false,
        challengeCompletedNow: false,
      );
    }

    final repo = ProfileRepository(_ref.read(isarProvider));
    final existing = await repo.getProfile();
    if (existing == null) {
      return const MealLogDecision.blocked(MealLogBlockReason.locked);
    }

    final now = DateTime.now();
    var profile = existing;
    if (_isChallengeExpired(profile, now) && profile.challengeMealsRemaining > 0) {
      profile = profile.copyWith(
        challengeMealsRemaining: 0,
        challengeStartedAt: null,
        challengeLastMealAt: null,
      );
      await _persist(repo, profile);
    }

    if (profile.freeMealsRemaining > 0) {
      final next = profile.copyWith(freeMealsRemaining: profile.freeMealsRemaining - 1);
      await _persist(repo, next);
      await _ref.read(analyticsServiceProvider).logEvent('free_meal_consumed', {
        'remaining': next.freeMealsRemaining,
      });
      return const MealLogDecision(
        allowed: true,
        blockReason: null,
        consumedFreeMeal: true,
        consumedChallengeMeal: false,
        challengeCompletedNow: false,
      );
    }

    final challengeActive = !_isChallengeExpired(profile, now);
    final canUseChallengeToday = _canUseChallengeMealToday(profile, now);
    if (challengeActive && profile.challengeMealsRemaining > 0 && canUseChallengeToday) {
      final next = profile.copyWith(
        challengeMealsRemaining: profile.challengeMealsRemaining - 1,
        challengeLastMealAt: now,
      );
      await _persist(repo, next);
      final completedNow = next.challengeMealsRemaining == 0;
      await _ref.read(analyticsServiceProvider).logEvent('challenge_meal_consumed', {
        'remaining': next.challengeMealsRemaining,
        'completed_now': completedNow,
      });
      return MealLogDecision(
        allowed: true,
        blockReason: null,
        consumedFreeMeal: false,
        consumedChallengeMeal: true,
        challengeCompletedNow: completedNow,
      );
    }

    if (challengeActive && profile.challengeMealsRemaining > 0 && !canUseChallengeToday) {
      return const MealLogDecision.blocked(MealLogBlockReason.challengeUsedToday);
    }
    return const MealLogDecision.blocked(MealLogBlockReason.locked);
  }

  Future<void> recordPaywallDismissed() async {
    final repo = ProfileRepository(_ref.read(isarProvider));
    final profile = await repo.getProfile();
    if (profile == null) return;

    final next = profile.copyWith(paywallDismissCount: profile.paywallDismissCount + 1);
    await _persist(repo, next);
    await _ref.read(analyticsServiceProvider).logEvent('paywall_dismissed', {
      'count': next.paywallDismissCount,
    });
  }

  Future<void> start3DayChallenge() async {
    final repo = ProfileRepository(_ref.read(isarProvider));
    final profile = await repo.getProfile();
    if (profile == null) return;

    final now = DateTime.now();
    final next = profile.copyWith(
      challengeStartedAt: now,
      challengeLastMealAt: null,
      challengeMealsRemaining: 3,
    );
    await _persist(repo, next);
    await _ref.read(analyticsServiceProvider).logEvent('challenge_started', {
      'meals_total': 3,
    });
  }

  bool canUseAiPhoto() {
    final subscription = _ref.read(subscriptionProvider);
    return subscription.isPro;
  }

  bool isReadOnlyLocked(UserProfile profile) {
    final subscription = _ref.read(subscriptionProvider);
    if (subscription.isPro) return false;
    final now = DateTime.now();
    if (profile.freeMealsRemaining > 0) return false;
    final challengeActive = !_isChallengeExpired(profile, now);
    if (challengeActive &&
        profile.challengeMealsRemaining > 0 &&
        _canUseChallengeMealToday(profile, now)) {
      return false;
    }
    return true;
  }

  bool _isChallengeExpired(UserProfile profile, DateTime now) {
    final startedAt = profile.challengeStartedAt;
    if (startedAt == null) return true;
    final daysSinceStart = _daysBetweenLocalDates(startedAt, now);
    return daysSinceStart > 2;
  }

  bool _canUseChallengeMealToday(UserProfile profile, DateTime now) {
    final last = profile.challengeLastMealAt;
    if (last == null) return true;
    return _daysBetweenLocalDates(last, now) >= 1;
  }

  int _daysBetweenLocalDates(DateTime a, DateTime b) {
    final da = DateTime(a.year, a.month, a.day);
    final db = DateTime(b.year, b.month, b.day);
    return db.difference(da).inDays;
  }

  Future<void> _persist(ProfileRepository repo, UserProfile profile) async {
    await repo.saveProfile(profile);
    _ref.read(profileNotifierProvider.notifier).updateProfile(profile);
  }
}
