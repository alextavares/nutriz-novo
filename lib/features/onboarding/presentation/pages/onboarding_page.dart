import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:nutriz/features/onboarding/presentation/notifiers/onboarding_notifier.dart';
import 'package:nutriz/features/profile/domain/models/user_profile.dart';
import 'package:nutriz/routing/app_router.dart';
import 'package:nutriz/core/analytics/analytics_providers.dart';
import 'package:nutriz/core/debug/debug_flags.dart';
import '../widgets/onboarding_step_container.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/goal_card.dart';
import '../widgets/biometric_slider.dart';
import '../widgets/calorie_result_display.dart';
import '../widgets/pro_upsell_card.dart';
import '../widgets/calculating_step.dart';
import '../widgets/ruler_picker.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  final bool isEditMode;

  const OnboardingPage({super.key, this.isEditMode = false});

  const OnboardingPage.edit({super.key}) : isEditMode = true;

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    debugPrint('DEBUG: initState called - NEW WIDGET CREATED');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('DEBUG: _stepKeys list: $_stepKeys');
    });
  }

  @override
  void dispose() {
    debugPrint('DEBUG: dispose called - WIDGET DESTROYED');
    _pageController.dispose();
    super.dispose();
  }

  late final List<_StepKey> _stepKeys = widget.isEditMode
      ? [
          _StepKey.welcome,
          _StepKey.gender,
          _StepKey.mainGoal,
          _StepKey.commitment,
          _StepKey.birthDate,
          _StepKey.height,
          _StepKey.currentWeight,
          _StepKey.targetWeight,
          _StepKey.activityLevel,
          _StepKey.weeklyGoal,
          _StepKey.dietaryPreference,
          _StepKey.badHabits,
          _StepKey.water,
          _StepKey.sleep,
          _StepKey.motivation,
          _StepKey.calculating,
          _StepKey.results,
        ]
      : [
          _StepKey.welcome,
          _StepKey.gender,
          _StepKey.mainGoal,
          _StepKey.commitment,
          _StepKey.birthDate,
          _StepKey.height,
          _StepKey.currentWeight,
          _StepKey.targetWeight,
          _StepKey.activityLevel,
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
  int get _proUpsellPageIndex => _stepKeys.indexOf(_StepKey.proUpsell);
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

  String _suggestFirstMealType() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'breakfast';
    if (hour < 16) return 'lunch';
    if (hour < 21) return 'dinner';
    return 'snack';
  }

  void _nextPage() {
    debugPrint(
      'DEBUG: _nextPage called. _currentPage=$_currentPage, _totalPages=$_totalPages',
    );
    if (_currentPage < _totalPages - 1) {
      debugPrint('DEBUG: _nextPage animating to page ${_currentPage + 1}');
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
      HapticFeedback.lightImpact();
    } else {
      debugPrint('DEBUG: _nextPage skipped, already on last page');
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
      HapticFeedback.lightImpact();
    }
  }

  void _animateToPage(int index) {
    if (index < 0 || index >= _totalPages) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
    setState(() {
      _currentPage = index;
    });
    HapticFeedback.lightImpact();
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
      case _StepKey.activityLevel:
        return true;
      case _StepKey.weeklyGoal:
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
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('DEBUG: BUILD called. _currentPage=$_currentPage');
    // Watch profile to react to state changes (e.g., gender selection)
    final UserProfile profile = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final theme = Theme.of(context);
    final totalSteps = _calculatingPageIndex > 1
        ? _calculatingPageIndex - 1
        : 0;
    final showStepLabel =
        totalSteps > 0 &&
        _currentPage > 0 &&
        _currentPage < _calculatingPageIndex;
    final stepNumber = totalSteps == 0
        ? 0
        : (_currentPage - 1).clamp(0, totalSteps - 1) + 1;

    if (!_loggedStart && !widget.isEditMode) {
      _loggedStart = true;
      ref.read(analyticsServiceProvider).logEvent('onboarding_start');
    }

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
              if (!_isProUpsellPage &&
                  _currentStepKey != _StepKey.welcome &&
                  _currentStepKey != _StepKey.gender &&
                  _currentStepKey != _StepKey.mainGoal)
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
                                      _currentStepKey == _StepKey.gender)
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
                ),

              // Page Content
              Expanded(
                key: const ValueKey('onboarding_pageview_expanded'),
                child: PageView.builder(
                  key: const ValueKey('onboarding_pageview'),
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _stepKeys.length,
                  onPageChanged: (index) {
                    if (_logOnboarding)
                      debugPrint('DEBUG: onPageChanged index=$index');
                    // Defer setState to after the current frame to prevent
                    // interference with PageView animation
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && _currentPage != index) {
                        setState(() {
                          _currentPage = index;
                        });
                      }
                    });
                    if (!widget.isEditMode) {
                      ref.read(analyticsServiceProvider).logEvent(
                        'onboarding_step_view',
                        {'step_index': index, 'step_total': _totalPages},
                      );
                    }
                  },
                  itemBuilder: (context, index) {
                    final key = _stepKeys[index];
                    return _buildStep(key, notifier, profile);
                  },
                ),
              ),

              // Navigation Button
              if (_currentStepKey != _StepKey.calculating &&
                  !_isProUpsellPage &&
                  _currentStepKey != _StepKey.welcome &&
                  _currentStepKey != _StepKey.gender &&
                  _currentStepKey != _StepKey.mainGoal)
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
      debugPrint('DEBUG: PIVOT - Redirecionando para PredictionScreen...');
      // _animateToPage(_resultsPageIndex);
      // NEW FLOW: Go to Prediction Screen
      final profile = ref.read(onboardingNotifierProvider);
      if (mounted) {
        debugPrint(
          'DEBUG: PIVOT - Push para /onboarding/prediction com dados: ${profile.currentWeight} -> ${profile.targetWeight}',
        );
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainGoalStep(OnboardingNotifier notifier, UserProfile profile) {
    // BETTERME CLONE: Step 2 "Main Goal"
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 1),
              Text(
                "Qual é seu objetivo principal?",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E1E1E),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 32),

              _BetterMeGoalCard(
                title: "Perder Peso",
                subtitle: "Queimar gordura e definir",
                icon: Icons.local_fire_department_rounded,
                color: const Color(0xFFFFF3E0),
                iconColor: Colors.orange,
                onTap: () {
                  notifier.updateMainGoal(MainGoal.loseWeight);
                  _nextPage();
                },
              ),
              const SizedBox(height: 16),
              _BetterMeGoalCard(
                title: "Manter Peso",
                subtitle: "Melhorar alimentação e saúde",
                icon: Icons.spa_rounded,
                color: const Color(0xFFE8F5E9),
                iconColor: Colors.green,
                onTap: () {
                  notifier.updateMainGoal(MainGoal.maintain);
                  _nextPage();
                },
              ),
              const SizedBox(height: 16),
              _BetterMeGoalCard(
                title: "Ganhar Músculos",
                subtitle: "Ficar mais forte e volumoso",
                icon: Icons.fitness_center_rounded,
                color: const Color(0xFFE3F2FD),
                iconColor: Colors.blue,
                onTap: () {
                  notifier.updateMainGoal(MainGoal.buildMuscle);
                  _nextPage();
                },
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommitmentStep(
    OnboardingNotifier notifier,
    UserProfile profile,
  ) {
    final theme = Theme.of(context);
    return OnboardingStepContainer(
      title: 'Um compromisso rápido',
      subtitle: 'Isso aumenta a chance de você ter resultado',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Topa registrar 1 refeição por dia pelos próximos 3 dias?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: CheckboxListTile(
              value: profile.committedToLogDaily,
              onChanged: (value) {
                notifier.updateCommitment(committedToLogDaily: value ?? false);
              },
              title: const Text('Sim, eu me comprometo'),
              subtitle: const Text('Leva menos de 1 minuto por dia.'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Você pode mudar isso depois no Perfil.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBirthDateStep(OnboardingNotifier notifier, UserProfile profile) {
    final age = DateTime.now().year - profile.birthDate.year;
    return OnboardingStepContainer(
      title: 'Qual é sua idade?',
      subtitle: 'Sua idade afeta seu metabolismo',
      child: Center(
        child: RulerPicker(
          label: 'IDADE',
          unit: 'anos',
          value: age.toDouble(),
          min: 12,
          max: 100,
          onChanged: (value) {
            final year = DateTime.now().year - value.round();
            notifier.updateBiometrics(birthDate: DateTime(year, 1, 1));
          },
        ),
      ),
    );
  }

  Widget _buildHeightStep(OnboardingNotifier notifier, UserProfile profile) {
    // Diet.ai uses a specific layout: Avatar Left, Ruler Right, Value Top.
    final isMale = profile.gender == Gender.male;
    final theme = Theme.of(context);

    // Default to cm for now (Diet.ai has a toggle)
    final heightCm = profile.height;

    return OnboardingStepContainer(
      title: 'Qual é sua altura?',
      subtitle: 'Usada para calcular seu metabolismo basal',
      // We override the child padding or layout if needed, but OnboardingStepContainer usually provides padding.
      // We might need to "break out" of padding for the edge-to-edge ruler if desired, but sticking to container is safer.
      child: Column(
        children: [
          // Unit Toggle (Visual for now)
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildUnitToggleOption('cm', true),
                _buildUnitToggleOption('ft', false),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Main Content Area
          Expanded(
            child: Stack(
              children: [
                // Avatar (Bottom Left/Center)
                Positioned(
                  left: 0,
                  right: 80, // Leave space for ruler
                  bottom: 0,
                  top: 40, // Space for value? Or overlap?
                  child: Image.asset(
                    isMale
                        ? 'assets/images/gender_man.png'
                        : 'assets/images/gender_woman.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomCenter,
                  ),
                ),

                // Height Value Display (Floating near head or fixed top)
                Positioned(
                  left: 0,
                  right: 80,
                  top: 0,
                  child: Column(
                    children: [
                      Text(
                        '$heightCm',
                        style: GoogleFonts.inter(
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                          height: 1.0,
                          letterSpacing: -2.0,
                        ),
                      ),
                      Text(
                        'cm',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                  ),
                ),

                // Vertical Ruler (Right Edge)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: 100,
                  child: RulerPicker(
                    label: '',
                    unit: 'cm',
                    value: heightCm.toDouble(),
                    min: 100,
                    max: 250,
                    direction: Axis.vertical, // NEW: Vertical Mode
                    showValue: false, // NEW: Hide internal display
                    onChanged: (value) {
                      notifier.updateBiometrics(height: value.round());
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitToggleOption(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.green : Colors.transparent, // Diet.ai Green
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF9E9E9E),
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildCurrentWeightStep(
    OnboardingNotifier notifier,
    UserProfile profile,
  ) {
    return OnboardingStepContainer(
      title: 'Qual é seu peso atual?',
      subtitle: 'Seu ponto de partida',
      child: Center(
        child: BiometricSlider(
          label: 'Peso Atual',
          unit: 'kg',
          value: profile.currentWeight,
          min: 30,
          max: 200,
          divisions: 340,
          isInteger: false,
          onChanged: (value) {
            notifier.updateBiometrics(currentWeight: value);
          },
        ),
      ),
    );
  }

  Widget _buildTargetWeightStep(
    OnboardingNotifier notifier,
    UserProfile profile,
  ) {
    final theme = Theme.of(context);
    final diff = profile.targetWeight - profile.currentWeight;
    String diffText;
    Color diffColor;

    if (diff < 0) {
      diffText = '${diff.abs().toStringAsFixed(1)} kg a perder';
      diffColor = Colors.orange;
    } else if (diff > 0) {
      diffText = '${diff.toStringAsFixed(1)} kg a ganhar';
      diffColor = Colors.blue;
    } else {
      diffText = 'Manter peso atual';
      diffColor = Colors.green;
    }

    return OnboardingStepContainer(
      title: 'Qual é seu peso meta?',
      subtitle: 'O peso que você deseja alcançar',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BiometricSlider(
            label: 'Peso Meta',
            unit: 'kg',
            value: profile.targetWeight,
            min: 30,
            max: 200,
            divisions: 340,
            isInteger: false,
            onChanged: (value) {
              notifier.updateTarget(targetWeight: value);
            },
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: diffColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              diffText,
              style: theme.textTheme.titleMedium?.copyWith(
                color: diffColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLevelStep(
    OnboardingNotifier notifier,
    UserProfile profile,
  ) {
    return OnboardingStepContainer(
      title: 'Nível de atividade física',
      subtitle: 'Com que frequência você se exercita?',
      child: SingleChildScrollView(
        child: Column(
          children: [
            ActivityLevelCard(
              icon: Icons.weekend,
              title: 'Sedentário',
              description: 'Pouco ou nenhum exercício',
              isSelected: profile.activityLevel == ActivityLevel.sedentary,
              onTap: () =>
                  notifier.updateActivityLevel(ActivityLevel.sedentary),
            ),
            const SizedBox(height: 12),
            ActivityLevelCard(
              icon: Icons.directions_walk,
              title: 'Levemente Ativo',
              description: 'Exercício leve 1-3 dias/semana',
              isSelected: profile.activityLevel == ActivityLevel.low,
              onTap: () => notifier.updateActivityLevel(ActivityLevel.low),
            ),
            const SizedBox(height: 12),
            ActivityLevelCard(
              icon: Icons.directions_run,
              title: 'Moderadamente Ativo',
              description: 'Exercício moderado 3-5 dias/semana',
              isSelected: profile.activityLevel == ActivityLevel.active,
              onTap: () => notifier.updateActivityLevel(ActivityLevel.active),
            ),
            const SizedBox(height: 12),
            ActivityLevelCard(
              icon: Icons.sports_gymnastics,
              title: 'Muito Ativo',
              description: 'Exercício intenso 6-7 dias/semana',
              isSelected: profile.activityLevel == ActivityLevel.veryActive,
              onTap: () =>
                  notifier.updateActivityLevel(ActivityLevel.veryActive),
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
    return OnboardingStepContainer(
      title: 'Ritmo de progresso',
      subtitle: 'Quanto você quer mudar por semana?',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: WeeklyGoalSlider(
            value: profile.weeklyGoal,
            onChanged: (value) {
              notifier.updateTarget(weeklyGoal: value);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDietaryPreferenceStep(
    OnboardingNotifier notifier,
    UserProfile profile,
  ) {
    return OnboardingStepContainer(
      title: 'Preferência alimentar',
      subtitle: 'Escolha seu estilo de alimentação',
      child: SingleChildScrollView(
        child: Column(
          children: [
            ActivityLevelCard(
              icon: Icons.restaurant,
              title: 'Clássico',
              description: 'Todos os tipos de alimentos',
              isSelected:
                  profile.dietaryPreference == DietaryPreference.classic,
              onTap: () =>
                  notifier.updateDietaryPreference(DietaryPreference.classic),
            ),
            const SizedBox(height: 12),
            ActivityLevelCard(
              icon: Icons.set_meal,
              title: 'Pescetariano',
              description: 'Vegetais, ovos, laticínios e peixes',
              isSelected:
                  profile.dietaryPreference == DietaryPreference.pescetarian,
              onTap: () => notifier.updateDietaryPreference(
                DietaryPreference.pescetarian,
              ),
            ),
            const SizedBox(height: 12),
            ActivityLevelCard(
              icon: Icons.eco,
              title: 'Vegetariano',
              description: 'Vegetais, ovos e laticínios',
              isSelected:
                  profile.dietaryPreference == DietaryPreference.vegetarian,
              onTap: () => notifier.updateDietaryPreference(
                DietaryPreference.vegetarian,
              ),
            ),
            const SizedBox(height: 12),
            ActivityLevelCard(
              icon: Icons.grass,
              title: 'Vegano',
              description: 'Apenas alimentos de origem vegetal',
              isSelected: profile.dietaryPreference == DietaryPreference.vegan,
              onTap: () =>
                  notifier.updateDietaryPreference(DietaryPreference.vegan),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadHabitsStep(OnboardingNotifier notifier, UserProfile profile) {
    return OnboardingStepContainer(
      title: 'Maus hábitos',
      subtitle: 'O que te impede de atingir seu objetivo?',
      child: SingleChildScrollView(
        child: Column(
          children: [
            _MultiSelectCard(
              title: 'Doces e Açúcar',
              isSelected: profile.badHabits.contains('sugar'),
              onTap: () => notifier.toggleBadHabit('sugar'),
            ),
            const SizedBox(height: 12),
            _MultiSelectCard(
              title: 'Refrigerante',
              isSelected: profile.badHabits.contains('soda'),
              onTap: () => notifier.toggleBadHabit('soda'),
            ),
            const SizedBox(height: 12),
            _MultiSelectCard(
              title: 'Lanche Noturno',
              isSelected: profile.badHabits.contains('night_snack'),
              onTap: () => notifier.toggleBadHabit('night_snack'),
            ),
            const SizedBox(height: 12),
            _MultiSelectCard(
              title: 'Comer por ansiedade',
              isSelected: profile.badHabits.contains('anxiety'),
              onTap: () => notifier.toggleBadHabit('anxiety'),
            ),
            const SizedBox(height: 12),
            _MultiSelectCard(
              title: 'Massas e Pães',
              isSelected: profile.badHabits.contains('carbs'),
              onTap: () => notifier.toggleBadHabit('carbs'),
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
              icon: Icons.local_drink_rounded,
              title: 'Menos de 1 Litro',
              description: 'Pouca hidratação',
              isSelected: profile.waterIntake == WaterIntake.lessThan1L,
              onTap: () => notifier.updateWaterIntake(WaterIntake.lessThan1L),
            ),
            const SizedBox(height: 12),
            ActivityLevelCard(
              icon: Icons.water_drop_rounded,
              title: '1 a 2 Litros',
              description: 'Média recomendada',
              isSelected: profile.waterIntake == WaterIntake.oneToTwoL,
              onTap: () => notifier.updateWaterIntake(WaterIntake.oneToTwoL),
            ),
            const SizedBox(height: 12),
            ActivityLevelCard(
              icon: Icons.waves_rounded,
              title: '2 a 3 Litros',
              description: 'Ótima hidratação',
              isSelected: profile.waterIntake == WaterIntake.twoToThreeL,
              onTap: () => notifier.updateWaterIntake(WaterIntake.twoToThreeL),
            ),
            const SizedBox(height: 12),
            ActivityLevelCard(
              icon: Icons.tsunami_rounded,
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
              icon: Icons.bedtime_rounded,
              title: 'Menos de 5 horas',
              description: 'Descanso insuficiente',
              isSelected: profile.sleepDuration == SleepDuration.lessThan5,
              onTap: () =>
                  notifier.updateSleepDuration(SleepDuration.lessThan5),
            ),
            const SizedBox(height: 12),
            ActivityLevelCard(
              icon: Icons.nightlight_round,
              title: '5 a 6 horas',
              description: 'Pode melhorar',
              isSelected: profile.sleepDuration == SleepDuration.fiveToSix,
              onTap: () =>
                  notifier.updateSleepDuration(SleepDuration.fiveToSix),
            ),
            const SizedBox(height: 12),
            ActivityLevelCard(
              icon: Icons.bed_rounded,
              title: '7 a 8 horas',
              description: 'Recomendado',
              isSelected: profile.sleepDuration == SleepDuration.sevenToEight,
              onTap: () =>
                  notifier.updateSleepDuration(SleepDuration.sevenToEight),
            ),
            const SizedBox(height: 12),
            ActivityLevelCard(
              icon: Icons.access_time_filled_rounded,
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
    debugPrint('DEBUG: _buildStep key=$key');
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
      case _StepKey.activityLevel:
        return _buildActivityLevelStep(notifier, profile);
      case _StepKey.weeklyGoal:
        return _buildWeeklyGoalStep(notifier, profile);
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
  activityLevel,
  weeklyGoal,
  dietaryPreference,
  badHabits,
  water,
  sleep,
  motivation,
  calculating,
  results,
  proUpsell,
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

class _BetterMeGoalCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _BetterMeGoalCard({
    required this.title,
    required this.subtitle,
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 28),
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
