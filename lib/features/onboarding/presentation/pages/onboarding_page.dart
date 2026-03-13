import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:nutriz/features/onboarding/presentation/notifiers/onboarding_notifier.dart';
import 'package:nutriz/features/profile/domain/models/user_profile.dart';
import 'package:nutriz/routing/app_router.dart';
import 'package:nutriz/core/analytics/analytics_providers.dart';
import 'package:nutriz/core/debug/debug_flags.dart';
import 'package:nutriz/features/onboarding/presentation/controllers/onboarding_terminal_flow.dart';
import 'package:nutriz/features/onboarding/presentation/providers/onboarding_flow_providers.dart';
import 'package:nutriz/features/premium/presentation/pages/offer_paywall_screen.dart';
import '../widgets/onboarding_step_container.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/goal_card.dart';
import '../widgets/calorie_result_display.dart';
import '../widgets/calculating_step.dart';
import '../widgets/ruler_picker.dart';
import '../widgets/long_term_results_chart.dart';
import '../widgets/age_wheel_picker.dart';
import '../widgets/science_ai_progress_chart.dart';
import '../widgets/restrictive_diets_chart.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  final bool isEditMode;

  const OnboardingPage({super.key, this.isEditMode = false});

  const OnboardingPage.edit({super.key}) : isEditMode = true;

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _HeaderIcon extends StatelessWidget {
  final String assetPath;
  final double size;

  const _HeaderIcon({required this.assetPath, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Image.asset(
          assetPath,
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  static const MethodChannel _notificationsChannel = MethodChannel(
    'com.nutriz.app/notifications',
  );

  late final PageController _pageController;
  late final TextEditingController _nameController;
  int _currentPage = 0;
  bool _weightUseMetric = true;
  bool _birthDateDefaulted = false;
  bool _weeklyGoalDefaulted = false;
  bool _pushPromptShown = false;
  bool _extraDetailsAddMore = false;

  @override
  void initState() {
    super.initState();
    final savedIndex = ref.read(
      onboardingCurrentPageProvider(widget.isEditMode),
    );
    var postCalculationReached = ref.read(
      onboardingPostCalculationReachedProvider(widget.isEditMode),
    );
    final existingName = ref.read(onboardingNotifierProvider).name;
    var initialIndex = _stepKeys.isEmpty
        ? 0
        : savedIndex.clamp(0, _stepKeys.length - 1);
    final initialStep = _stepKeys[initialIndex];
    final initialStepIsPostCalculation = _isPostCalculationStep(initialStep);

    // Recovery guard: if the persisted "post calculation reached" flag is true
    // but we're still in a pre-results step (e.g. rating), this flag is stale
    // and blocks progression to calculating/results.
    if (postCalculationReached &&
        !initialStepIsPostCalculation &&
        initialStep != _StepKey.calculating) {
      ref
              .read(
                onboardingPostCalculationReachedProvider(
                  widget.isEditMode,
                ).notifier,
              )
              .state =
          false;
      postCalculationReached = false;
    }

    if (postCalculationReached && initialStep == _StepKey.calculating) {
      final allDoneIndex = _stepKeys.indexOf(_StepKey.allDone);
      if (allDoneIndex != -1) {
        initialIndex = allDoneIndex;
      }
    }
    _currentPage = initialIndex;
    _completionReached =
        postCalculationReached ||
        _isPostCalculationStep(_stepKeys[initialIndex]);
    if (_completionReached) {
      _terminalFlow.transitionTo(OnboardingTerminalPhase.calculationComplete);
    }
    if (_stepKeys[initialIndex] == _StepKey.results) {
      _resultsNavigationTriggered = true;
    }
    _pageController = PageController(initialPage: initialIndex);
    _nameController = TextEditingController(text: existingName);
    // No debug logs here: this method runs often during development (hot
    // restart), and logging the whole step list is noisy.
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  List<_StepKey> get _stepKeys => widget.isEditMode
      ? const [
          _StepKey.welcome,
          _StepKey.gender,
          _StepKey.height,
          _StepKey.commitment,
          _StepKey.birthDate,
          _StepKey.activityLevel,
          _StepKey.scienceAi,
          _StepKey.currentWeight,
          _StepKey.mainGoal,
          _StepKey.targetWeight,
          _StepKey.realisticGoal,
          _StepKey.weeklyGoal,
          _StepKey.dietAiBoost,
          _StepKey.badHabits,
          _StepKey.dietaryPreference,
          _StepKey.healthConditions,
          _StepKey.thankYou,
          _StepKey.extraDetails,
          _StepKey.water,
          _StepKey.sleep,
          _StepKey.motivation,
          _StepKey.name,
          _StepKey.rating,
          _StepKey.calculating,
          _StepKey.results,
          _StepKey.allDone,
        ]
      : const [
          _StepKey.welcome,
          _StepKey.gender,
          _StepKey.height,
          _StepKey.commitment,
          _StepKey.birthDate,
          _StepKey.activityLevel,
          _StepKey.scienceAi,
          _StepKey.currentWeight,
          _StepKey.mainGoal,
          _StepKey.targetWeight,
          _StepKey.realisticGoal,
          _StepKey.weeklyGoal,
          _StepKey.dietAiBoost,
          _StepKey.badHabits,
          _StepKey.dietaryPreference,
          _StepKey.healthConditions,
          _StepKey.thankYou,
          _StepKey.extraDetails,
          _StepKey.water,
          _StepKey.sleep,
          _StepKey.motivation,
          _StepKey.name,
          _StepKey.rating,
          _StepKey.calculating,
          _StepKey.results,
          _StepKey.allDone,
        ];

  int get _totalPages => _stepKeys.length;
  _StepKey get _currentStepKey => _stepKeys[_currentPage];
  int get _calculatingPageIndex => _stepKeys.indexOf(_StepKey.calculating);
  int get _resultsPageIndex => _stepKeys.indexOf(_StepKey.results);
  bool get _isProUpsellPage =>
      !widget.isEditMode && _currentStepKey == _StepKey.proUpsell;
  bool get _isBeforeCalculating => _currentPage == _calculatingPageIndex - 1;

  bool _calculationInProgress = false;
  bool _calculationStarted = false;
  int _calculationRunId = 0;
  bool _finishInProgress = false;
  bool _navInProgress = false;
  bool _completionReached = false;
  bool _finalNavigationTriggered = false;
  bool _resultsNavigationTriggered = false;
  bool _stepTransitionLocked = false;
  bool _extraDetailsContinueInProgress = false;
  bool _loggedStart = false;
  final OnboardingTerminalFlow _terminalFlow = OnboardingTerminalFlow();
  Future<void>? _calculationFuture;
  Future<void>? _persistCompletionFuture;
  bool get _logOnboarding => DebugFlags.canVerbose;
  bool get _logNav => DebugFlags.canVerbose;

  void _logOnboardingSignal(
    String name, [
    Map<String, Object?> details = const {},
  ]) {
    if (_logOnboarding) {
      debugPrint('$name $details');
    }
  }

  bool _isPostCalculationStep(_StepKey step) {
    return step == _StepKey.results ||
        step == _StepKey.proUpsell ||
        step == _StepKey.allDone ||
        step == _StepKey.foodLoggingMethod;
  }

  bool get _calculationCompleteReached =>
      _terminalFlow.calculationCompleteReached;

  bool get _completionPersistedReached =>
      _terminalFlow.completionPersistedReached;

  bool _isStepBeforeResults(_StepKey step) {
    final index = _stepKeys.indexOf(step);
    return index != -1 && index < _resultsPageIndex;
  }

  int _effectiveCurrentIndex() {
    if (!_pageController.hasClients) return _currentPage;
    final page = _pageController.page;
    if (page == null) return _currentPage;
    return page.round().clamp(0, _totalPages - 1);
  }

  _StepKey _effectiveCurrentStepKey() {
    return _stepKeys[_effectiveCurrentIndex()];
  }

  void _recoverStalePostCalculationState({required String source}) {
    if (!_calculationCompleteReached) return;
    final effectiveStep = _effectiveCurrentStepKey();
    if (!_isStepBeforeResults(effectiveStep)) return;

    _terminalFlow.reset();
    _completionReached = false;
    _resultsNavigationTriggered = false;
    _calculationStarted = false;
    _calculationInProgress = false;
    _calculationFuture = null;
    _persistCompletionFuture = null;
    ref
            .read(
              onboardingPostCalculationReachedProvider(
                widget.isEditMode,
              ).notifier,
            )
            .state =
        false;
    _logOnboardingSignal('stale_post_calculation_recovered', {
      'source': source,
      'step': effectiveStep.name,
    });
  }

  void _setTerminalPhase(
    OnboardingTerminalPhase next, {
    required String reason,
  }) {
    final changed = _terminalFlow.transitionTo(next);
    if (!changed) return;
    _logOnboardingSignal('terminal_phase_change', {
      'phase': next.name,
      'reason': reason,
    });
    if (mounted) {
      setState(() {});
    }
  }

  void _nextPage() {
    FocusScope.of(context).unfocus();
    if (_finalNavigationTriggered) return;
    if (_stepTransitionLocked) return;
    _recoverStalePostCalculationState(source: 'next_page');
    if (_logNav) {
      debugPrint(
        'DEBUG: _nextPage called. _currentPage=$_currentPage, _totalPages=$_totalPages',
      );
    }
    if (_currentPage < _totalPages - 1) {
      final nextIndex = (_currentPage + 1).clamp(0, _totalPages - 1);
      final nextStep = _stepKeys[nextIndex];
      if (_calculationCompleteReached && _isStepBeforeResults(nextStep)) {
        _logOnboardingSignal('blocked_step_regression', {
          'from': _currentStepKey.name,
          'to': nextStep.name,
          'reason': 'calculation_complete',
        });
        return;
      }
      _stepTransitionLocked = true;
      if (_logNav) {
        debugPrint('DEBUG: _nextPage animating to page $nextIndex');
      }
      _animateToPage(nextIndex);
    } else {
      if (_logNav) {
        debugPrint('DEBUG: _nextPage skipped, already on last page');
      }
    }
  }

  void _animateToPage(int index) {
    if (index < 0 || index >= _totalPages) return;
    if (!_pageController.hasClients) {
      _logOnboardingSignal('animate_to_page_deferred', {'target': index});
      _stepTransitionLocked = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (!_pageController.hasClients) return;
        _animateToPage(index);
      });
      return;
    }
    final effectiveIndex = _effectiveCurrentIndex();
    if (effectiveIndex == index) {
      _stepTransitionLocked = false;
      if (_currentPage != index && mounted) {
        setState(() {
          _currentPage = index;
        });
      }
      ref
              .read(onboardingCurrentPageProvider(widget.isEditMode).notifier)
              .state =
          index;
      return;
    }
    _recoverStalePostCalculationState(source: 'animate_to_page');
    final targetStep = _stepKeys[index];
    if (_calculationCompleteReached && _isStepBeforeResults(targetStep)) {
      _logOnboardingSignal('blocked_step_regression', {
        'from': _currentStepKey.name,
        'to': targetStep.name,
        'reason': 'calculation_complete',
      });
      return;
    }
    // Persist the intended target immediately so if the route/widget is
    // recreated mid-animation we can restore the right page.
    ref.read(onboardingCurrentPageProvider(widget.isEditMode).notifier).state =
        index;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
    HapticFeedback.lightImpact();
  }

  void _jumpToPage(int index) {
    FocusScope.of(context).unfocus();
    if (index < 0 || index >= _totalPages) return;
    _stepTransitionLocked = false;
    ref.read(onboardingCurrentPageProvider(widget.isEditMode).notifier).state =
        index;
    if (!_pageController.hasClients) {
      _logOnboardingSignal('jump_to_page_deferred', {'target': index});
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (!_pageController.hasClients) return;
        _pageController.jumpToPage(index);
      });
      return;
    }
    _pageController.jumpToPage(index);
  }

  void _goToStep(_StepKey stepKey) {
    FocusScope.of(context).unfocus();
    if (_finalNavigationTriggered) return;
    _recoverStalePostCalculationState(source: 'go_to_${stepKey.name}');
    if (_stepTransitionLocked) {
      // Recovery for rare dead-lock on rating -> calculating transition.
      if (_currentStepKey == _StepKey.rating &&
          stepKey == _StepKey.calculating) {
        _logOnboardingSignal('step_lock_recovered', {
          'from': _currentStepKey.name,
          'to': stepKey.name,
        });
        _stepTransitionLocked = false;
      } else {
        return;
      }
    }
    if (_calculationCompleteReached && _isStepBeforeResults(stepKey)) {
      if (_logOnboarding) {
        debugPrint(
          'DEBUG: _goToStep blocked to ${stepKey.name} after calculation_complete.',
        );
      }
      return;
    }
    final index = _stepKeys.indexOf(stepKey);
    if (index == -1) return;
    _stepTransitionLocked = true;
    _animateToPage(index);
  }

  void _goToCalculatingFromRating(OnboardingNotifier notifier) {
    unawaited(notifier.saveDraft());
    final index = _stepKeys.indexOf(_StepKey.calculating);
    if (index == -1) return;

    void forceJump(String source) {
      if (!mounted) return;
      final effectiveIndex = _effectiveCurrentIndex();
      if (effectiveIndex == index) return;
      _logOnboardingSignal('rating_continue_force_jump', {
        'source': source,
        'from': _stepKeys[effectiveIndex].name,
        'to': _StepKey.calculating.name,
      });
      _recoverStalePostCalculationState(source: source);
      _stepTransitionLocked = false;
      _jumpToPage(index);
    }

    // Short+hard fallback cover release-only race conditions in controller sync.
    unawaited(
      Future<void>.delayed(
        const Duration(milliseconds: 350),
        () => forceJump('rating_continue_short_fallback'),
      ),
    );
    unawaited(
      Future<void>.delayed(
        const Duration(milliseconds: 900),
        () => forceJump('rating_continue_hard_fallback'),
      ),
    );

    try {
      _recoverStalePostCalculationState(source: 'rating_continue_direct_jump');
      _stepTransitionLocked = false;
      _jumpToPage(index);
    } catch (e, stack) {
      _logOnboardingSignal('rating_continue_direct_jump_error', {
        'error': e.toString(),
      });
      if (_logOnboarding) {
        debugPrint('DEBUG: rating_continue_direct_jump_error: $e\n$stack');
      }
      forceJump('rating_continue_exception_recovery');
    }
  }

  void _jumpToStep(_StepKey stepKey) {
    if (_calculationCompleteReached && _isStepBeforeResults(stepKey)) {
      _logOnboardingSignal('blocked_step_regression', {
        'from': _currentStepKey.name,
        'to': stepKey.name,
        'reason': 'calculation_complete',
      });
      return;
    }
    final index = _stepKeys.indexOf(stepKey);
    if (index == -1) return;
    _jumpToPage(index);
  }

  void _cancelCalculation() {
    _calculationRunId++;
    _calculationFuture = null;
    if (mounted) {
      setState(() {
        _calculationInProgress = false;
        _calculationStarted = false;
      });
    }
    _setTerminalPhase(
      OnboardingTerminalPhase.collecting,
      reason: 'calculation_cancelled',
    );
  }

  Future<void> _ensureCalculationComplete(
    OnboardingNotifier notifier, {
    required String source,
  }) async {
    if (_calculationCompleteReached) return;
    if (_calculationFuture != null) {
      await _calculationFuture;
      return;
    }

    _setTerminalPhase(OnboardingTerminalPhase.calculating, reason: source);
    _calculationStarted = true;
    _calculationInProgress = true;
    final runId = _calculationRunId;
    _logOnboardingSignal('calculation_start_once', {
      'source': source,
      'run_id': runId,
    });

    _calculationFuture = () async {
      await notifier.calculateAndSave();
      _completionReached = true;
      _setTerminalPhase(
        OnboardingTerminalPhase.calculationComplete,
        reason: source,
      );
      ref
              .read(
                onboardingPostCalculationReachedProvider(
                  widget.isEditMode,
                ).notifier,
              )
              .state =
          true;
      _logOnboardingSignal('calculation_complete_once', {
        'source': source,
        'run_id': runId,
      });
    }();

    try {
      await _calculationFuture;
    } finally {
      _calculationInProgress = false;
      _calculationFuture = null;
    }
  }

  Future<void> _persistCompletionOnce({required String source}) async {
    if (_completionPersistedReached) return;
    if (_persistCompletionFuture != null) {
      await _persistCompletionFuture;
      return;
    }

    _setTerminalPhase(
      OnboardingTerminalPhase.completionPersisting,
      reason: source,
    );
    _persistCompletionFuture = () async {
      await ref.read(onboardingNotifierProvider.notifier).persistCompletion();
      _completionReached = true;
      _setTerminalPhase(
        OnboardingTerminalPhase.completionPersisted,
        reason: source,
      );
      ref
              .read(
                onboardingPostCalculationReachedProvider(
                  widget.isEditMode,
                ).notifier,
              )
              .state =
          true;
      _logOnboardingSignal('persist_completion_once', {'source': source});
    }();

    try {
      await _persistCompletionFuture;
    } finally {
      _persistCompletionFuture = null;
    }
  }

  Future<void> _navigateFinalOnce(String route) async {
    if (_finalNavigationTriggered) {
      if (_logOnboarding) {
        debugPrint(
          'DEBUG: final navigation already triggered, ignoring $route',
        );
      }
      return;
    }
    _finalNavigationTriggered = true;
    _setTerminalPhase(
      OnboardingTerminalPhase.finalNavigationTriggered,
      reason: route,
    );
    _completionReached = true;
    ref
            .read(
              onboardingPostCalculationReachedProvider(
                widget.isEditMode,
              ).notifier,
            )
            .state =
        false;
    _logOnboardingSignal('final_navigation', {'route': route});
    ref.read(onboardingStatusProvider.notifier).setCompleted();
    ref.read(onboardingCurrentPageProvider(widget.isEditMode).notifier).state =
        0;
    if (!mounted) return;
    _setTerminalPhase(
      OnboardingTerminalPhase.finalNavigationDone,
      reason: route,
    );
    context.go(route);
  }

  void _handleBack() {
    if (_currentPage <= 0) return;
    if (_calculationCompleteReached) {
      _logOnboardingSignal('back_blocked', {
        'step': _currentStepKey.name,
        'reason': 'calculation_complete',
      });
      return;
    }

    if (_currentStepKey == _StepKey.calculating) {
      _cancelCalculation();
      _animateToPage(_calculatingPageIndex - 1);
      return;
    }

    // Pular a etapa "calculando" ao voltar (ela é só loading).
    if (_currentStepKey == _StepKey.results) {
      _animateToPage(_calculatingPageIndex - 1);
      return;
    }

    if (_currentStepKey == _StepKey.proUpsell) {
      _animateToPage(_resultsPageIndex);
      return;
    }

    _animateToPage(_currentPage - 1);
  }

  bool _canProceed() {
    final profile = ref.read(onboardingNotifierProvider);
    switch (_currentStepKey) {
      case _StepKey.welcome:
        return true;
      case _StepKey.gender:
        return true;
      case _StepKey.mainGoal:
        return true;
      case _StepKey.commitment:
        return true;
      case _StepKey.birthDate:
        // Ensure user is at least 10 years old (Diet.ai limit)
        return profile.birthDate.year <= DateTime.now().year - 10;
      case _StepKey.height:
        // Ensure valid height (e.g., 50cm to 300cm)
        return profile.height >= 50 && profile.height <= 300;
      case _StepKey.currentWeight:
        return profile.currentWeight >= 30 && profile.currentWeight <= 300;
      case _StepKey.targetWeight:
        return profile.targetWeight >= 30 && profile.targetWeight <= 300;
      case _StepKey.realisticGoal:
        return true;
      case _StepKey.weeklyGoal:
        return true;
      case _StepKey.dietAiBoost:
        return true;
      case _StepKey.healthConditions:
        return true;
      case _StepKey.thankYou:
        return true;
      case _StepKey.pushNotifications:
        return true;
      case _StepKey.extraDetails:
        return true;
      case _StepKey.name:
        return profile.name.trim().isNotEmpty;
      case _StepKey.rating:
        return true;
      case _StepKey.allDone:
        return true;
      case _StepKey.foodLoggingMethod:
        return true;
      case _StepKey.activityLevel:
        return true;
      case _StepKey.scienceAi:
        return true;
      case _StepKey.dietaryPreference:
        return true;
      case _StepKey.badHabits:
        return true; // Optional
      case _StepKey.water:
        return true;
      case _StepKey.sleep:
        return true;
      case _StepKey.motivation:
        return profile.motivations.isNotEmpty;
      case _StepKey.calculating:
        return false;
      case _StepKey.results:
        return true;
      case _StepKey.proUpsell:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch profile to react to state changes (e.g., gender selection)
    final profile = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final theme = Theme.of(context);
    final totalSteps = _calculatingPageIndex > 1
        ? _calculatingPageIndex - 1
        : 0;
    final showStepLabel =
        totalSteps > 0 &&
        _currentPage > 0 &&
        _currentPage < _calculatingPageIndex &&
        _currentStepKey != _StepKey.height &&
        _currentStepKey != _StepKey.commitment &&
        _currentStepKey != _StepKey.birthDate &&
        _currentStepKey != _StepKey.activityLevel &&
        _currentStepKey != _StepKey.scienceAi &&
        _currentStepKey != _StepKey.currentWeight &&
        _currentStepKey != _StepKey.targetWeight &&
        _currentStepKey != _StepKey.realisticGoal &&
        _currentStepKey != _StepKey.weeklyGoal &&
        _currentStepKey != _StepKey.dietAiBoost &&
        _currentStepKey != _StepKey.dietaryPreference &&
        _currentStepKey != _StepKey.healthConditions &&
        _currentStepKey != _StepKey.thankYou &&
        _currentStepKey != _StepKey.pushNotifications &&
        _currentStepKey != _StepKey.extraDetails &&
        _currentStepKey != _StepKey.name &&
        _currentStepKey != _StepKey.rating &&
        _currentStepKey != _StepKey.allDone &&
        _currentStepKey != _StepKey.foodLoggingMethod &&
        _currentStepKey != _StepKey.badHabits;
    final stepNumber = totalSteps == 0
        ? 0
        : (_currentPage - 1).clamp(0, totalSteps - 1) + 1;

    if (!_loggedStart && !widget.isEditMode) {
      _loggedStart = true;
      ref.read(analyticsServiceProvider).logEvent('onboarding_start');
    }

    final showProgressBar =
        !_isProUpsellPage &&
        _currentStepKey != _StepKey.welcome &&
        _currentStepKey != _StepKey.gender &&
        _currentStepKey != _StepKey.mainGoal;

    final showBottomNavButton =
        _currentStepKey != _StepKey.calculating &&
        (_currentStepKey != _StepKey.results || widget.isEditMode) &&
        !_isProUpsellPage &&
        _currentStepKey != _StepKey.welcome &&
        _currentStepKey != _StepKey.gender &&
        _currentStepKey != _StepKey.mainGoal &&
        _currentStepKey != _StepKey.commitment &&
        _currentStepKey != _StepKey.height &&
        _currentStepKey != _StepKey.birthDate &&
        _currentStepKey != _StepKey.activityLevel &&
        _currentStepKey != _StepKey.scienceAi &&
        _currentStepKey != _StepKey.currentWeight &&
        _currentStepKey != _StepKey.targetWeight &&
        _currentStepKey != _StepKey.realisticGoal &&
        _currentStepKey != _StepKey.weeklyGoal &&
        _currentStepKey != _StepKey.dietAiBoost &&
        _currentStepKey != _StepKey.dietaryPreference &&
        _currentStepKey != _StepKey.healthConditions &&
        _currentStepKey != _StepKey.thankYou &&
        _currentStepKey != _StepKey.pushNotifications &&
        _currentStepKey != _StepKey.extraDetails &&
        _currentStepKey != _StepKey.name &&
        _currentStepKey != _StepKey.rating &&
        _currentStepKey != _StepKey.allDone &&
        _currentStepKey != _StepKey.foodLoggingMethod &&
        _currentStepKey != _StepKey.badHabits;

    return PopScope(
      canPop: _currentPage == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentPage > 0) {
          _handleBack();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Progress Bar
              // IMPORTANT: Keep this slot stable (don't insert/remove widgets
              // above the PageView), otherwise Flutter may recreate the PageView
              // and re-attach the controller, causing page resets.
              if (showProgressBar)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          if (_currentPage > 0 && !_calculationCompleteReached)
                            IconButton(
                              onPressed: _handleBack,
                              icon: const Icon(Icons.arrow_back_ios, size: 20),
                            )
                          else
                            const SizedBox(width: 48),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (_resultsPageIndex == 0)
                                    ? 0.0
                                    : (_currentPage / _resultsPageIndex)
                                          .clamp(0.0, 1.0)
                                          .toDouble(),
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.primary,
                                ),
                                minHeight: 6,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 72,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child:
                                  (_currentStepKey == _StepKey.results ||
                                      _currentStepKey == _StepKey.calculating ||
                                      _currentStepKey == _StepKey.welcome ||
                                      _currentStepKey == _StepKey.gender ||
                                      _currentStepKey == _StepKey.height ||
                                      _currentStepKey == _StepKey.commitment ||
                                      _currentStepKey == _StepKey.birthDate ||
                                      _currentStepKey ==
                                          _StepKey.activityLevel ||
                                      _currentStepKey == _StepKey.scienceAi ||
                                      _currentStepKey ==
                                          _StepKey.currentWeight ||
                                      _currentStepKey ==
                                          _StepKey.targetWeight ||
                                      _currentStepKey ==
                                          _StepKey.realisticGoal ||
                                      _currentStepKey == _StepKey.weeklyGoal ||
                                      _currentStepKey == _StepKey.dietAiBoost ||
                                      _currentStepKey ==
                                          _StepKey.dietaryPreference ||
                                      _currentStepKey ==
                                          _StepKey.healthConditions ||
                                      _currentStepKey == _StepKey.thankYou ||
                                      _currentStepKey ==
                                          _StepKey.pushNotifications ||
                                      _currentStepKey ==
                                          _StepKey.extraDetails ||
                                      _currentStepKey == _StepKey.name ||
                                      _currentStepKey == _StepKey.rating ||
                                      _currentStepKey == _StepKey.allDone ||
                                      _currentStepKey ==
                                          _StepKey.foodLoggingMethod ||
                                      _currentStepKey == _StepKey.badHabits)
                                  ? const SizedBox.shrink()
                                  : TextButton(
                                      onPressed: _finishInProgress
                                          ? null
                                          : widget.isEditMode
                                          ? _cancelEdit
                                          : () => _skipOnboarding(notifier),
                                      child: Text(
                                        widget.isEditMode
                                            ? 'Cancelar'
                                            : 'Pular',
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      if (showStepLabel)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'Passo $stepNumber de $totalSteps',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              else
                const SizedBox.shrink(),

              // Page Content
              Expanded(
                child: PageView.builder(
                  key: const PageStorageKey<String>('onboarding_page_view'),
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _stepKeys.length,
                  onPageChanged: (index) {
                    if (_logNav) {
                      debugPrint('DEBUG: onPageChanged index=$index');
                    }
                    if (mounted && _currentPage != index) {
                      setState(() {
                        _currentPage = index;
                      });
                    }
                    _stepTransitionLocked = false;
                    ref
                            .read(
                              onboardingCurrentPageProvider(
                                widget.isEditMode,
                              ).notifier,
                            )
                            .state =
                        index;
                    final enteredStep = _stepKeys[index];
                    if (enteredStep == _StepKey.extraDetails) {
                      _extraDetailsContinueInProgress = false;
                    }
                    _logOnboardingSignal('onboarding_step_enter', {
                      'step_index': index,
                      'step': enteredStep.name,
                    });
                    if (_isPostCalculationStep(enteredStep)) {
                      _completionReached = true;
                      if (enteredStep == _StepKey.results) {
                        _resultsNavigationTriggered = true;
                      }
                      _setTerminalPhase(
                        OnboardingTerminalPhase.calculationComplete,
                        reason: 'entered_${enteredStep.name}',
                      );
                      ref
                              .read(
                                onboardingPostCalculationReachedProvider(
                                  widget.isEditMode,
                                ).notifier,
                              )
                              .state =
                          true;
                    }

                    if (!widget.isEditMode) {
                      ref.read(analyticsServiceProvider).logEvent(
                        'onboarding_step_view',
                        {'step_index': index, 'step_total': _totalPages},
                      );
                    }

                    // Failsafe: if we just entered the calculating step, kick
                    // off the calculation even if the loading widget callback
                    // doesn't fire (avoids getting stuck on the loading UI).
                    if (_stepKeys[index] == _StepKey.calculating &&
                        _calculationInProgress &&
                        !_calculationStarted) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        if (_currentStepKey != _StepKey.calculating) return;
                        _startCalculation(
                          ref.read(onboardingNotifierProvider.notifier),
                        );
                      });
                    }
                  },
                  itemBuilder: (context, index) {
                    return _buildStep(_stepKeys[index], notifier, profile);
                  },
                ),
              ),

              // Navigation Button
              if (showBottomNavButton)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _canProceed()
                          ? () async {
                              // ... logic ...
                              if (_logNav) {
                                debugPrint(
                                  'DEBUG: OnboardingPage Navigation Button pressed. _currentStepKey=$_currentStepKey',
                                );
                              }
                              if (_navInProgress) {
                                if (_logNav) {
                                  debugPrint(
                                    'DEBUG: Nav in progress, ignoring.',
                                  );
                                }
                                return;
                              }
                              setState(() => _navInProgress = true);
                              try {
                                if (_isBeforeCalculating) {
                                  // Before calculation step
                                  if (_calculationInProgress) return;
                                  setState(() {
                                    _calculationInProgress = true;
                                  });
                                  unawaited(notifier.saveDraft());
                                  _nextPage();
                                  return;
                                }

                                if (_currentStepKey == _StepKey.results) {
                                  if (_logNav) {
                                    debugPrint(
                                      'DEBUG: On results step, finishing.',
                                    );
                                  }
                                  if (widget.isEditMode) {
                                    _finishEdit();
                                  } else {
                                    await _finishOnboarding(
                                      nextRoute: '/diary?firstRun=1',
                                    );
                                  }
                                  return;
                                }

                                if (_currentPage > 0) {
                                  unawaited(notifier.saveDraft());
                                }
                                _nextPage();
                              } catch (e, stack) {
                                if (_logNav) {
                                  debugPrint(
                                    'DEBUG: Navigation error: $e\n$stack',
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setState(() => _navInProgress = false);
                                }
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == 0
                            ? 'Começar'
                            : _currentStepKey == _StepKey.results
                            ? (widget.isEditMode
                                  ? 'Salvar'
                                  : 'Ir para o Diário')
                            : 'Próximo',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              if (!showBottomNavButton) const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  void _startCalculation(OnboardingNotifier notifier) {
    if (_currentStepKey != _StepKey.calculating) return;
    if (_calculationCompleteReached) return;
    if (!mounted) return;
    unawaited(
      _ensureCalculationComplete(notifier, source: 'start_calculating_step'),
    );
  }

  Future<void> _onCalculatingStepComplete(OnboardingNotifier notifier) async {
    await _ensureCalculationComplete(
      notifier,
      source: 'calculating_step_complete',
    );
    if (!mounted) return;
    if (_currentStepKey != _StepKey.calculating) return;
    if (_resultsNavigationTriggered) return;
    _resultsNavigationTriggered = true;
    _jumpToStep(_StepKey.results);
  }

  void _cancelEdit() {
    if (!mounted) return;
    ref.read(onboardingCurrentPageProvider(widget.isEditMode).notifier).state =
        0;
    ref
            .read(
              onboardingPostCalculationReachedProvider(
                widget.isEditMode,
              ).notifier,
            )
            .state =
        false;
    context.pop();
  }

  Future<void> _skipOnboarding(OnboardingNotifier notifier) async {
    if (_logOnboarding) {
      debugPrint('DEBUG: OnboardingPage._skipOnboarding tap');
    }
    _cancelCalculation();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pular personalização?'),
          content: const Text(
            'Você pode personalizar depois no Perfil. Por enquanto, vamos usar metas padrão.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Continuar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Usar padrão'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;
    if (_finishInProgress) return;

    setState(() => _finishInProgress = true);
    try {
      await _ensureCalculationComplete(notifier, source: 'skip_onboarding');
      if (!mounted) return;
      await _persistCompletionOnce(source: 'skip_onboarding');
      _completionReached = true;
      if (!mounted) return;
      if (_logOnboarding) {
        debugPrint(
          'DEBUG: OnboardingPage._skipOnboarding persistCompletion OK',
        );
      }
      if (!widget.isEditMode) {
        final p = ref.read(onboardingNotifierProvider);
        unawaited(
          ref.read(analyticsServiceProvider).logEvent('onboarding_complete', {
            'screen': 'onboarding',
            'goal_type': p.mainGoal.name,
            'activity_level': p.activityLevel.name,
            'calorie_target': p.calculatedCalories,
            'protein_g': p.proteinGrams,
            'carbs_g': p.carbsGrams,
            'fat_g': p.fatGrams,
            'skipped': true,
          }),
        );
        unawaited(
          ref.read(analyticsServiceProvider).logEvent('goal_set', {
            'screen': 'onboarding',
            'goal_type': p.mainGoal.name,
            'activity_level': p.activityLevel.name,
            'calorie_target': p.calculatedCalories,
            'protein_g': p.proteinGrams,
            'carbs_g': p.carbsGrams,
            'fat_g': p.fatGrams,
            'source': 'skip',
          }),
        );
      }
      await _navigateFinalOnce('/diary?firstRun=1');
    } finally {
      if (mounted) {
        setState(() => _finishInProgress = false);
      }
    }
  }

  Future<void> _finishOnboarding({String nextRoute = '/diary'}) async {
    if (_logOnboarding) {
      debugPrint(
        'DEBUG: OnboardingPage._finishOnboarding call next=$nextRoute',
      );
    }
    if (_finishInProgress) {
      if (_logOnboarding) {
        debugPrint('DEBUG: _finishInProgress is true, ignoring.');
      }
      return;
    }
    setState(() {
      _finishInProgress = true;
    });

    try {
      await _persistCompletionOnce(source: 'finish_onboarding');
      _completionReached = true;
      if (_logOnboarding) {
        debugPrint(
          'DEBUG: OnboardingPage._finishOnboarding persistCompletion OK',
        );
      }

      if (!mounted) return;
      if (!widget.isEditMode) {
        final p = ref.read(onboardingNotifierProvider);
        unawaited(
          ref.read(analyticsServiceProvider).logEvent('onboarding_complete', {
            'screen': 'onboarding',
            'goal_type': p.mainGoal.name,
            'activity_level': p.activityLevel.name,
            'calorie_target': p.calculatedCalories,
            'protein_g': p.proteinGrams,
            'carbs_g': p.carbsGrams,
            'fat_g': p.fatGrams,
            'skipped': false,
          }),
        );
        unawaited(
          ref.read(analyticsServiceProvider).logEvent('goal_set', {
            'screen': 'onboarding',
            'goal_type': p.mainGoal.name,
            'activity_level': p.activityLevel.name,
            'calorie_target': p.calculatedCalories,
            'protein_g': p.proteinGrams,
            'carbs_g': p.carbsGrams,
            'fat_g': p.fatGrams,
            'source': 'finish',
          }),
        );
      }

      await _navigateFinalOnce(nextRoute);
    } finally {
      if (mounted) {
        setState(() {
          _finishInProgress = false;
        });
      }
    }
  }

  void _finishEdit() {
    if (!mounted) return;
    ref.read(onboardingCurrentPageProvider(widget.isEditMode).notifier).state =
        0;
    ref
            .read(
              onboardingPostCalculationReachedProvider(
                widget.isEditMode,
              ).notifier,
            )
            .state =
        false;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Metas atualizadas.')));
    context.pop();
  }

  // ============ STEP BUILDERS ============

  Widget _buildWelcomeStep() {
    // DIET.AI CLONE: Step 1 "Intro" (Apple Logo)
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Progress Bar (Fake for first screen?)
                // Diet.ai has a small green bar at top.
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 40),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: 0.05,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF4CAF50),
                      ),
                      minHeight: 4,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // LOGO (Approximation)
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ), // Placeholder for shadow/elevation
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons
                        .eco_rounded, // Best fit for "Apple/Nature" without custom asset
                    size: 100,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(height: 48),

                // TITLE
                Text(
                  'Emagreça sem complicação.\nComece seu plano personalizado hoje.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E1E1E),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // BODY
                Text(
                  'Vou fazer algumas perguntas rápidas para calcular sua meta de calorias e proteína e colocar sua alimentação no trilho.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: const Color(0xFF757575),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 64),

                // BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continuar',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Você poderá ajustar tudo depois no Perfil.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF9E9E9E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                // MEDICAL DISCLAIMER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Aviso Legal: As dietas e sugestões de jejum deste aplicativo não substituem o aconselhamento, diagnóstico ou tratamento médico profissional. Sempre consulte um médico ou nutricionista.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFFBDBDBD),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // DIET.AI CLONE: Step 2 "Gender"
  Widget _buildGenderStep(OnboardingNotifier notifier, UserProfile profile) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _handleBack,
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: 0.1,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF4CAF50),
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance for back button
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // Mars/Venus Icons (Diet.ai style - coral/pink)
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _HeaderIcon(
                          assetPath: 'assets/images/icons/icon_gender_3d.png',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Qual é seu sexo?',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E1E1E),
                      ),
                    ),
                    const SizedBox(height: 32),

                    Row(
                      children: [
                        Expanded(
                          child: _Gender3DCard(
                            label: 'Homem',
                            isSelected: profile.gender == Gender.male,
                            isMale: true,
                            onTap: () => notifier.updateGender(Gender.male),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _Gender3DCard(
                            label: 'Mulher',
                            isSelected: profile.gender == Gender.female,
                            isMale: false,
                            onTap: () => notifier.updateGender(Gender.female),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    Text(
                      'Usamos seu gênero para criar o melhor plano de dieta para você. Selecione o que mais se aproxima do seu perfil hormonal.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF212121),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // BUTTON
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _goToStep(_StepKey.height),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continuar',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainGoalStep(OnboardingNotifier notifier, UserProfile profile) {
    final progressValue = (_resultsPageIndex == 0)
        ? 0.0
        : (_currentPage / _resultsPageIndex).clamp(0.0, 1.0).toDouble();

    String imageFor(MainGoal goal) {
      final suffix = profile.gender == Gender.male ? 'male' : 'female';
      return switch (goal) {
        MainGoal.loseWeight => 'assets/images/goal_lose_weight_$suffix.png',
        MainGoal.maintain => 'assets/images/goal_maintain_$suffix.png',
        MainGoal.buildMuscle => 'assets/images/goal_gain_weight_$suffix.png',
      };
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header (DietAI-like)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _handleBack,
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF4CAF50),
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.emoji_events_rounded,
                          color: Color(0xFF111827),
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Quais são seus\nobjetivos alimentares?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _DietAiMainGoalCard(
                      title: 'Perder peso',
                      isSelected: profile.mainGoal == MainGoal.loseWeight,
                      emoji: '🔥',
                      assetPath: imageFor(MainGoal.loseWeight),
                      onTap: () => notifier.updateMainGoal(MainGoal.loseWeight),
                    ),
                    const SizedBox(height: 10),
                    _DietAiMainGoalCard(
                      title: 'Manter peso',
                      isSelected: profile.mainGoal == MainGoal.maintain,
                      emoji: '🌿',
                      assetPath: imageFor(MainGoal.maintain),
                      onTap: () => notifier.updateMainGoal(MainGoal.maintain),
                    ),
                    const SizedBox(height: 10),
                    _DietAiMainGoalCard(
                      title: 'Ganhar peso',
                      isSelected: profile.mainGoal == MainGoal.buildMuscle,
                      emoji: '💪',
                      assetPath: imageFor(MainGoal.buildMuscle),
                      onTap: () =>
                          notifier.updateMainGoal(MainGoal.buildMuscle),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          notifier.saveDraft();
                          _nextPage();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Continuar',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommitmentStep(
    OnboardingNotifier notifier,
    UserProfile profile,
  ) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nutriz traz resultados\na longo prazo',
              style: GoogleFonts.inter(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF111827),
                height: 1.15,
              ),
            ),
            const SizedBox(height: 18),
            const LongTermResultsChart(),
            const SizedBox(height: 10),
            Text(
              'O objetivo aqui não é uma solução rápida. '
              'É criar um ritmo simples para você registrar, ajustar o dia e manter consistência.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.4,
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continuar',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthDateStep(OnboardingNotifier notifier, UserProfile profile) {
    final age = DateTime.now().year - profile.birthDate.year;
    final clampedAge = age.clamp(12, 100);
    const defaultAge = 30;

    final initialAge = clampedAge == 12 ? defaultAge : clampedAge;
    if (!_birthDateDefaulted && clampedAge == 12) {
      _birthDateDefaulted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final year = DateTime.now().year - defaultAge;
        notifier.updateBiometrics(birthDate: DateTime(year, 1, 1));
      });
    }

    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          children: [
            const SizedBox(height: 8),
            const _HeaderIcon(assetPath: 'assets/images/icons/icon_age_3d.png'),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Qual é sua idade?',
                style: GoogleFonts.inter(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF111827),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: AgeWheelPicker(
                initialAge: initialAge,
                minAge: 12,
                maxAge: 100,
                onChanged: (value) {
                  final year = DateTime.now().year - value;
                  notifier.updateBiometrics(birthDate: DateTime(year, 1, 1));
                },
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _canProceed() ? _nextPage : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continuar',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeightStep(OnboardingNotifier notifier, UserProfile profile) {
    final theme = Theme.of(context);
    final isMale = profile.gender == Gender.male;

    const minCm = 120;
    const maxCm = 220;

    final heightCm = profile.height.clamp(minCm, maxCm).toInt();
    final rulerValue = heightCm.toDouble();
    final rulerMin = minCm.toDouble();
    final rulerMax = maxCm.toDouble();

    final heightLabel = '$heightCm cm';

    const rulerWidth = 110.0;
    const avatarRightInset = rulerWidth + 12;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 12),
          const Center(
            child: _HeaderIcon(
              assetPath: 'assets/images/icons/icon_height_3d.png',
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Qual é sua altura?',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E1E1E),
                  height: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final centerY = constraints.maxHeight / 2;
                  final avatarViewportHeightFactor = isMale ? 0.48 : 0.48;
                  final avatarXOffset = 0.0;

                  final avatarViewportHeight =
                      constraints.maxHeight * avatarViewportHeightFactor;

                  // With BoxFit.cover, height/width are determined by the container.
                  // passing height to Image might conflict, so we remove it or rely on SizedBox.

                  return Stack(
                    children: [
                      Positioned(
                        left: 0,
                        right: avatarRightInset,
                        top: 0,
                        bottom: 0,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Transform.translate(
                            offset: Offset(avatarXOffset, 0),
                            child: SizedBox(
                              height: avatarViewportHeight,
                              child: ClipRect(
                                child: Image.asset(
                                  isMale
                                      ? 'assets/images/gender_man.png'
                                      : 'assets/images/gender_woman.png',
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: centerY,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 1.5,
                          color: const Color(0xFF60A5FA),
                        ),
                      ),
                      Positioned(
                        top: centerY - 26,
                        left: 0,
                        right: avatarRightInset - 8,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            heightLabel,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        width: rulerWidth,
                        child: Theme(
                          data: theme.copyWith(
                            colorScheme: theme.colorScheme.copyWith(
                              onSurface: const Color(0xFF9CA3AF),
                            ),
                          ),
                          child: RulerPicker(
                            label: '',
                            unit: 'cm',
                            value: rulerValue,
                            min: rulerMin,
                            max: rulerMax,
                            direction: Axis.vertical,
                            showValue: false,
                            showIndicator: false,
                            onChanged: (value) {
                              notifier.updateBiometrics(height: value.round());
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _canProceed() ? _nextPage : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continuar',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitToggleOption(
    String text,
    bool isSelected, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF9E9E9E),
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  int _kgToLbs(int kg) => (kg * 2.2046226218).round();

  double _kgToLbsDouble(double kg) => kg * 2.2046226218;
  double _lbsToKg(int lbs) => lbs / 2.2046226218;

  double _calculateBmi({required double weightKg, required int heightCm}) {
    final heightM = heightCm / 100.0;
    if (heightM <= 0) return 0;
    return weightKg / (heightM * heightM);
  }

  String _bmiCategory(double bmi) {
    if (bmi < 18.5) return 'Abaixo do peso';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Sobrepeso';
    if (bmi < 35) return 'Obesidade';
    return 'Obesidade grave';
  }

  Widget _buildWeightUnitToggle() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildUnitToggleOption(
            'kg',
            _weightUseMetric,
            onTap: () => setState(() => _weightUseMetric = true),
          ),
          _buildUnitToggleOption(
            'lbs',
            !_weightUseMetric,
            onTap: () => setState(() => _weightUseMetric = false),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentWeightStep(
    OnboardingNotifier notifier,
    UserProfile profile,
  ) {
    final theme = Theme.of(context);
    const minKg = 30;
    const maxKg = 200;

    final weightKg = profile.currentWeight.clamp(
      minKg.toDouble(),
      maxKg.toDouble(),
    );

    // Display Logic
    String displayString;
    if (_weightUseMetric) {
      displayString = weightKg.toStringAsFixed(1);
    } else {
      displayString = _kgToLbs(weightKg.round()).toString();
    }
    final displayUnit = _weightUseMetric ? 'kg' : 'lbs';

    // Ruler Logic
    // If Metric, we scale by 10 to support 100g (0.1kg) increments.
    // e.g. 30.0kg -> 300 units.
    final rulerMin = _weightUseMetric
        ? (minKg * 10).toDouble()
        : _kgToLbs(minKg).toDouble();
    final rulerMax = _weightUseMetric
        ? (maxKg * 10).toDouble()
        : _kgToLbs(maxKg).toDouble();

    final rulerValue = _weightUseMetric
        ? (weightKg * 10)
        : _kgToLbsDouble(weightKg);

    final bmi = _calculateBmi(weightKg: weightKg, heightCm: profile.height);
    final bmiText = bmi <= 0 ? '--' : bmi.toStringAsFixed(1);
    final bmiCategory = bmi <= 0 ? '' : _bmiCategory(bmi);

    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 6),
                    const _HeaderIcon(
                      assetPath: 'assets/images/icons/icon_weight_3d.png',
                      size: 50,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Qual é seu peso?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(child: _buildWeightUnitToggle()),
                    const SizedBox(height: 20),
                    Text(
                      '$displayString $displayUnit',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF4CAF50),
                        letterSpacing: -1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Theme(
                            data: theme.copyWith(
                              scaffoldBackgroundColor: Colors.white,
                            ),
                            child: RulerPicker(
                              label: '',
                              unit: displayUnit,
                              value: rulerValue,
                              min: rulerMin,
                              max: rulerMax,
                              direction: Axis.horizontal,
                              showValue: false,
                              showIndicator: false,
                              labelBuilder: _weightUseMetric
                                  ? (val) => (val / 10).round().toString()
                                  : null,
                              onChanged: (value) {
                                final picked = value.round();
                                final double nextKg;
                                if (_weightUseMetric) {
                                  // picked is scaled x10 (e.g. 935 => 93.5)
                                  nextKg = picked / 10.0;
                                } else {
                                  // picked is lbs (e.g. 150)
                                  nextKg = _lbsToKg(picked);
                                }
                                notifier.updateBiometrics(
                                  currentWeight: nextKg,
                                );
                              },
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 34),
                              child: Container(
                                width: 2,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF60A5FA),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Seu Índice de Massa Corporal (IMC) é',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      bmiText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                    if (bmiCategory.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Seu IMC mostra que você está $bmiCategory.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    _BmiScale(bmi: bmi),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _canProceed()
                    ? () {
                        final profile = ref.read(onboardingNotifierProvider);
                        final notifier = ref.read(
                          onboardingNotifierProvider.notifier,
                        );
                        var target = profile.currentWeight;

                        if (profile.mainGoal == MainGoal.loseWeight) {
                          target = profile.currentWeight * 0.9;
                        } else if (profile.mainGoal == MainGoal.buildMuscle) {
                          target = profile.currentWeight * 1.05;
                        }

                        // Round to 1 decimal place (e.g. 74.2)
                        target = (target * 10).roundToDouble() / 10;

                        notifier.updateTarget(targetWeight: target);
                        _nextPage();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continuar',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetWeightStep(
    OnboardingNotifier notifier,
    UserProfile profile,
  ) {
    final theme = Theme.of(context);

    const minKg = 30;
    const maxKg = 200;

    final currentKg = profile.currentWeight.clamp(
      minKg.toDouble(),
      maxKg.toDouble(),
    );
    final targetKg = profile.targetWeight.clamp(
      minKg.toDouble(),
      maxKg.toDouble(),
    );

    // Display Logic
    String displayString;
    if (_weightUseMetric) {
      displayString = targetKg.toStringAsFixed(1);
    } else {
      displayString = _kgToLbs(targetKg.round()).toString();
    }
    final displayUnit = _weightUseMetric ? 'kg' : 'lbs';

    // Ruler Logic
    // Scale x10 for Metric (100g precision)
    final rulerMin = _weightUseMetric
        ? (minKg * 10).toDouble()
        : _kgToLbs(minKg).toDouble();
    final rulerMax = _weightUseMetric
        ? (maxKg * 10).toDouble()
        : _kgToLbs(maxKg).toDouble();

    final rulerValue = _weightUseMetric
        ? (targetKg * 10)
        : _kgToLbsDouble(
            targetKg,
          ); // Use non-rounded conversion if possible or clamped

    final diffKg = (targetKg - currentKg);
    final diffAbsKg = diffKg.abs();
    final isLoss = diffKg < -0.1;
    final isGain = diffKg > 0.1;

    final percent = currentKg <= 0.1
        ? 0.0
        : (diffAbsKg / currentKg * 100.0).clamp(0.0, 99.0);
    final percentText = percent < 1 ? '1' : percent.round().toString();

    final bmiTarget = _calculateBmi(
      weightKg: targetKg,
      heightCm: profile.height,
    );
    final bmiText = bmiTarget <= 0 ? '--' : bmiTarget.toStringAsFixed(1);
    final bmiCategory = bmiTarget <= 0 ? '' : _bmiCategory(bmiTarget);

    String headline;
    if (isLoss) {
      headline = '🎯 $percentText% de perda de peso!';
    } else if (isGain) {
      headline = '🎯 $percentText% de ganho de peso!';
    } else {
      headline = '🎯 Peso estável!';
    }

    final diffAmount = _weightUseMetric
        ? diffAbsKg
        : (diffAbsKg * 2.2046226218);
    final diffUnit = _weightUseMetric ? 'kg' : 'lbs';

    String message;
    if (isLoss) {
      message =
          'Você vai perder ${diffAmount.toStringAsFixed(1)} $diffUnit para alcançar seu peso meta.';
    } else if (isGain) {
      message =
          'Você vai ganhar ${diffAmount.toStringAsFixed(1)} $diffUnit para alcançar seu peso meta.';
    } else {
      message = 'Você vai manter seu peso atual.';
    }
    if (bmiCategory.isNotEmpty) {
      message = '$message Seu IMC será $bmiText ($bmiCategory).';
    }

    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ... (Header Icon and Text remain same)
                    const SizedBox(height: 8),
                    const SizedBox(height: 8),
                    const _HeaderIcon(
                      assetPath: 'assets/images/icons/icon_target_3d.png',
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Qual é seu peso meta?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(child: _buildWeightUnitToggle()),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF93C5FD),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.auto_graph_rounded,
                              color: Color(0xFF3B82F6),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  headline,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF1D4ED8),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  message,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    height: 1.35,
                                    color: const Color(0xFF111827),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _BmiScale(bmi: bmiTarget),
                    const SizedBox(height: 22),
                    Text(
                      '$displayString $displayUnit',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        color: bmiTarget < 18.5
                            ? const Color(0xFF3B82F6) // Underweight: Blue
                            : bmiTarget < 25
                            ? const Color(0xFF4CAF50) // Normal: Green
                            : bmiTarget < 30
                            ? const Color(
                                0xFFF59E0B,
                              ) // Overweight: Yellow/Orange
                            : const Color(0xFFEF4444), // Obese: Red
                        letterSpacing: -1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Theme(
                            data: theme.copyWith(
                              scaffoldBackgroundColor: Colors.white,
                            ),
                            child: RulerPicker(
                              label: '',
                              unit: displayUnit,
                              value: rulerValue,
                              min: rulerMin,
                              max: rulerMax,
                              direction: Axis.horizontal,
                              showValue: false,
                              showIndicator: false,
                              labelBuilder: _weightUseMetric
                                  ? (val) => (val / 10).round().toString()
                                  : null,
                              onChanged: (value) {
                                final picked = value.round();
                                final double nextKg;
                                if (_weightUseMetric) {
                                  // picked is scaled x10 (e.g. 935 => 93.5)
                                  nextKg = picked / 10.0;
                                } else {
                                  // picked is lbs (e.g. 150)
                                  nextKg = _lbsToKg(picked);
                                }
                                notifier.updateTarget(targetWeight: nextKg);
                              },
                            ),
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: 3,
                              height: 65,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6),
                                borderRadius: BorderRadius.circular(1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.5),
                                    blurRadius: 2,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _canProceed()
                    ? () {
                        // Validation logic
                        final isLoseWeight =
                            profile.mainGoal == MainGoal.loseWeight;
                        final isGainWeight =
                            profile.mainGoal == MainGoal.buildMuscle;
                        final isMaintainWeight =
                            profile.mainGoal == MainGoal.maintain;
                        final current = profile.currentWeight;
                        final target = profile.targetWeight;
                        final diff = (target - current).abs();
                        final isClose = diff < 0.1; // 100g margin

                        if ((isLoseWeight ||
                                isGainWeight ||
                                isMaintainWeight) &&
                            isClose) {
                          if (isLoseWeight || isGainWeight) {
                            // Suggest Maintain Weight
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text(
                                  'Seu objetivo e meta de peso não combinam',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: Text(
                                  isLoseWeight
                                      ? 'Você escolheu Perder Peso mas sua meta de peso é próxima ao seu peso atual. Deseja continuar mudando seu objetivo para Manter Peso?'
                                      : 'Você escolheu Ganhar Peso mas sua meta de peso é próxima ao seu peso atual. Deseja continuar mudando seu objetivo para Manter Peso?',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      notifier.updateMainGoal(
                                        MainGoal.maintain,
                                      );
                                      _nextPage();
                                    },
                                    child: const Text('Continuar'),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            // Already Maintain Weight and close -> Valid
                            _nextPage();
                          }
                        } else if (isLoseWeight && target > current) {
                          // Suggest Gain Weight
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text(
                                'Seu objetivo e meta de peso não combinam',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: const Text(
                                'Você escolheu Perder Peso, mas sua meta de peso é maior que seu peso atual. Deseja continuar mudando seu objetivo para Ganhar Peso?',
                                style: TextStyle(fontSize: 14),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    notifier.updateMainGoal(
                                      MainGoal.buildMuscle,
                                    );
                                    _nextPage();
                                  },
                                  child: const Text('Continuar'),
                                ),
                              ],
                            ),
                          );
                        } else if (isGainWeight && target < current) {
                          // Suggest Lose Weight
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text(
                                'Seu objetivo e meta de peso não combinam',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: const Text(
                                'Você escolheu Ganhar Peso mas sua meta de peso é menor que seu peso atual. Deseja continuar mudando seu objetivo para Perder Peso?',
                                style: TextStyle(fontSize: 14),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    notifier.updateMainGoal(
                                      MainGoal.loseWeight,
                                    );
                                    _nextPage();
                                  },
                                  child: const Text('Continuar'),
                                ),
                              ],
                            ),
                          );
                        } else if (isMaintainWeight && target < current) {
                          // Suggest Lose Weight
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text(
                                'Seu objetivo e meta de peso não combinam',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: const Text(
                                'Você escolheu Manter Peso mas sua meta de peso é menor que seu peso atual. Deseja continuar mudando seu objetivo para Perder Peso?',
                                style: TextStyle(fontSize: 14),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    notifier.updateMainGoal(
                                      MainGoal.loseWeight,
                                    );
                                    _nextPage();
                                  },
                                  child: const Text('Continuar'),
                                ),
                              ],
                            ),
                          );
                        } else if (isMaintainWeight && target > current) {
                          // Suggest Gain Weight
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text(
                                'Seu objetivo e meta de peso não combinam',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: const Text(
                                'Você escolheu Manter Peso mas sua meta de peso é maior que seu peso atual. Deseja continuar mudando seu objetivo para Ganhar Peso?',
                                style: TextStyle(fontSize: 14),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    notifier.updateMainGoal(
                                      MainGoal.buildMuscle,
                                    );
                                    _nextPage();
                                  },
                                  child: const Text('Continuar'),
                                ),
                              ],
                            ),
                          );
                        } else {
                          // Normal flow
                          _nextPage();
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continuar',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityLevelStep(
    OnboardingNotifier notifier,
    UserProfile profile,
  ) {
    final isMale = profile.gender == Gender.male;

    String imageFor(ActivityLevel level) {
      final suffix = isMale ? 'male' : 'female';
      return switch (level) {
        ActivityLevel.sedentary =>
          'assets/images/activity_sedentary_$suffix.png',
        ActivityLevel.low => 'assets/images/activity_light_$suffix.png',
        ActivityLevel.active => 'assets/images/activity_moderate_$suffix.png',
        ActivityLevel.veryActive =>
          'assets/images/activity_very_active_$suffix.png',
      };
    }

    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 4),
            const _HeaderIcon(
              assetPath: 'assets/images/icons/icon_activity_3d.png',
              size: 44, // Slightly smaller icon
            ),
            const SizedBox(height: 4),
            Text(
              'Quão ativo você é\nno dia a dia?',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 24, // Smaller font to fit options
                fontWeight: FontWeight.w900,
                height: 1.15,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _DietAiActivityCard(
                      title: 'Sedentário',
                      isSelected:
                          profile.activityLevel == ActivityLevel.sedentary,
                      level: ActivityLevel.sedentary,
                      assetPath: imageFor(ActivityLevel.sedentary),
                      onTap: () =>
                          notifier.updateActivityLevel(ActivityLevel.sedentary),
                    ),
                    const SizedBox(height: 10),
                    _DietAiActivityCard(
                      title: 'Levemente ativo',
                      isSelected: profile.activityLevel == ActivityLevel.low,
                      level: ActivityLevel.low,
                      assetPath: imageFor(ActivityLevel.low),
                      onTap: () =>
                          notifier.updateActivityLevel(ActivityLevel.low),
                    ),
                    const SizedBox(height: 10),
                    _DietAiActivityCard(
                      title: 'Moderadamente ativo',
                      isSelected: profile.activityLevel == ActivityLevel.active,
                      level: ActivityLevel.active,
                      assetPath: imageFor(ActivityLevel.active),
                      onTap: () =>
                          notifier.updateActivityLevel(ActivityLevel.active),
                    ),
                    const SizedBox(height: 10),
                    _DietAiActivityCard(
                      title: 'Muito ativo',
                      isSelected:
                          profile.activityLevel == ActivityLevel.veryActive,
                      level: ActivityLevel.veryActive,
                      assetPath: imageFor(ActivityLevel.veryActive),
                      onTap: () => notifier.updateActivityLevel(
                        ActivityLevel.veryActive,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  notifier.saveDraft();
                  _nextPage();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continuar',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealisticGoalStep(UserProfile profile) {
    final currentKg = profile.currentWeight;
    final targetKg = profile.targetWeight;
    final diffKg = currentKg - targetKg;
    final isLoss = diffKg > 0.05;
    final isGain = diffKg < -0.05;

    final diffAbs = diffKg.abs();
    final diffValue = _weightUseMetric ? diffAbs : diffAbs * 2.2046226218;
    final diffUnit = _weightUseMetric ? 'kg' : 'lbs';

    final formatted = intl.NumberFormat('0.0', 'pt_BR').format(diffValue);

    String title;
    if (isLoss) {
      title =
          'Perder $formatted $diffUnit é uma\nmeta realista e é\nmais fácil do que você imagina!';
    } else if (isGain) {
      title =
          'Ganhar $formatted $diffUnit é uma\nmeta realista e é\nmais fácil do que você imagina!';
    } else {
      title =
          'Alcançar seu peso meta é uma\nmeta realista e é\nmais fácil do que você imagina!';
    }

    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                height: 1.15,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            const Expanded(child: RestrictiveDietsChart()),
            const SizedBox(height: 10),
            Text(
              'Metas realistas são mais fáceis de sustentar e reduzem o risco de efeito sanfona.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.4,
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continuar',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScienceAiStep(OnboardingNotifier notifier) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Text(
              'Seu progresso fica\nmais simples com\no Nutriz',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                height: 1.05,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Seu progresso de peso',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AspectRatio(
                  aspectRatio: 1.45,
                  child: const ScienceAiProgressChart(),
                ),
              ),
            ),
            Text(
              'No começo, o mais importante é criar ritmo. '
              'Quando você registra com consistência, fica muito mais fácil ajustar o dia e continuar.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.4,
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  notifier.saveDraft();
                  _nextPage();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continuar',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSilhouetteIcon(String emoji, double size, Color color) {
    return Transform.scale(
      scaleX: -1, // Flip to face right
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) =>
            LinearGradient(colors: [color, color]).createShader(bounds),
        child: Text(emoji, style: TextStyle(fontSize: size)),
      ),
    );
  }

  Widget _buildWeeklyGoalStep(
    OnboardingNotifier notifier,
    UserProfile profile,
  ) {
    const options = [0.1, 0.5, 1.0];

    final sign =
        (profile.targetWeight < profile.currentWeight - 0.05 ||
            profile.mainGoal == MainGoal.loseWeight)
        ? -1.0
        : (profile.targetWeight > profile.currentWeight + 0.05 ||
              profile.mainGoal == MainGoal.buildMuscle)
        ? 1.0
        : 0.0;

    double snap(double value) {
      if (value <= 0) return options[1];
      var best = options.first;
      var bestDiff = (value - best).abs();
      for (final o in options.skip(1)) {
        final d = (value - o).abs();
        if (d < bestDiff) {
          best = o;
          bestDiff = d;
        }
      }
      return best;
    }

    final currentAbs = profile.weeklyGoal.abs();
    final snapped = snap(currentAbs);

    if (!_weeklyGoalDefaulted) {
      _weeklyGoalDefaulted = true;
      final shouldDefault = profile.weeklyGoal == 0 && sign != 0;
      if (shouldDefault) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifier.updateTarget(weeklyGoal: sign * 0.5);
        });
      }
    }

    final selectedAbs = profile.weeklyGoal == 0 && sign == 0 ? 0.0 : snapped;
    final index = selectedAbs == 0.0
        ? 1
        : options
              .indexWhere((o) => (o - selectedAbs).abs() < 0.001)
              .clamp(0, options.length - 1);

    final isLoss = sign < 0;
    final title = isLoss
        ? 'Escolha a velocidade\nda perda de peso'
        : sign > 0
        ? 'Escolha a velocidade\ndo ganho de peso'
        : 'Escolha o ritmo\ndo seu progresso';

    final displayValue = selectedAbs == 0.0 ? 0.5 : selectedAbs;
    final displayUnit = _weightUseMetric ? 'kg' : 'lbs';
    final displayNumber = _weightUseMetric
        ? displayValue
        : displayValue * 2.2046226218;
    final formatted = intl.NumberFormat('0.0', 'pt_BR').format(displayNumber);

    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 6, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _HeaderIcon(
              assetPath: 'assets/images/icons/icon_speed_3d.png',
              size: 50,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                height: 1.1,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              '$formatted $displayUnit/semana',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF3B82F6),
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSilhouetteIcon(
                  '🐌',
                  40,
                  index == 0
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFF111827).withOpacity(0.2),
                ),
                _buildSilhouetteIcon(
                  '🐇',
                  40,
                  index == 1
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFF111827).withOpacity(0.2),
                ),
                _buildSilhouetteIcon(
                  '🐆',
                  40,
                  index == 2
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFF111827).withOpacity(0.2),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 10,
                activeTrackColor: const Color(0xFF3B82F6),
                inactiveTrackColor: const Color(0xFFE5E7EB),
                thumbColor: const Color(0xFF3B82F6),
                overlayColor: const Color(0xFF3B82F6).withOpacity(0.12),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
              ),
              child: Slider(
                value: index.toDouble(),
                min: 0,
                max: 2,
                divisions: 2,
                onChanged: (v) {
                  final pickedIndex = v.round().clamp(0, 2);
                  final pickedAbs = options[pickedIndex];
                  notifier.updateTarget(
                    weeklyGoal: sign == 0 ? 0 : sign * pickedAbs,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '0,1 $displayUnit',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  Text(
                    '0,5 $displayUnit',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  Text(
                    '1 $displayUnit',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Recomendado',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  notifier.saveDraft();
                  _nextPage();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continuar',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietAiBoostStep(OnboardingNotifier notifier) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: _HeaderIcon(
                assetPath: 'assets/images/icons/icon_diet_3d.png',
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Mais consistência.\nMenos esforço para\nseguir no plano.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                height: 1.15,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sem\nrotina',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  Text(
                    'Com\nNutriz',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    height: 70,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Mais\nconfusão',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF111827),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Container(
                    height: 110,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Mais\ncontrole',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              'O Nutriz reduz a fricção do dia a dia e ajuda você a manter consistência com mais facilidade.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.4,
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  notifier.saveDraft();
                  _nextPage();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continuar',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietaryPreferenceStep(
    OnboardingNotifier notifier,
    UserProfile profile,
  ) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 6, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _HeaderIcon(
              assetPath: 'assets/images/icons/icon_food_preference_3d.png',
              size: 50,
            ),
            const SizedBox(height: 10),
            Text(
              'Qual é sua\npreferência alimentar?',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                height: 1.15,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _DietAiOptionCard(
                      emoji: '🤖',
                      title: 'Inteligência Artificial',
                      subtitle: 'Nós escolhemos a melhor dieta para você',
                      isSelected:
                          profile.dietaryPreference ==
                          DietaryPreference.artificialIntelligence,
                      onTap: () => notifier.updateDietaryPreference(
                        DietaryPreference.artificialIntelligence,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _DietAiOptionCard(
                      emoji: '🥗',
                      title: 'Equilibrada',
                      subtitle: 'Todos os tipos de alimentos',
                      isSelected:
                          profile.dietaryPreference ==
                          DietaryPreference.balanced,
                      onTap: () => notifier.updateDietaryPreference(
                        DietaryPreference.balanced,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _DietAiOptionCard(
                      emoji: '💪',
                      title: 'Alta proteína',
                      subtitle: 'Para ganho de massa muscular',
                      isSelected:
                          profile.dietaryPreference ==
                          DietaryPreference.highProtein,
                      onTap: () => notifier.updateDietaryPreference(
                        DietaryPreference.highProtein,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _DietAiOptionCard(
                      emoji: '🍖',
                      title: 'Low carb',
                      subtitle: 'Baixo consumo de carboidratos',
                      isSelected:
                          profile.dietaryPreference ==
                          DietaryPreference.lowCarb,
                      onTap: () => notifier.updateDietaryPreference(
                        DietaryPreference.lowCarb,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _DietAiOptionCard(
                      emoji: '🥓',
                      title: 'Cetogênica',
                      subtitle: 'Gorduras saudáveis e pouco carboidrato',
                      isSelected:
                          profile.dietaryPreference == DietaryPreference.keto,
                      onTap: () => notifier.updateDietaryPreference(
                        DietaryPreference.keto,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _DietAiOptionCard(
                      emoji: '🌊',
                      title: 'Mediterrânea',
                      subtitle: 'Vegetais, azeite e peixes',
                      isSelected:
                          profile.dietaryPreference ==
                          DietaryPreference.mediterranean,
                      onTap: () => notifier.updateDietaryPreference(
                        DietaryPreference.mediterranean,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _DietAiOptionCard(
                      emoji: '🥩',
                      title: 'Paleo',
                      subtitle: 'Comida de verdade, sem processados',
                      isSelected:
                          profile.dietaryPreference == DietaryPreference.paleo,
                      onTap: () => notifier.updateDietaryPreference(
                        DietaryPreference.paleo,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _DietAiOptionCard(
                      emoji: '🥑',
                      title: 'Baixa gordura',
                      subtitle: 'Foco em redução de gorduras',
                      isSelected:
                          profile.dietaryPreference == DietaryPreference.lowFat,
                      onTap: () => notifier.updateDietaryPreference(
                        DietaryPreference.lowFat,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _DietAiOptionCard(
                      emoji: '🍽️',
                      title: 'Dash',
                      subtitle: 'Para saúde do coração',
                      isSelected:
                          profile.dietaryPreference == DietaryPreference.dash,
                      onTap: () => notifier.updateDietaryPreference(
                        DietaryPreference.dash,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _DietAiOptionCard(
                      emoji: '🐟',
                      title: 'Pescetariano',
                      subtitle: 'Vegetais, ovos, laticínios e peixes',
                      isSelected:
                          profile.dietaryPreference ==
                          DietaryPreference.pescetarian,
                      onTap: () => notifier.updateDietaryPreference(
                        DietaryPreference.pescetarian,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _DietAiOptionCard(
                      emoji: '🥦',
                      title: 'Vegetariano',
                      subtitle: 'Vegetais, ovos e laticínios',
                      isSelected:
                          profile.dietaryPreference ==
                          DietaryPreference.vegetarian,
                      onTap: () => notifier.updateDietaryPreference(
                        DietaryPreference.vegetarian,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _DietAiOptionCard(
                      emoji: '🌱',
                      title: 'Vegano',
                      subtitle: 'Apenas alimentos de origem vegetal',
                      isSelected:
                          profile.dietaryPreference == DietaryPreference.vegan,
                      onTap: () => notifier.updateDietaryPreference(
                        DietaryPreference.vegan,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  notifier.saveDraft();
                  _nextPage();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continuar',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthConditionsStep(
    OnboardingNotifier notifier,
    UserProfile profile,
  ) {
    // Reuse `badHabits` list as a lightweight store; keep conditions namespaced.
    const prefix = 'hc:';
    final selected = profile.badHabits
        .where((e) => e.startsWith(prefix))
        .toSet();

    bool isSelected(String id) => selected.contains('$prefix$id');

    void toggle(String id) {
      final next = List<String>.from(profile.badHabits);
      final key = '$prefix$id';
      if (next.contains(key)) {
        next.remove(key);
      } else {
        next.add(key);
      }
      notifier.updateBadHabits(next);
    }

    void clearAll() {
      final next = profile.badHabits
          .where((e) => !e.startsWith(prefix))
          .toList();
      notifier.updateBadHabits(next);
    }

    final noneSelected = selected.isEmpty;

    const items = <_HealthConditionItem>[
      _HealthConditionItem(
        id: 'high_bp',
        emoji: '🩸',
        title: 'Pressão alta',
        info: 'Ajuda a adaptar sugestões nutricionais.',
      ),
      _HealthConditionItem(
        id: 'diabetes',
        emoji: '🌀',
        title: 'Diabetes',
        info: 'Priorizamos refeições que controlam a glicemia.',
      ),
      _HealthConditionItem(
        id: 'high_cholesterol',
        emoji: '🍟',
        title: 'Colesterol alto',
        info: 'Focamos em gorduras saudáveis para o coração.',
      ),
      _HealthConditionItem(
        id: 'other',
        emoji: '❓',
        title: 'Outro',
        info: 'Você pode refinar isso depois no perfil.',
      ),
    ];

    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 6),
            const SizedBox(height: 6),
            const _HeaderIcon(
              assetPath: 'assets/images/icons/icon_health_3d.png',
            ),
            const SizedBox(height: 14),
            Text(
              'Você tem alguma condição\nde saúde?',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                height: 1.15,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _DietAiRestrictionCard(
                      title: 'Nenhuma',
                      emoji: '✓',
                      isSelected: noneSelected,
                      onTap: clearAll,
                      infoText:
                          'Nenhuma condição. Você pode alterar isso depois.',
                    ),
                    const SizedBox(height: 10),
                    for (final item in items) ...[
                      _DietAiRestrictionCard(
                        title: item.title,
                        emoji: item.emoji,
                        isSelected: isSelected(item.id),
                        onTap: () => toggle(item.id),
                        infoText: item.info,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  notifier.saveDraft();
                  _nextPage();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThankYouStep(OnboardingNotifier notifier) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 56),
            Center(
              child:
                  ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF3B82F6), // Blue
                            Color(0xFF14B8A6), // Teal
                          ],
                        ).createShader(bounds),
                        child: const Icon(
                          Icons.handshake_rounded,
                          size: 100,
                          color: Colors.white,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(duration: 600.ms, curve: Curves.easeOutBack)
                      .shake(
                        delay: 600.ms,
                        duration: 1000.ms,
                        hz: 3,
                        rotation: 0.05,
                      ) // Suave
                      .fadeOut(delay: 2200.ms, duration: 700.ms),
            ),
            const SizedBox(height: 24),
            Text(
              'Obrigado por\nconfiar em nós!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                height: 1.15,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Agora vamos personalizar o NutriZ para você...',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.4,
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            const Center(
              child: Icon(
                Icons.lock_rounded,
                color: Color(0xFFD1D5DB),
                size: 22,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Sua privacidade e segurança são nossa prioridade.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                height: 1.4,
                color: const Color(0xFF111827),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Suas informações pessoais\nserão mantidas seguras e protegidas.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                height: 1.35,
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  notifier.saveDraft();
                  _nextPage();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameStep(OnboardingNotifier notifier, UserProfile profile) {
    final canContinue = profile.name.trim().isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 6),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.badge_outlined,
                            color: Color(0xFF111827),
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Qual é o seu nome?',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const Spacer(),
                      TextField(
                        controller: _nameController,
                        textAlign: TextAlign.center,
                        textInputAction: TextInputAction.done,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Nome',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF9CA3AF),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF86EFAC),
                              width: 2,
                            ),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF4CAF50),
                              width: 2,
                            ),
                          ),
                        ),
                        onChanged: notifier.updateName,
                        onSubmitted: (_) {
                          notifier.saveDraft();
                          if (!mounted) return;
                          if (ref
                              .read(onboardingNotifierProvider)
                              .name
                              .trim()
                              .isEmpty) {
                            return;
                          }
                          _goToStep(_StepKey.rating);
                        },
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: canContinue
                              ? () {
                                  notifier.saveDraft();
                                  _goToStep(_StepKey.rating);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(
                              0xFF4CAF50,
                            ).withOpacity(0.35),
                            disabledForegroundColor: Colors.white.withOpacity(
                              0.8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Continuar',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRatingStep(OnboardingNotifier notifier) {
    Widget stars({double size = 16}) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          5,
          (_) => Icon(
            Icons.star_rounded,
            color: const Color(0xFFF59E0B),
            size: size,
          ),
        ),
      );
    }

    Widget avatar(String label, Color color) {
      return CircleAvatar(
        radius: 16,
        backgroundColor: color,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      );
    }

    Widget testimonial({
      required String initials,
      required String name,
      required String text,
      String? assetPath,
    }) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE5E7EB),
                image: assetPath != null
                    ? DecorationImage(
                        image: AssetImage(assetPath),
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      )
                    : null,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: assetPath == null
                  ? Text(
                      initials,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF374151),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF111827),
                          ),
                        ),
                      ),
                      stars(size: 14),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    text,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        'Avalie-nos',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '4.7',
                            style: GoogleFonts.inter(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(width: 8),
                          stars(size: 18),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('❮'),
                          const SizedBox(width: 10),
                          Text(
                            '+50k Avaliações',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text('❯'),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'O NutriZ foi criado para pessoas exatamente\ncomo você',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          height: 1.25,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: SizedBox(
                          height: 34,
                          width: 190,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                child: avatar('M', const Color(0xFF60A5FA)),
                              ),
                              Positioned(
                                left: 22,
                                child: avatar('A', const Color(0xFF34D399)),
                              ),
                              Positioned(
                                left: 44,
                                child: avatar('J', const Color(0xFFF472B6)),
                              ),
                              Positioned(
                                left: 66,
                                child: avatar('C', const Color(0xFFFBBF24)),
                              ),
                              Positioned(
                                left: 88,
                                child: avatar('R', const Color(0xFF818CF8)),
                              ),
                              Positioned(
                                left: 110,
                                child: avatar('S', const Color(0xFFFB7185)),
                              ),
                              Positioned(
                                left: 132,
                                child: avatar('D', const Color(0xFF22C55E)),
                              ),
                              Positioned(
                                left: 154,
                                child: avatar('K', const Color(0xFF111827)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Mais de 1,5 milhões de usuários',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              testimonial(
                                initials: 'AM',
                                name: 'Ana Maria',
                                assetPath: 'assets/images/gender_woman.png',
                                text:
                                    'Perdi 10 kg em apenas 3 meses! Estava quase começando Ozempic, mas dei uma chance a esse app e funcionou!',
                              ),
                              const SizedBox(height: 12),
                              testimonial(
                                initials: 'CA',
                                name: 'Carlos André',
                                assetPath: 'assets/images/gender_man.png',
                                text:
                                    'Como não preciso mais registrar cada alimento manualmente, finalmente sobrou tempo pra treinar depois do trabalho.',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => _goToCalculatingFromRating(notifier),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Continuar',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAllDoneStep(OnboardingNotifier notifier, UserProfile profile) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 18),
            Text(
              'Tudo pronto. Agora vamos\nregistrar sua primeira refeição.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                height: 1.12,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Background glow
                    Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF22C55E).withValues(alpha: 0.2),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1.1, 1.1),
                          duration: 2.seconds,
                          curve: Curves.easeInOutSine,
                        ),

                    // Main icon plate
                    Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(
                                0xFF22C55E,
                              ).withValues(alpha: 0.2),
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF22C55E,
                                ).withValues(alpha: 0.15),
                                blurRadius: 32,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('🥗', style: TextStyle(fontSize: 64)),
                          ),
                        )
                        .animate()
                        .scale(
                          begin: const Offset(0, 0),
                          curve: Curves.easeOutBack,
                          duration: 800.ms,
                        )
                        .then(delay: 200.ms)
                        .shimmer(
                          duration: 1.seconds,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),

                    // Floating element 1: Sparkles
                    Positioned(
                      top: -10,
                      right: 10,
                      child: const Text('✨', style: TextStyle(fontSize: 32))
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .moveY(
                            begin: 0,
                            end: -15,
                            duration: 1.5.seconds,
                            curve: Curves.easeInOut,
                          )
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1.2, 1.2),
                            duration: 1.5.seconds,
                          )
                          .fadeIn(),
                    ),

                    // Floating element 2: Camera (for AI scanning)
                    Positioned(
                      bottom: 10,
                      left: -10,
                      child:
                          Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  '📸',
                                  style: TextStyle(fontSize: 28),
                                ),
                              )
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .moveY(
                                begin: 0,
                                end: 12,
                                duration: 2.seconds,
                                curve: Curves.easeInOut,
                              )
                              .rotate(
                                begin: -0.05,
                                end: 0.05,
                                duration: 3.seconds,
                              )
                              .fadeIn(delay: 300.ms),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  unawaited(notifier.saveDraft());
                  unawaited(
                    ref.read(analyticsServiceProvider).logEvent(
                      'first_meal_cta_tap',
                      {
                        'source': 'onboarding_all_done',
                        'meal_type': 'suggested',
                      },
                    ),
                  );
                  await _finishOnboarding(nextRoute: '/diary?firstRun=1');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continuar',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodLoggingMethodStep(
    OnboardingNotifier notifier,
    UserProfile profile,
  ) {
    final selected = profile.foodLoggingMethod;

    Widget option({
      required String title,
      required FoodLoggingMethod method,
      required String assetPath,
      bool highlighted = false,
    }) {
      final isSelected = selected == method;
      final bg = isSelected || highlighted
          ? const Color(0xFF22C55E)
          : const Color(0xFFE5E7EB);
      final fg = isSelected || highlighted
          ? Colors.white
          : const Color(0xFF111827);

      return InkWell(
        onTap: () {
          notifier.updateFoodLoggingMethod(method);
          notifier.saveDraft();
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.only(left: 16, right: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: fg,
                  ),
                ),
              ),
              SizedBox(
                width: 56,
                height: 40,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: (isSelected || highlighted)
                            ? Colors.white.withOpacity(0.2)
                            : const Color(0xFFF3F4F6),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.image_outlined,
                          size: 20,
                          color: (isSelected || highlighted)
                              ? Colors.white.withOpacity(0.9)
                              : const Color(0xFF9CA3AF),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.menu_book_outlined,
                  color: Color(0xFF111827),
                  size: 18,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Como você quer registrar\nsua alimentação?',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                height: 1.12,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 18),
            option(
              title: 'Agora não',
              method: FoodLoggingMethod.notNow,
              assetPath: 'assets/images/log_method_not_now.png',
              highlighted: true,
            ),
            const SizedBox(height: 12),
            option(
              title: 'Selecionar da galeria',
              method: FoodLoggingMethod.gallery,
              assetPath: 'assets/images/log_method_gallery.png',
            ),
            const SizedBox(height: 10),
            option(
              title: 'Tirar foto do alimento',
              method: FoodLoggingMethod.photo,
              assetPath: 'assets/images/log_method_photo.png',
            ),
            const SizedBox(height: 10),
            option(
              title: 'Escanear código de barras',
              method: FoodLoggingMethod.barcode,
              assetPath: 'assets/images/log_method_barcode.png',
            ),
            const SizedBox(height: 10),
            option(
              title: 'Digitar o que comeu',
              method: FoodLoggingMethod.type,
              assetPath: 'assets/images/log_method_type.png',
            ),
            const SizedBox(height: 10),
            option(
              title: 'Dizer o que comeu',
              method: FoodLoggingMethod.voice,
              assetPath: 'assets/images/log_method_voice.png',
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  unawaited(notifier.saveDraft());
                  await _finishOnboarding(nextRoute: '/diary?firstRun=1');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continuar',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadHabitsStep(OnboardingNotifier notifier, UserProfile profile) {
    final restrictions = profile.badHabits;
    final noneSelected = restrictions.isEmpty;

    void setNone() => notifier.updateBadHabits(const []);

    void toggle(String id) {
      final next = List<String>.from(restrictions);
      if (next.contains(id)) {
        next.remove(id);
      } else {
        next.add(id);
      }
      notifier.updateBadHabits(next);
    }

    const items = <_RestrictionItem>[
      _RestrictionItem(
        id: 'vegetarian',
        emoji: '🌱',
        title: 'Vegetariano',
        info: 'Evita carne. Pode incluir ovos e laticínios.',
      ),
      _RestrictionItem(
        id: 'vegan',
        emoji: '🌿',
        title: 'Vegano',
        info: 'Evita todos os alimentos de origem animal.',
      ),
      _RestrictionItem(
        id: 'gluten_free',
        emoji: '🚫🌾',
        title: 'Sem glúten',
        info: 'Evita trigo, cevada e centeio (Doença celíaca/Intolerância).',
      ),
      _RestrictionItem(
        id: 'dairy_free',
        emoji: '🚫🥛',
        title: 'Sem lactose',
        info: 'Evita leite e laticínios (Intolerância à lactose).',
      ),
      _RestrictionItem(
        id: 'no_red_meat',
        emoji: '🥩',
        title: 'Não gosto de carne vermelha',
        info: 'Evita carne vermelha (boi, porco, etc).',
      ),
      _RestrictionItem(
        id: 'nut_allergy',
        emoji: '🥜',
        title: 'Alergia a nozes',
        info: 'Evita amendoim, castanhas e derivados.',
      ),
      _RestrictionItem(
        id: 'religious',
        emoji: '🙏',
        title: 'Restrição religiosa',
        info: 'Dietas baseadas em crenças (Kosher, Halal, etc).',
      ),
      _RestrictionItem(
        id: 'other',
        emoji: '❓',
        title: 'Outro',
        info: 'Outras restrições não listadas aqui.',
      ),
    ];

    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 6),
            const _HeaderIcon(
              assetPath: 'assets/images/icons/icon_diet_3d.png',
            ),
            const SizedBox(height: 14),
            Text(
              'Você tem alguma restrição alimentar,\nalergia ou alimento que não gosta?',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                height: 1.15,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _DietAiRestrictionCard(
                      title: 'Nenhuma',
                      emoji: '✓',
                      isSelected: noneSelected,
                      onTap: setNone,
                      infoText:
                          'Nenhuma restrição. Você pode alterar isso depois.',
                    ),
                    const SizedBox(height: 10),
                    for (final item in items) ...[
                      _DietAiRestrictionCard(
                        title: item.title,
                        emoji: item.emoji,
                        isSelected: restrictions.contains(item.id),
                        onTap: () => toggle(item.id),
                        infoText: item.info,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  notifier.saveDraft();
                  _nextPage();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continuar',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _requestNotificationsPermission() async {
    try {
      final granted = await _notificationsChannel.invokeMethod<bool>(
        'requestPermission',
      );
      return granted ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _showPushPermissionDialog(OnboardingNotifier notifier) async {
    if (!mounted) return;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.notifications_none_rounded, size: 28),
                const SizedBox(height: 10),
                Text(
                  'Allow Nutriz to send you\nnotifications?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _requestNotificationsPermission();
                      if (context.mounted) Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE0E7FF),
                      foregroundColor: const Color(0xFF111827),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Allow',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE0E7FF),
                      foregroundColor: const Color(0xFF111827),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Don't allow",
                      style: GoogleFonts.inter(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) return;
    unawaited(notifier.saveDraft());
    _nextPage();

    // Silence unused variable analysis; the result is not used yet but might be
    // useful later for analytics.
    // ignore: unused_local_variable
    final _ = result;
  }

  Widget _buildPushNotificationsStep(OnboardingNotifier notifier) {
    if (!_pushPromptShown) {
      _pushPromptShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _currentStepKey == _StepKey.pushNotifications) {
          _showPushPermissionDialog(notifier);
        }
      });
    }

    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 66),
            Text(
              'Alcance suas metas com\nnotificações',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                height: 1.15,
                color: const Color(0xFF111827),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _showPushPermissionDialog(notifier),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continuar',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtraDetailsStep(
    OnboardingNotifier notifier,
    UserProfile profile,
  ) {
    final suffix = profile.gender == Gender.male ? 'male' : 'female';
    final allSetAsset = 'assets/images/goal_maintain_$suffix.png';
    final addMoreAsset = 'assets/images/goal_lose_weight_$suffix.png';

    Widget option({
      required String title,
      required String assetPath,
      required bool selected,
      required VoidCallback onTap,
    }) {
      final bg = selected ? const Color(0xFF4CAF50) : const Color(0xFFF3F4F6);
      final fg = selected ? Colors.white : const Color(0xFF111827);

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: 200.ms,
            height: 90,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF4CAF50).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                const SizedBox(width: 24),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: fg,
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  height: 90,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: Image.asset(
                      assetPath,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 6),
            Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.playlist_add_check_circle_outlined,
                  color: Color(0xFF111827),
                  size: 18,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Deseja adicionar mais detalhes para nossa IA incluir no seu plano?',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                height: 1.2,
                color: const Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 32),
            option(
              title: 'Obrigado, estou pronto',
              assetPath: allSetAsset,
              selected: !_extraDetailsAddMore,
              onTap: () => setState(() => _extraDetailsAddMore = false),
            ),
            const SizedBox(height: 16),
            option(
              title: 'Adicionar mais detalhes',
              assetPath: addMoreAsset,
              selected: _extraDetailsAddMore,
              onTap: () => setState(() => _extraDetailsAddMore = true),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (_stepTransitionLocked) return;
                  if (_extraDetailsContinueInProgress) return;
                  _extraDetailsContinueInProgress = true;
                  notifier.saveDraft();
                  if (_extraDetailsAddMore) {
                    _logOnboardingSignal('extra_details_branch', {
                      'branch': 'add_more_details',
                    });
                    _goToStep(_StepKey.water);
                    return;
                  }
                  _logOnboardingSignal('extra_details_branch', {
                    'branch': 'no_more_details',
                  });
                  _goToStep(_StepKey.name);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continuar',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterStep(OnboardingNotifier notifier, UserProfile profile) {
    return OnboardingStepContainer(
      title: 'Consumo de água',
      subtitle: 'Quanta água você bebe por dia?',
      child: SingleChildScrollView(
        child: Column(
          children: [
            ActivityLevelCard(
              emoji: '💧',
              title: 'Menos de 1 Litro',
              description: 'Pouca hidratação',
              isSelected: profile.waterIntake == WaterIntake.lessThan1L,
              onTap: () => notifier.updateWaterIntake(WaterIntake.lessThan1L),
            ),
            const SizedBox(height: 12),
            ActivityLevelCard(
              emoji: '🥤',
              title: '1 a 2 Litros',
              description: 'Média recomendada',
              isSelected: profile.waterIntake == WaterIntake.oneToTwoL,
              onTap: () => notifier.updateWaterIntake(WaterIntake.oneToTwoL),
            ),
            const SizedBox(height: 12),
            ActivityLevelCard(
              emoji: '🌊',
              title: '2 a 3 Litros',
              description: 'Ótima hidratação',
              isSelected: profile.waterIntake == WaterIntake.twoToThreeL,
              onTap: () => notifier.updateWaterIntake(WaterIntake.twoToThreeL),
            ),
            const SizedBox(height: 12),
            ActivityLevelCard(
              emoji: '🐳',
              title: 'Mais de 3 Litros',
              description: 'Hidratação de atleta',
              isSelected: profile.waterIntake == WaterIntake.moreThan3L,
              onTap: () => notifier.updateWaterIntake(WaterIntake.moreThan3L),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepStep(OnboardingNotifier notifier, UserProfile profile) {
    return OnboardingStepContainer(
      title: 'Qualidade do sono',
      subtitle: 'Quantas horas você dorme por noite?',
      child: SingleChildScrollView(
        child: Column(
          children: [
            ActivityLevelCard(
              emoji: '😫',
              title: 'Menos de 5 horas',
              description: 'Descanso insuficiente',
              isSelected: profile.sleepDuration == SleepDuration.lessThan5,
              onTap: () =>
                  notifier.updateSleepDuration(SleepDuration.lessThan5),
            ),
            const SizedBox(height: 12),
            ActivityLevelCard(
              emoji: '😐',
              title: '5 a 6 horas',
              description: 'Pode melhorar',
              isSelected: profile.sleepDuration == SleepDuration.fiveToSix,
              onTap: () =>
                  notifier.updateSleepDuration(SleepDuration.fiveToSix),
            ),
            const SizedBox(height: 12),
            ActivityLevelCard(
              emoji: '🙂',
              title: '7 a 8 horas',
              description: 'Recomendado',
              isSelected: profile.sleepDuration == SleepDuration.sevenToEight,
              onTap: () =>
                  notifier.updateSleepDuration(SleepDuration.sevenToEight),
            ),
            const SizedBox(height: 12),
            ActivityLevelCard(
              emoji: '😴',
              title: 'Mais de 8 horas',
              description: 'Muito descanso',
              isSelected: profile.sleepDuration == SleepDuration.moreThan8,
              onTap: () =>
                  notifier.updateSleepDuration(SleepDuration.moreThan8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivationStep(
    OnboardingNotifier notifier,
    UserProfile profile,
  ) {
    return OnboardingStepContainer(
      title: 'O que te motiva?',
      subtitle: 'Selecione todas que se aplicam',
      child: SingleChildScrollView(
        child: Column(
          children: [
            _MultiSelectCard(
              title: 'Sentir-se mais saudável',
              isSelected: profile.motivations.contains('health'),
              onTap: () => notifier.toggleMotivation('health'),
            ),
            const SizedBox(height: 12),
            _MultiSelectCard(
              title: 'Melhorar a aparência',
              isSelected: profile.motivations.contains('appearance'),
              onTap: () => notifier.toggleMotivation('appearance'),
            ),
            const SizedBox(height: 12),
            _MultiSelectCard(
              title: 'Ter mais energia',
              isSelected: profile.motivations.contains('energy'),
              onTap: () => notifier.toggleMotivation('energy'),
            ),
            const SizedBox(height: 12),
            _MultiSelectCard(
              title: 'Aumentar a autoestima',
              isSelected: profile.motivations.contains('self_esteem'),
              onTap: () => notifier.toggleMotivation('self_esteem'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatingStep(OnboardingNotifier notifier) {
    return _CalculatingStepWrapper(
      notifier: notifier,
      startCalculation: _startCalculation,
      forceComplete: () {
        unawaited(_onCalculatingStepComplete(notifier));
      },
    );
  }

  Widget _buildResultsStep(UserProfile profile) {
    return OnboardingStepContainer(
      title: 'Sua meta de hoje está pronta',
      subtitle:
          'Agora registre sua primeira refeição para ver o que ainda falta no seu dia.',
      child: SingleChildScrollView(
        child: Column(
          children: [
            CalorieResultDisplay(
              calories: profile.calculatedCalories,
              protein: profile.proteinGrams,
              carbs: profile.carbsGrams,
              fat: profile.fatGrams,
            ),
            const SizedBox(height: 32),
            if (profile.weeksToGoal != null && profile.weeksToGoal! > 0)
              TimeEstimateWidget(
                currentWeight: profile.currentWeight,
                targetWeight: profile.targetWeight,
                weeksToGoal: profile.weeksToGoal!,
                estimatedDate: profile.estimatedGoalDate ?? DateTime.now(),
              ),
            const SizedBox(height: 16),
            Text(
              'Você pode editar suas metas a qualquer momento no Perfil.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            if (!widget.isEditMode) ...[
              const SizedBox(height: 32),
              SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: () {
                        ref.read(analyticsServiceProvider).logEvent(
                          'first_meal_cta_tap',
                          {
                            'source': 'onboarding_result',
                            'meal_type': 'suggested',
                          },
                        );
                        _finishOnboarding(nextRoute: '/diary?firstRun=1');
                      },
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Registrar minha 1ª refeição',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  )
                  .animate(delay: 800.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2, duration: 400.ms),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProUpsellStep() {
    return OfferPaywallScreen(
      onClose: () => _goToStep(_StepKey.allDone),
      onSuccess: () => _goToStep(_StepKey.allDone),
    );
  }

  Widget _buildStep(
    _StepKey key,
    OnboardingNotifier notifier,
    UserProfile profile,
  ) {
    switch (key) {
      case _StepKey.welcome:
        return _buildWelcomeStep();
      case _StepKey.gender:
        return _buildGenderStep(notifier, profile);
      case _StepKey.mainGoal:
        return _buildMainGoalStep(notifier, profile);
      case _StepKey.commitment:
        return _buildCommitmentStep(notifier, profile);
      case _StepKey.birthDate:
        return _buildBirthDateStep(notifier, profile);
      case _StepKey.height:
        return _buildHeightStep(notifier, profile);
      case _StepKey.currentWeight:
        return _buildCurrentWeightStep(notifier, profile);
      case _StepKey.targetWeight:
        return _buildTargetWeightStep(notifier, profile);
      case _StepKey.realisticGoal:
        return _buildRealisticGoalStep(profile);
      case _StepKey.activityLevel:
        return _buildActivityLevelStep(notifier, profile);
      case _StepKey.scienceAi:
        return _buildScienceAiStep(notifier);
      case _StepKey.weeklyGoal:
        return _buildWeeklyGoalStep(notifier, profile);
      case _StepKey.dietAiBoost:
        return _buildDietAiBoostStep(notifier);
      case _StepKey.dietaryPreference:
        return _buildDietaryPreferenceStep(notifier, profile);
      case _StepKey.healthConditions:
        return _buildHealthConditionsStep(notifier, profile);
      case _StepKey.thankYou:
        return _buildThankYouStep(notifier);
      case _StepKey.pushNotifications:
        return _buildPushNotificationsStep(notifier);
      case _StepKey.extraDetails:
        return _buildExtraDetailsStep(notifier, profile);
      case _StepKey.name:
        return _buildNameStep(notifier, profile);
      case _StepKey.rating:
        return _buildRatingStep(notifier);
      case _StepKey.allDone:
        return _buildAllDoneStep(notifier, profile);
      case _StepKey.foodLoggingMethod:
        return _buildFoodLoggingMethodStep(notifier, profile);
      case _StepKey.badHabits:
        return _buildBadHabitsStep(notifier, profile);
      case _StepKey.water:
        return _buildWaterStep(notifier, profile);
      case _StepKey.sleep:
        return _buildSleepStep(notifier, profile);
      case _StepKey.motivation:
        return _buildMotivationStep(notifier, profile);
      case _StepKey.calculating:
        return _buildCalculatingStep(notifier);
      case _StepKey.results:
        return _buildResultsStep(profile);
      case _StepKey.proUpsell:
        return _buildProUpsellStep();
    }
  }
}

enum _StepKey {
  welcome,
  gender,
  mainGoal,
  commitment,

  birthDate,
  height,
  currentWeight,
  targetWeight,
  realisticGoal,
  activityLevel,
  scienceAi,
  weeklyGoal,
  dietAiBoost,
  dietaryPreference,
  healthConditions,
  thankYou,
  pushNotifications,
  extraDetails,
  name,
  rating,
  allDone,
  foodLoggingMethod,
  badHabits,
  water,
  sleep,
  motivation,
  calculating,
  results,
  proUpsell,
}

class _BmiScale extends StatelessWidget {
  final double bmi;

  const _BmiScale({required this.bmi});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: CustomPaint(
        painter: _BmiScalePainter(bmi: bmi),
        size: Size.infinite,
      ),
    );
  }
}

class _BmiScalePainter extends CustomPainter {
  final double bmi;

  _BmiScalePainter({required this.bmi});

  @override
  void paint(Canvas canvas, Size size) {
    const min = 15.0;
    const max = 40.0;
    final clamped = bmi.isFinite ? bmi.clamp(min, max) : min;

    final w = size.width;
    final y = 14.0; // Bar vertical center

    // Map BMI values to X coordinates
    double getX(double val) {
      final t = (val - min) / (max - min);
      return w * t.clamp(0.0, 1.0);
    }

    // Segments
    // < 18.5 (Underweight)
    final x18_5 = getX(18.5);
    final x25 = getX(25.0);
    final x30 = getX(30.0);
    final x35 = getX(35.0);

    final linePaint = Paint()
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw background segments
    // We draw slightly overlapping lines to simulate a continuous bar
    // 1. Underweight (Blue)
    linePaint.color = const Color(0xFF60A5FA);
    canvas.drawLine(Offset(0, y), Offset(x18_5, y), linePaint);

    // 2. Normal (Green)
    linePaint.color = const Color(0xFF4CAF50);
    canvas.drawLine(Offset(x18_5, y), Offset(x25, y), linePaint);

    // 3. Overweight (Yellow/Orange)
    linePaint.color = const Color(0xFFFACC15);
    canvas.drawLine(Offset(x25, y), Offset(x30, y), linePaint);

    // 4. Obese (Orange/Red)
    linePaint.color = const Color(0xFFFB923C);
    canvas.drawLine(Offset(x30, y), Offset(x35, y), linePaint);

    // 5. Extremely Obese (Red)
    linePaint.color = const Color(0xFFEF4444);
    canvas.drawLine(Offset(x35, y), Offset(w, y), linePaint);

    // Draw Ticks & Labels
    final tickPaint = Paint()
      ..color = const Color(0xFF1F2937)
      ..strokeWidth = 1.5;

    final textStyle = GoogleFonts.inter(
      fontSize: 9,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF6B7280),
    );

    void drawTick(double val, String label) {
      final x = getX(val);
      // Tick
      canvas.drawLine(Offset(x, y - 6), Offset(x, y + 6), tickPaint);
      // Label
      final painter = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, Offset(x - painter.width / 2, y - 18));
    }

    drawTick(18.5, '18.5');
    drawTick(25.0, '25.0');
    drawTick(30.0, '30.0');
    drawTick(35.0, '35.0');

    // Category labels bottom
    final catStyle = GoogleFonts.inter(
      fontSize: 8,
      fontWeight: FontWeight.w500,
      color: const Color(0xFF9CA3AF),
    );

    void drawCat(String text, double start, double end) {
      final center = (getX(start) + getX(end)) / 2;
      final painter = TextPainter(
        text: TextSpan(text: text, style: catStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      // Don't draw if it doesn't fit well (too crowded)
      if (painter.width > (getX(end) - getX(start)) + 10) return;

      painter.paint(canvas, Offset(center - painter.width / 2, y + 8));
    }

    drawCat('Abaixo', min, 18.5);
    drawCat('Normal', 18.5, 25.0);
    drawCat('Sobrepeso', 25.0, 30.0);
    drawCat('Obeso', 30.0, 35.0);
    drawCat('Extremo', 35.0, max);

    // Current Value Marker
    final cx = getX(clamped);
    final markerPaint = Paint()
      ..color = const Color(0xFF111827)
      ..style = PaintingStyle.fill;

    // Triangle pointing down
    final path = Path();
    path.moveTo(cx, y - 5);
    path.lineTo(cx - 5, y - 12);
    path.lineTo(cx + 5, y - 12);
    path.close();
    canvas.drawPath(path, markerPaint);
  }

  @override
  bool shouldRepaint(covariant _BmiScalePainter oldDelegate) {
    return bmi != oldDelegate.bmi;
  }
}

class _DietAiActivityCard extends StatelessWidget {
  final String title;
  final bool isSelected;
  final ActivityLevel level;
  final String assetPath;
  final VoidCallback onTap;

  const _DietAiActivityCard({
    required this.title,
    required this.isSelected,
    required this.level,
    required this.assetPath,
    required this.onTap,
  });

  String _emoji() {
    return switch (level) {
      ActivityLevel.sedentary => '🛋️',
      ActivityLevel.low => '🚶',
      ActivityLevel.active => '🏃',
      ActivityLevel.veryActive => '🔥',
    };
  }

  String _infoText() {
    return switch (level) {
      ActivityLevel.sedentary =>
        'Pouco ou nenhum exercício. A maior parte do dia é sentada(o) ou com pouca movimentação.',
      ActivityLevel.low =>
        'Movimenta-se levemente no dia a dia e faz exercícios leves 1–3 vezes por semana.',
      ActivityLevel.active =>
        'Exercícios moderados 3–5 vezes por semana ou rotina diária bem ativa.',
      ActivityLevel.veryActive =>
        'Treinos intensos 6–7 vezes por semana ou trabalho fisicamente exigente.',
    };
  }

  ({Alignment alignment, double widthFactor, double scale, double yOffset})
  _imageTuning() {
    return switch (level) {
      ActivityLevel.sedentary => (
        alignment: Alignment.centerRight,
        widthFactor: 0.78,
        scale: 1.55,
        yOffset: 2,
      ),
      ActivityLevel.low => (
        alignment: Alignment.bottomRight,
        widthFactor: 0.82,
        scale: 1.65,
        yOffset: 6,
      ),
      ActivityLevel.active => (
        alignment: Alignment.bottomRight,
        widthFactor: 0.88,
        scale: 1.60,
        yOffset: 8,
      ),
      ActivityLevel.veryActive => (
        alignment: Alignment.bottomRight,
        widthFactor: 0.92,
        scale: 1.55,
        yOffset: 10,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected
        ? const Color(0xFF4CAF50)
        : const Color(0xFFE5E7EB);

    final textColor = isSelected ? Colors.white : const Color(0xFF111827);
    final iconColor = isSelected ? Colors.white : const Color(0xFF16A34A);
    const imageSlotWidth = 120.0;
    final tuning = _imageTuning();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height:
            88, // Reduced from 96 to fit all 4 options better on small screens
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, right: imageSlotWidth),
              child: Row(
                children: [
                  Text(
                    _emoji(),
                    style: TextStyle(fontSize: 18, color: textColor),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      title,
                      overflow: TextOverflow.visible,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () {
                      showModalBottomSheet<void>(
                        context: context,
                        showDragHandle: true,
                        builder: (context) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _infoText(),
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    height: 1.5,
                                    color: const Color(0xFF374151),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: iconColor, width: 1.5),
                      ),
                      child: Icon(
                        Icons.info_outline_rounded,
                        size: 14,
                        color: iconColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 0,
              top: -8,
              bottom: -8,
              width: imageSlotWidth,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
                child: Transform.translate(
                  offset: Offset(0, tuning.yOffset),
                  child: Align(
                    alignment: tuning.alignment,
                    widthFactor: tuning.widthFactor,
                    child: Transform.scale(
                      scale: tuning.scale,
                      alignment: Alignment.centerRight,
                      child: Image.asset(
                        assetPath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.transparent,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 10),
                            child: Icon(
                              Icons.image_outlined,
                              color: isSelected
                                  ? Colors.white.withOpacity(0.85)
                                  : const Color(0xFF9CA3AF),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DietAiMainGoalCard extends StatelessWidget {
  final String title;
  final bool isSelected;
  final String emoji;
  final String assetPath;
  final VoidCallback onTap;

  const _DietAiMainGoalCard({
    required this.title,
    required this.isSelected,
    required this.emoji,
    required this.assetPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF4CAF50);
    final backgroundColor = isSelected ? green : const Color(0xFFF3F4F6);
    final textColor = isSelected ? Colors.white : const Color(0xFF111827);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: green.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Text Content (Left)
            Positioned(
              left: 20,
              top: 0,
              bottom: 0,
              right: 140,
              child: Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Image (Right)
            Positioned(
              right: 0,
              bottom: 0,
              top: 0,
              width: 140,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 0),
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: textColor.withOpacity(0.5),
                          size: 30,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DietAiOptionCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _DietAiOptionCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF4CAF50);
    final backgroundColor = isSelected ? green : const Color(0xFFE5E7EB);
    final titleColor = isSelected ? Colors.white : const Color(0xFF111827);
    final subtitleColor = isSelected
        ? Colors.white.withOpacity(0.85)
        : const Color(0xFF6B7280);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Text(emoji, style: TextStyle(fontSize: 16, color: titleColor)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _DietAiRestrictionCard extends StatelessWidget {
  final String title;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;
  final String infoText;

  const _DietAiRestrictionCard({
    required this.title,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
    required this.infoText,
  });

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF4CAF50);
    final backgroundColor = isSelected ? green : const Color(0xFFE5E7EB);
    final textColor = isSelected ? Colors.white : const Color(0xFF111827);
    final iconColor = isSelected ? Colors.white : const Color(0xFF16A34A);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Text(emoji, style: TextStyle(fontSize: 14, color: textColor)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () {
                  showModalBottomSheet<void>(
                    context: context,
                    showDragHandle: true,
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              infoText,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                height: 1.4,
                                color: const Color(0xFF374151),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: iconColor, width: 1.5),
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: 12,
                    color: iconColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RestrictionItem {
  final String id;
  final String emoji;
  final String title;
  final String info;

  const _RestrictionItem({
    required this.id,
    required this.emoji,
    required this.title,
    required this.info,
  });
}

class _HealthConditionItem {
  final String id;
  final String emoji;
  final String title;
  final String info;

  const _HealthConditionItem({
    required this.id,
    required this.emoji,
    required this.title,
    required this.info,
  });
}

class _MultiSelectCard extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _MultiSelectCard({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.green[900] : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Gender3DCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isMale;
  final VoidCallback onTap;

  const _Gender3DCard({
    required this.label,
    required this.isSelected,
    required this.isMale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: isSelected ? 1.0 : 0.6,
          duration: const Duration(milliseconds: 200),
          child: Column(
            children: [
              // Avatar with Selection Border
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.transparent,
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.all(
                  4,
                ), // Space between border and image
                child: SizedBox(
                  height: 400, // Maximized height
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      isMale
                          ? 'assets/images/gender_man.png'
                          : 'assets/images/gender_woman.png',
                      alignment: Alignment.topCenter,
                      fit: BoxFit
                          .cover, // Fill the space, cropping sides if needed
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? const Color(0xFF1E1E1E)
                      : const Color(0xFF757575),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalculatingStepWrapper extends StatefulWidget {
  final OnboardingNotifier notifier;
  final void Function(OnboardingNotifier) startCalculation;
  final VoidCallback forceComplete;

  const _CalculatingStepWrapper({
    required this.notifier,
    required this.startCalculation,
    required this.forceComplete,
  });

  @override
  State<_CalculatingStepWrapper> createState() =>
      _CalculatingStepWrapperState();
}

class _CalculatingStepWrapperState extends State<_CalculatingStepWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.startCalculation(widget.notifier);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalculatingStep(onComplete: widget.forceComplete);
  }
}
