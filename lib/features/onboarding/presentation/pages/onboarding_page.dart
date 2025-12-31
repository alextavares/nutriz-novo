import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:nutriz/features/onboarding/presentation/notifiers/onboarding_notifier.dart';
import 'package:nutriz/features/profile/domain/models/user_profile.dart';
import 'package:nutriz/routing/app_router.dart';
import 'package:nutriz/core/analytics/analytics_providers.dart';
import 'package:nutriz/core/debug/debug_flags.dart';
import 'package:nutriz/features/onboarding/presentation/providers/onboarding_flow_providers.dart';
import '../widgets/onboarding_step_container.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/goal_card.dart';
import '../widgets/biometric_slider.dart';
import '../widgets/calorie_result_display.dart';
import '../widgets/pro_upsell_card.dart';
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

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  late final PageController _pageController;
  int _currentPage = 0;
  bool _heightUseMetric = true;
  bool _weightUseMetric = true;
  bool _birthDateDefaulted = false;
  bool _weeklyGoalDefaulted = false;

  @override
  void initState() {
    super.initState();
    final savedIndex = ref.read(
      onboardingCurrentPageProvider(widget.isEditMode),
    );
    final initialIndex = _stepKeys.isEmpty
        ? 0
        : savedIndex.clamp(0, _stepKeys.length - 1);
    _currentPage = initialIndex;
    _pageController = PageController(initialPage: initialIndex);
    // No debug logs here: this method runs often during development (hot
    // restart), and logging the whole step list is noisy.
  }

  @override
  void dispose() {
    _pageController.dispose();
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
          _StepKey.dietaryPreference,
          _StepKey.badHabits,
          _StepKey.water,
          _StepKey.sleep,
          _StepKey.motivation,
          _StepKey.calculating,
          _StepKey.results,
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
          _StepKey.dietaryPreference,
          _StepKey.badHabits,
          _StepKey.water,
          _StepKey.sleep,
          _StepKey.motivation,
          _StepKey.calculating,
          _StepKey.results,
          _StepKey.proUpsell,
        ];

  int get _totalPages => _stepKeys.length;
  _StepKey get _currentStepKey => _stepKeys[_currentPage];
  int get _calculatingPageIndex => _stepKeys.indexOf(_StepKey.calculating);
  int get _resultsPageIndex => _stepKeys.indexOf(_StepKey.results);
  bool get _isProUpsellPage =>
      !widget.isEditMode && _currentStepKey == _StepKey.proUpsell;
  bool get _isBeforeCalculating => _currentPage == _calculatingPageIndex - 1;

  bool _calculationInProgress = false;
  int _calculationRunId = 0;
  bool _finishInProgress = false;
  bool _navInProgress = false;
  bool _loggedStart = false;
  bool get _logOnboarding => DebugFlags.canVerbose;
  bool get _logNav => DebugFlags.canVerbose;

  void _nextPage() {
    if (_logNav) {
      debugPrint(
        'DEBUG: _nextPage called. _currentPage=$_currentPage, _totalPages=$_totalPages',
      );
    }
    if (_currentPage < _totalPages - 1) {
      final nextIndex = (_currentPage + 1).clamp(0, _totalPages - 1);
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

  void _goToStep(_StepKey stepKey) {
    final index = _stepKeys.indexOf(stepKey);
    if (index == -1) return;
    _animateToPage(index);
  }

  void _cancelCalculation() {
    _calculationRunId++;
    if (mounted) {
      setState(() {
        _calculationInProgress = false;
      });
    }
  }

  void _handleBack() {
    if (_currentPage <= 0) return;

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
        _currentStepKey != _StepKey.badHabits;

    return WillPopScope(
      onWillPop: () async {
        if (_currentPage > 0) {
          _handleBack();
          return false;
        }
        return true;
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
                          if (_currentPage > 0)
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
                                      _currentStepKey == _StepKey.currentWeight ||
                                      _currentStepKey == _StepKey.targetWeight ||
                                      _currentStepKey == _StepKey.realisticGoal ||
                                      _currentStepKey == _StepKey.weeklyGoal ||
                                      _currentStepKey == _StepKey.dietAiBoost ||
                                      _currentStepKey == _StepKey.dietaryPreference ||
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
                    if (_logNav)
                      debugPrint('DEBUG: onPageChanged index=$index');
                    if (mounted && _currentPage != index) {
                      setState(() {
                        _currentPage = index;
                      });
                    }
                    ref
                            .read(
                              onboardingCurrentPageProvider(
                                widget.isEditMode,
                              ).notifier,
                            )
                            .state =
                        index;
                    if (!widget.isEditMode) {
                      ref.read(analyticsServiceProvider).logEvent(
                        'onboarding_step_view',
                        {'step_index': index, 'step_total': _totalPages},
                      );
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
                                if (_logNav)
                                  debugPrint(
                                    'DEBUG: Nav in progress, ignoring.',
                                  );
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
                                  notifier.saveDraft();
                                  _nextPage();
                                  return;
                                }

                                if (_currentStepKey == _StepKey.results) {
                                  if (_logNav)
                                    debugPrint(
                                      'DEBUG: On results step, finishing.',
                                    );
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
                                  notifier.saveDraft();
                                }
                                _nextPage();
                              } catch (e, stack) {
                                if (_logNav)
                                  debugPrint(
                                    'DEBUG: Navigation error: $e\n$stack',
                                  );
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

  void _startCalculation(OnboardingNotifier notifier) async {
    final runId = ++_calculationRunId;
    if (_logOnboarding) {
      debugPrint('DEBUG: _startCalculation started runId=$runId');
    }
    // await Future.delayed(const Duration(seconds: 3)); // Handled by CalculatingStep
    if (!mounted || runId != _calculationRunId) return;
    try {
      if (_logOnboarding) {
        debugPrint('DEBUG: Calling notifier.calculateAndSave()');
      }
      await notifier.calculateAndSave();
      if (!mounted || runId != _calculationRunId) return;
      if (_logOnboarding) {
        debugPrint('DEBUG: calculateAndSave done. next page...');
      }
      if (_currentStepKey != _StepKey.calculating) return;
      if (_logOnboarding) {
        debugPrint('DEBUG: PIVOT - Redirecionando para PredictionScreen...');
      }
      // _animateToPage(_resultsPageIndex);
      // NEW FLOW: Go to Prediction Screen
      final profile = ref.read(onboardingNotifierProvider);
      if (mounted) {
        if (_logOnboarding) {
          debugPrint(
            'DEBUG: PIVOT - Push para /onboarding/prediction com dados: ${profile.currentWeight} -> ${profile.targetWeight}',
          );
        }
        context.push(
          '/onboarding/prediction',
          extra: {
            'currentWeight': profile.currentWeight,
            'goalWeight': profile.targetWeight,
            'age': (DateTime.now().year - profile.birthDate.year),
          },
        );
      }
    } catch (e, stack) {
      if (_logOnboarding) {
        debugPrint('DEBUG: _startCalculation error: $e\n$stack');
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao calcular: $e')));
        _handleBack(); // Go back so user isn't stuck
      }
    } finally {
      if (mounted && runId == _calculationRunId) {
        setState(() {
          _calculationInProgress = false;
        });
      }
    }
  }

  void _cancelEdit() {
    if (!mounted) return;
    ref.read(onboardingCurrentPageProvider(widget.isEditMode).notifier).state =
        0;
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
      await notifier.calculateAndSave();
      if (!mounted) return;
      await notifier.persistCompletion();
      if (!mounted) return;
      if (_logOnboarding) {
        debugPrint(
          'DEBUG: OnboardingPage._skipOnboarding persistCompletion OK',
        );
      }
      if (!widget.isEditMode) {
        final p = ref.read(onboardingNotifierProvider);
        ref.read(analyticsServiceProvider).logEvent('onboarding_complete', {
          'screen': 'onboarding',
          'goal_type': p.mainGoal.name,
          'activity_level': p.activityLevel.name,
          'calorie_target': p.calculatedCalories,
          'protein_g': p.proteinGrams,
          'carbs_g': p.carbsGrams,
          'fat_g': p.fatGrams,
          'skipped': true,
        });
        ref.read(analyticsServiceProvider).logEvent('goal_set', {
          'screen': 'onboarding',
          'goal_type': p.mainGoal.name,
          'activity_level': p.activityLevel.name,
          'calorie_target': p.calculatedCalories,
          'protein_g': p.proteinGrams,
          'carbs_g': p.carbsGrams,
          'fat_g': p.fatGrams,
          'source': 'skip',
        });
      }
      ref.read(onboardingStatusProvider.notifier).setCompleted();
      if (_logOnboarding) {
        debugPrint(
          'DEBUG: OnboardingPage._skipOnboarding setCompleted -> go(/diary)',
        );
      }
      ref
              .read(onboardingCurrentPageProvider(widget.isEditMode).notifier)
              .state =
          0;
      context.go('/diary?firstRun=1');
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
      await ref.read(onboardingNotifierProvider.notifier).persistCompletion();
      if (_logOnboarding) {
        debugPrint(
          'DEBUG: OnboardingPage._finishOnboarding persistCompletion OK',
        );
      }

      if (!mounted) return;
      if (!widget.isEditMode) {
        final p = ref.read(onboardingNotifierProvider);
        ref.read(analyticsServiceProvider).logEvent('onboarding_complete', {
          'screen': 'onboarding',
          'goal_type': p.mainGoal.name,
          'activity_level': p.activityLevel.name,
          'calorie_target': p.calculatedCalories,
          'protein_g': p.proteinGrams,
          'carbs_g': p.carbsGrams,
          'fat_g': p.fatGrams,
          'skipped': false,
        });
        ref.read(analyticsServiceProvider).logEvent('goal_set', {
          'screen': 'onboarding',
          'goal_type': p.mainGoal.name,
          'activity_level': p.activityLevel.name,
          'calorie_target': p.calculatedCalories,
          'protein_g': p.proteinGrams,
          'carbs_g': p.carbsGrams,
          'fat_g': p.fatGrams,
          'source': 'finish',
        });
      }

      // Mark onboarding as completed immediately so router redirect won't bounce back.
      ref.read(onboardingStatusProvider.notifier).setCompleted();
      if (_logOnboarding) {
        debugPrint(
          'DEBUG: OnboardingPage._finishOnboarding setCompleted -> go',
        );
      }
      ref
              .read(onboardingCurrentPageProvider(widget.isEditMode).notifier)
              .state =
          0;
      context.go(nextRoute);
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
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

              const Spacer(flex: 1),

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
                "Ano Novo, Nova Você!\nFique mais saudável em 2026 🎄",
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
                "Olá 👋 Eu sou sua Nutricionista Pessoal baseada em IA. Vou fazer algumas perguntas para personalizar um plano de dieta inteligente para você.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF757575),
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 2),

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

              // SIGN IN LINK
              TextButton(
                onPressed: () {
                  // Navigate to login
                  context.push('/login');
                },
                child: Text.rich(
                  TextSpan(
                    text: "Já tem uma conta? ",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF9E9E9E),
                    ),
                    children: [
                      TextSpan(
                        text: "Entrar",
                        style: GoogleFonts.inter(
                          color: const Color(0xFF2196F3),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.male,
                          size: 28,
                          color: Color(0xFFE57373), // Coral/pink
                        ),
                        Icon(
                          Icons.female,
                          size: 28,
                          color: Color(0xFFE57373), // Coral/pink
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
                        child: const Icon(
                          Icons.track_changes_rounded,
                          color: Color(0xFF111827),
                          size: 18,
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
              'DietAI traz resultados\na longo prazo',
              style: GoogleFonts.inter(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF111827),
                height: 1.15,
              ),
            ),
            const SizedBox(height: 18),
            const Expanded(child: LongTermResultsChart()),
            const SizedBox(height: 10),
            Text(
              '80% dos usuários dedicados mantêm o peso após 6 meses. '
              'O DietAI usa IA e ciência da nutrição para criar hábitos sustentáveis.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.4,
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
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
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cake_outlined,
                      size: 18,
                      color: Color(0xFF111827),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      initialAge.toString(),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.straighten, color: Color(0xFFE57373), size: 22),
              const SizedBox(width: 8),
              Icon(
                isMale ? Icons.male : Icons.female,
                color: const Color(0xFF4CAF50),
                size: 22,
              ),
            ],
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
                  final avatarViewportHeightFactor = isMale ? 0.78 : 0.80;
                  final avatarImageHeightFactor = isMale ? 1.18 : 1.26;
                  final avatarLiftFactor = isMale ? 0.18 : 0.20;
                  final avatarXOffset = isMale ? 24.0 : 22.0;

                  final avatarViewportHeight =
                      constraints.maxHeight * avatarViewportHeightFactor;
                  final avatarImageHeight =
                      constraints.maxHeight * avatarImageHeightFactor;
                  final avatarLift = constraints.maxHeight * avatarLiftFactor;

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
                            offset: Offset(avatarXOffset, -avatarLift),
                            child: SizedBox(
                              height: avatarViewportHeight,
                              child: ClipRect(
                                child: Transform.translate(
                                  offset: Offset(0, -avatarLift),
                                  child: Image.asset(
                                    isMale
                                        ? 'assets/images/gender_man.png'
                                        : 'assets/images/gender_woman.png',
                                    fit: BoxFit.contain,
                                    height: avatarImageHeight,
                                  ),
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

  Widget _buildHeightUnitToggle() {
    final theme = Theme.of(context);
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
            'cm',
            _heightUseMetric,
            onTap: () => setState(() => _heightUseMetric = true),
          ),
          _buildUnitToggleOption(
            'ft',
            !_heightUseMetric,
            onTap: () => setState(() => _heightUseMetric = false),
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

  int _cmToInches(int cm) => (cm / 2.54).round();

  int _inchesToCm(int inches) => (inches * 2.54).round();

  int _kgToLbs(int kg) => (kg * 2.2046226218).round();

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

  String _formatImperial(int cm) {
    final totalInches = _cmToInches(cm);
    final feet = totalInches ~/ 12;
    final inches = totalInches % 12;
    return "$feet'${inches.toString().padLeft(2, '0')}\"";
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
    final weightKgRounded = weightKg.round();

    final displayValue = _weightUseMetric
        ? weightKgRounded
        : _kgToLbs(weightKgRounded);
    final displayUnit = _weightUseMetric ? 'kg' : 'lbs';

    final rulerMin = _weightUseMetric
        ? minKg.toDouble()
        : _kgToLbs(minKg).toDouble();
    final rulerMax = _weightUseMetric
        ? maxKg.toDouble()
        : _kgToLbs(maxKg).toDouble();
    final rulerValue = displayValue.toDouble().clamp(rulerMin, rulerMax);

    final bmi = _calculateBmi(weightKg: weightKg, heightCm: profile.height);
    final bmiText = bmi <= 0 ? '--' : bmi.toStringAsFixed(1);
    final bmiCategory = bmi <= 0 ? '' : _bmiCategory(bmi);

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
                  Icons.monitor_weight_outlined,
                  color: Color(0xFF111827),
                  size: 18,
                ),
              ),
            ),
            const SizedBox(height: 14),
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
            const SizedBox(height: 22),
            Text(
              '$displayValue $displayUnit',
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
                    data: theme.copyWith(scaffoldBackgroundColor: Colors.white),
                    child: RulerPicker(
                      label: '',
                      unit: displayUnit,
                      value: rulerValue,
                      min: rulerMin,
                      max: rulerMax,
                      direction: Axis.horizontal,
                      showValue: false,
                      showIndicator: false,
                      onChanged: (value) {
                        final int picked = value.round();
                        final nextKg = _weightUseMetric
                            ? picked.toDouble()
                            : double.parse(_lbsToKg(picked).toStringAsFixed(1));
                        notifier.updateBiometrics(currentWeight: nextKg);
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

    final displayValue = _weightUseMetric
        ? targetKg.round()
        : _kgToLbs(targetKg.round());
    final displayUnit = _weightUseMetric ? 'kg' : 'lbs';

    final rulerMin = _weightUseMetric
        ? minKg.toDouble()
        : _kgToLbs(minKg).toDouble();
    final rulerMax = _weightUseMetric
        ? maxKg.toDouble()
        : _kgToLbs(maxKg).toDouble();
    final rulerValue = displayValue.toDouble().clamp(rulerMin, rulerMax);

    final diffKg = (targetKg - currentKg);
    final diffAbsKg = diffKg.abs();
    final isLoss = diffKg < -0.1;
    final isGain = diffKg > 0.1;

    final percent = currentKg <= 0.1
        ? 0.0
        : (diffAbsKg / currentKg * 100.0).clamp(0.0, 99.0);
    final percentText = percent < 1 ? '1' : percent.round().toString();

    final bmiTarget =
        _calculateBmi(weightKg: targetKg, heightCm: profile.height);
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

    final diffAmount = _weightUseMetric ? diffAbsKg : (diffAbsKg * 2.2046226218);
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
            const SizedBox(height: 8),
            Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.flag_outlined,
                  color: Color(0xFF111827),
                  size: 18,
                ),
              ),
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              '$displayValue $displayUnit',
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
                    data: theme.copyWith(scaffoldBackgroundColor: Colors.white),
                    child: RulerPicker(
                      label: '',
                      unit: displayUnit,
                      value: rulerValue,
                      min: rulerMin,
                      max: rulerMax,
                      direction: Axis.horizontal,
                      showValue: false,
                      showIndicator: false,
                      onChanged: (value) {
                        final picked = value.round();
                        final nextKg = _weightUseMetric
                            ? picked.toDouble()
                            : double.parse(_lbsToKg(picked).toStringAsFixed(1));
                        notifier.updateTarget(targetWeight: nextKg);
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
                  Icons.directions_run_rounded,
                  color: Color(0xFF111827),
                  size: 18,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Quão ativo você é\nno dia a dia?',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 28,
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
              '90% dos usuários comprometidos notam resultados visíveis e o progresso se mantém, '
              'enquanto dietas restritivas causam efeito sanfona.',
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
              'Ciência da Nutrição\n+\nIA\n= DietAI',
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
              'Os dados históricos do DietAI mostram que o progresso pode parecer '
              'lento no começo, mas após 7 dias a perda de gordura acelera significativamente.',
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

  Widget _buildWeeklyGoalStep(
    OnboardingNotifier notifier,
    UserProfile profile,
  ) {
    const options = [0.1, 0.5, 1.0];

    final sign = (profile.targetWeight < profile.currentWeight - 0.05 ||
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
        : options.indexWhere((o) => (o - selectedAbs).abs() < 0.001).clamp(
              0,
              options.length - 1,
            );

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
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.speed_rounded,
                  color: Color(0xFF111827),
                  size: 18,
                ),
              ),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 28),
            Text(
              '$formatted $displayUnit/semana',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🐌',
                  style: TextStyle(
                    fontSize: 28,
                    color: index == 0 ? null : Colors.black.withOpacity(0.35),
                  ),
                ),
                Text(
                  '🐇',
                  style: TextStyle(
                    fontSize: 28,
                    color: index == 1 ? null : Colors.black.withOpacity(0.35),
                  ),
                ),
                Text(
                  '🐆',
                  style: TextStyle(
                    fontSize: 28,
                    color: index == 2 ? null : Colors.black.withOpacity(0.35),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 6,
                activeTrackColor: const Color(0xFF3B82F6),
                inactiveTrackColor: const Color(0xFFE5E7EB),
                thumbColor: const Color(0xFF3B82F6),
                overlayColor: const Color(0xFF3B82F6).withOpacity(0.12),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
              ),
              child: Slider(
                value: index.toDouble(),
                min: 0,
                max: 2,
                divisions: 2,
                onChanged: (v) {
                  final pickedIndex = v.round().clamp(0, 2);
                  final pickedAbs = options[pickedIndex];
                  notifier.updateTarget(weeklyGoal: sign == 0 ? 0 : sign * pickedAbs);
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
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
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
            const SizedBox(height: 28),
            Text(
              'Perca 2x mais peso\ncom DietAI do que\nsozinho',
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
                    'Sem\nDietAI',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  Text(
                    'Com\nDietAI',
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
                      '20%',
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
                      '2X',
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
              'O DietAI torna mais simples alcançar suas metas\ne ajuda você a manter consistência.',
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
                  Icons.restaurant_menu_rounded,
                  color: Color(0xFF111827),
                  size: 18,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Qual é sua\npreferência alimentar?',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 28,
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
                    _DietAiOptionCard(
                      emoji: '🥩',
                      title: 'Clássico',
                      subtitle: 'Todos os tipos de alimentos',
                      isSelected:
                          profile.dietaryPreference == DietaryPreference.classic,
                      onTap: () => notifier.updateDietaryPreference(
                        DietaryPreference.classic,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _DietAiOptionCard(
                      emoji: '🐟',
                      title: 'Pescetariano',
                      subtitle: 'Vegetais, ovos, laticínios e peixes',
                      isSelected: profile.dietaryPreference ==
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
                      isSelected: profile.dietaryPreference ==
                          DietaryPreference.vegetarian,
                      onTap: () => notifier.updateDietaryPreference(
                        DietaryPreference.vegetarian,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _DietAiOptionCard(
                      emoji: '🥑',
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
        emoji: '🥗',
        title: 'Vegetariano',
        info:
            'Evita carnes. Pode incluir ovos e laticínios dependendo do seu padrão alimentar.',
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
        info:
            'Evita alimentos com trigo, cevada e centeio. Importante para intolerância ou doença celíaca.',
      ),
      _RestrictionItem(
        id: 'dairy_free',
        emoji: '🚫🥛',
        title: 'Sem lactose',
        info:
            'Evita leite e derivados. Pode ser útil para intolerância à lactose.',
      ),
      _RestrictionItem(
        id: 'no_red_meat',
        emoji: '🥩',
        title: 'Evito carne vermelha',
        info: 'Evita carne bovina/suína e similares.',
      ),
      _RestrictionItem(
        id: 'nut_allergy',
        emoji: '🥜',
        title: 'Alergia a nozes',
        info: 'Evita amendoim, castanhas e derivados por segurança.',
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
            Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.no_food_rounded,
                  color: Color(0xFF111827),
                  size: 18,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Você tem alguma restrição\nalimentar, alergia ou algo\na evitar?',
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
                      emoji: '✅',
                      isSelected: noneSelected,
                      onTap: setNone,
                      infoText:
                          'Sem restrições. Você pode ajustar isso depois no Perfil.',
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
    return CalculatingStep(onComplete: () => _startCalculation(notifier));
  }

  Widget _buildResultsStep(UserProfile profile) {
    return OnboardingStepContainer(
      title: 'Seu plano está pronto!',
      subtitle: 'Baseado nas suas informações, calculamos:',
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
              const SizedBox(height: 24),
              TextButton(
                onPressed: _nextPage,
                child: const Text('Conhecer o Nutriz Pro'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProUpsellStep() {
    return OnboardingStepContainer(
      title: '',
      child: ProUpsellCard(
        onContinueFree: () async => _finishOnboarding(),
        onTryPro: () async => _finishOnboarding(nextRoute: '/premium'),
      ),
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
      height: 46,
      child: CustomPaint(painter: _BmiScalePainter(bmi: bmi)),
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

    final left = 0.0;
    final right = size.width;
    final y = 10.0;
    final baseline = Paint()
      ..color = const Color(0xFF111827)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final tick = Paint()
      ..color = const Color(0xFF111827)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(left, y), Offset(right, y), baseline);

    void label(double value, String text) {
      final x = left + (right - left) * ((value - min) / (max - min));
      canvas.drawLine(Offset(x, y - 6), Offset(x, y + 6), tick);

      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 60);
      painter.paint(canvas, Offset(x - painter.width / 2, y + 12));
    }

    label(18.5, '18.5');
    label(25, '25.0');
    label(30, '30.0');
    label(35, '35.0');

    // Marker for current BMI.
    final markerX = left + (right - left) * ((clamped - min) / (max - min));
    final marker = Paint()
      ..color = const Color(0xFF60A5FA)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(markerX, y - 12), Offset(markerX, y + 12), marker);
  }

  @override
  bool shouldRepaint(covariant _BmiScalePainter oldDelegate) {
    return bmi != oldDelegate.bmi;
  }
}

class _GenderCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _GenderCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(width: 24),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.black26,
              size: 18,
            ),
          ],
        ),
      ),
    );
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
        widthFactor: 0.62,
        scale: 1.55,
        yOffset: 2,
      ),
      ActivityLevel.low => (
        alignment: Alignment.bottomRight,
        widthFactor: 0.66,
        scale: 1.65,
        yOffset: 6,
      ),
      ActivityLevel.active => (
        alignment: Alignment.bottomRight,
        widthFactor: 0.70,
        scale: 1.60,
        yOffset: 8,
      ),
      ActivityLevel.veryActive => (
        alignment: Alignment.bottomRight,
        widthFactor: 0.74,
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
    const imageSlotWidth = 150.0;
    final tuning = _imageTuning();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 76,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 14, right: imageSlotWidth),
              child: Row(
                children: [
                  Text(
                    _emoji(),
                    style: TextStyle(fontSize: 14, color: textColor),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
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
                                  _infoText(),
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
    final backgroundColor = isSelected ? green : const Color(0xFFE5E7EB);
    final textColor = isSelected ? Colors.white : const Color(0xFF111827);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 74,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Text(emoji, style: TextStyle(fontSize: 16, color: textColor)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 150,
              height: 74,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
                child: Align(
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
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 14),
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
        height: 76,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
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

class _BetterMeGoalCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final String? emoji; // Added emoji support
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _BetterMeGoalCard({
    required this.title,
    required this.subtitle,
    this.icon,
    this.emoji,
    required this.color,
    required this.iconColor,
    required this.onTap,
  }) : assert(icon != null || emoji != null, 'Provide either icon or emoji');

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E1E1E),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.withOpacity(0.15)),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: emoji != null
                  ? Text(emoji!, style: const TextStyle(fontSize: 28))
                  : Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
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
