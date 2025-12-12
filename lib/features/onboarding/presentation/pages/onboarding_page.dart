import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutriz/features/onboarding/presentation/notifiers/onboarding_notifier.dart';
import 'package:nutriz/features/profile/domain/models/user_profile.dart';
import 'package:nutriz/routing/app_router.dart';
import '../widgets/onboarding_step_container.dart';
import '../widgets/goal_card.dart';
import '../widgets/biometric_slider.dart';
import '../widgets/calorie_result_display.dart';
import '../widgets/pro_upsell_card.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 13;

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
      HapticFeedback.lightImpact();
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

  bool _canProceed() {
    final profile = ref.read(onboardingNotifierProvider);
    switch (_currentPage) {
      case 0: // Welcome
        return true;
      case 1: // Main Goal
        return true;
      case 2: // Gender
        return true;
      case 3: // Birth Date
        return profile.birthDate.year < DateTime.now().year - 5;
      case 4: // Height
        return profile.height >= 100 && profile.height <= 250;
      case 5: // Current Weight
        return profile.currentWeight >= 30 && profile.currentWeight <= 300;
      case 6: // Target Weight
        return profile.targetWeight >= 30 && profile.targetWeight <= 300;
      case 7: // Activity Level
        return true;
      case 8: // Weekly Goal
        return true;
      case 9: // Dietary Preference
        return true;
      case 10: // Calculating
        return false;
      case 11: // Results
        return true;
      case 12: // PRO Upsell
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            if (_currentPage < _totalPages - 1 && _currentPage != 10)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    if (_currentPage > 0)
                      IconButton(
                        onPressed: _previousPage,
                        icon: const Icon(Icons.arrow_back_ios, size: 20),
                      )
                    else
                      const SizedBox(width: 48),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (_currentPage + 1) / (_totalPages - 1),
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

            // Page Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildWelcomeStep(),
                  _buildMainGoalStep(notifier, profile),
                  _buildGenderStep(notifier, profile),
                  _buildBirthDateStep(notifier, profile),
                  _buildHeightStep(notifier, profile),
                  _buildCurrentWeightStep(notifier, profile),
                  _buildTargetWeightStep(notifier, profile),
                  _buildActivityLevelStep(notifier, profile),
                  _buildWeeklyGoalStep(notifier, profile),
                  _buildDietaryPreferenceStep(notifier, profile),
                  _buildCalculatingStep(notifier),
                  _buildResultsStep(profile),
                  _buildProUpsellStep(),
                ],
              ),
            ),

            // Navigation Button
            if (_currentPage != 10 && _currentPage != 12)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canProceed()
                        ? () {
                            if (_currentPage == 9) {
                              // Before calculation step
                              _nextPage();
                              _startCalculation(notifier);
                            } else if (_currentPage == 11) {
                              // After results, go to PRO upsell
                              _nextPage();
                            } else {
                              _nextPage();
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
                          : _currentPage == 11
                          ? 'Continuar'
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
    );
  }

  void _startCalculation(OnboardingNotifier notifier) async {
    await Future.delayed(const Duration(seconds: 3));
    await notifier.calculateAndSave();
    if (mounted) {
      _nextPage();
    }
  }

  void _finishOnboarding() {
    // Force the provider to re-read from database instead of using stale state
    ref.invalidate(onboardingStatusProvider);
    context.go('/diary');
  }

  // ============ STEP BUILDERS ============

  Widget _buildWelcomeStep() {
    final theme = Theme.of(context);
    return OnboardingStepContainer(
      title: 'Bem-vindo ao Nutriz',
      subtitle: 'Vamos criar seu plano personalizado de nutrição',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  size: 80,
                  color: Colors.white,
                ),
              )
              .animate()
              .scale(begin: const Offset(0.5, 0.5), duration: 600.ms)
              .fadeIn(duration: 600.ms),
          const SizedBox(height: 32),
          Text(
            'Responda algumas perguntas para calcularmos suas metas diárias de calorias e macros.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 16),
          Text(
            'Leva apenas 2 minutos!',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildMainGoalStep(OnboardingNotifier notifier, UserProfile profile) {
    return OnboardingStepContainer(
      title: 'Qual é seu objetivo?',
      subtitle: 'Selecione o que melhor descreve suas metas',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GoalCard(
            icon: Icons.trending_down,
            title: 'Perder Peso',
            subtitle: 'Emagrecer de forma saudável',
            isSelected: profile.mainGoal == MainGoal.loseWeight,
            selectedColor: Colors.orange,
            onTap: () => notifier.updateMainGoal(MainGoal.loseWeight),
          ),
          const SizedBox(height: 16),
          GoalCard(
            icon: Icons.balance,
            title: 'Manter Peso',
            subtitle: 'Equilibrar minha alimentação',
            isSelected: profile.mainGoal == MainGoal.maintain,
            selectedColor: Colors.green,
            onTap: () => notifier.updateMainGoal(MainGoal.maintain),
          ),
          const SizedBox(height: 16),
          GoalCard(
            icon: Icons.fitness_center,
            title: 'Ganhar Músculos',
            subtitle: 'Aumentar massa muscular',
            isSelected: profile.mainGoal == MainGoal.buildMuscle,
            selectedColor: Colors.blue,
            onTap: () => notifier.updateMainGoal(MainGoal.buildMuscle),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderStep(OnboardingNotifier notifier, UserProfile profile) {
    return OnboardingStepContainer(
      title: 'Qual é seu sexo?',
      subtitle: 'Usado para calcular suas necessidades calóricas',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: GoalCard(
              icon: Icons.male,
              title: 'Masculino',
              isSelected: profile.gender == Gender.male,
              selectedColor: Colors.blue,
              onTap: () => notifier.updateGender(Gender.male),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GoalCard(
              icon: Icons.female,
              title: 'Feminino',
              isSelected: profile.gender == Gender.female,
              selectedColor: Colors.pink,
              onTap: () => notifier.updateGender(Gender.female),
            ),
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
        child: BiometricSlider(
          label: 'Idade',
          unit: 'anos',
          value: age.toDouble(),
          min: 12,
          max: 100,
          divisions: 88,
          onChanged: (value) {
            final year = DateTime.now().year - value.round();
            notifier.updateBiometrics(birthDate: DateTime(year, 1, 1));
          },
        ),
      ),
    );
  }

  Widget _buildHeightStep(OnboardingNotifier notifier, UserProfile profile) {
    return OnboardingStepContainer(
      title: 'Qual é sua altura?',
      subtitle: 'Usada para calcular seu metabolismo basal',
      child: Center(
        child: BiometricSlider(
          label: 'Altura',
          unit: 'cm',
          value: profile.height.toDouble(),
          min: 100,
          max: 250,
          divisions: 150,
          onChanged: (value) {
            notifier.updateBiometrics(height: value.round());
          },
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
              color: diffColor.withValues(alpha: 0.15),
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

  Widget _buildCalculatingStep(OnboardingNotifier notifier) {
    return const Center(
      child: CalculatingAnimation(
        message: 'Calculando seu plano personalizado...',
      ),
    );
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
          ],
        ),
      ),
    );
  }

  Widget _buildProUpsellStep() {
    return OnboardingStepContainer(
      title: '',
      child: ProUpsellCard(
        onContinueFree: _finishOnboarding,
        onTryPro: () {
          // TODO: Implement PRO subscription flow
          _finishOnboarding();
        },
      ),
    );
  }
}
