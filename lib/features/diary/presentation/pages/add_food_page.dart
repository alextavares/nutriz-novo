import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutriz/core/analytics/analytics_providers.dart';
import 'package:nutriz/core/monetization/meal_log_gate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../premium/presentation/providers/subscription_provider.dart';
import '../../../profile/presentation/notifiers/profile_notifier.dart';
import '../../domain/entities/food.dart';
import '../../domain/entities/food_item.dart';
import '../../domain/entities/meal.dart' hide FoodItem;
import '../notifiers/ai_food_notifier.dart';
import '../notifiers/food_search_notifier.dart';
import '../providers/ai_food_provider.dart';
import '../providers/diary_providers.dart';
import '../widgets/food_detail_sheet.dart';

class AddFoodPage extends ConsumerStatefulWidget {
  final String mealType;
  final bool startOnSearch;
  final bool focusSearch;

  const AddFoodPage({
    super.key,
    required this.mealType,
    this.startOnSearch = false,
    this.focusSearch = false,
  });

  @override
  ConsumerState<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends ConsumerState<AddFoodPage>
    with TickerProviderStateMixin {
  late final TabController _mainTabController;
  late final TabController _searchTabController;
  final TextEditingController _searchController = TextEditingController();
  _SearchCategory _selectedCategory = _SearchCategory.foods;
  bool _loggedView = false;
  int _sessionAddedCount = 0;
  bool _postLogUpsellShown = false;
  DateTime? _lastQueryLoggedAt;
  String _lastLoggedQuery = '';
  Timer? _searchDebounce;

  String get _doneLabel {
    final count = _sessionAddedCount;
    if (count <= 0) return 'Concluir';
    final suffix = count == 1 ? 'item' : 'itens';
    return 'Concluir ($count $suffix)';
  }

  void _logSearchQuery(String raw) {
    final query = raw.trim();
    final now = DateTime.now();
    final lastAt = _lastQueryLoggedAt;

    if (query.isNotEmpty &&
        lastAt != null &&
        now.difference(lastAt).inMilliseconds < 600) {
      return;
    }

    if (query == _lastLoggedQuery) return;

    _lastQueryLoggedAt = now;
    _lastLoggedQuery = query;
    ref.read(analyticsServiceProvider).logEvent('food_search_query', {
      'meal_type': widget.mealType,
      'query_len': query.length,
      'is_empty': query.isEmpty,
    });
  }

  void _onSearchChanged(String raw) {
    final query = raw.trim();
    final notifier = ref.read(foodSearchNotifierProvider.notifier);

    notifier.setQuery(query);
    _searchDebounce?.cancel();

    if (query.isEmpty) {
      notifier.search('');
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      notifier.search(query);
    });
  }

  String get _mealDisplayName {
    switch (widget.mealType) {
      case 'breakfast':
        return 'Café da manhã';
      case 'lunch':
        return 'Almoço';
      case 'dinner':
        return 'Jantar';
      case 'snack':
        return 'Lanche';
      default:
        return widget.mealType;
    }
  }

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.startOnSearch ? 1 : 0,
    );
    _searchTabController = TabController(length: 3, vsync: this);

    _mainTabController.addListener(() {
      if (!_mainTabController.indexIsChanging) {
        final tab = _mainTabController.index == 0 ? 'ai_camera' : 'search';
        ref.read(analyticsServiceProvider).logEvent('food_search_tab_view', {
          'meal_type': widget.mealType,
          'tab': tab,
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_loggedView) {
        _loggedView = true;
        ref.read(analyticsServiceProvider).logEvent('food_search_view', {
          'meal_type': widget.mealType,
        });
      }
      ref.read(foodSearchNotifierProvider.notifier).search('');
      ref.read(foodSearchNotifierProvider.notifier).loadFavorites();
      ref.read(foodSearchNotifierProvider.notifier).loadRecents();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _mainTabController.dispose();
    _searchTabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _comingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label em breve.')));
  }

  void _showAddedSnackBar({
    required BuildContext pageContext,
    required String foodName,
    required int calories,
  }) {
    ScaffoldMessenger.of(pageContext).hideCurrentSnackBar();
    ScaffoldMessenger.of(pageContext).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection
            .horizontal, // Permite deslizar para o lado para apagar
        duration: const Duration(
          milliseconds: 1200,
        ), // Tempo um pouquinho menor
        content: Text('Adicionado: $foodName (+$calories kcal)'),
        action: SnackBarAction(
          label: 'Diário',
          onPressed: () {
            if (pageContext.mounted) {
              pageContext.pop();
            }
          },
        ),
      ),
    );
  }

  Future<void> _maybeShowPostLogUpsell(
    BuildContext pageContext, {
    required String source,
  }) async {
    if (_postLogUpsellShown) return;
    if (_sessionAddedCount != 1) return;
    if (ref.read(subscriptionProvider).isPro) return;

    _postLogUpsellShown = true;

    final analytics = ref.read(analyticsServiceProvider);
    await analytics.logEvent('post_log_upsell_shown', {
      'meal_type': widget.mealType,
      'source': source,
    });

    if (!pageContext.mounted) return;

    await showDialog<void>(
      context: pageContext,
      builder: (dialogContext) {
        final router = GoRouter.of(pageContext);
        return AlertDialog(
          title: const Text('Desbloquear Premium?'),
          content: const Text(
            'Desbloqueie scanner e estatísticas avançadas. '
            'Se elegível, você pode iniciar um teste grátis e cancelar quando quiser.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await analytics.logEvent('post_log_upsell_dismiss', {
                  'meal_type': widget.mealType,
                  'source': source,
                });
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              },
              child: const Text('Agora não'),
            ),
            ElevatedButton(
              onPressed: () async {
                await analytics.logEvent('post_log_upsell_tap', {
                  'meal_type': widget.mealType,
                  'source': source,
                });
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                if (mounted) await router.push('/premium');
              },
              child: const Text('Ver planos'),
            ),
          ],
        );
      },
    );
  }

  void _showFoodConfirmationDialog(BuildContext rootContext, Food food) {
    final analytics = ref.read(analyticsServiceProvider);
    analytics.logEvent('food_selected', {
      'meal_type': widget.mealType,
      'source': 'ai',
      'food_id': food.id,
      'food_name': food.name,
    });
    analytics.logEvent('portion_edit_view', {
      'meal_type': widget.mealType,
      'source': 'ai',
      'food_id': food.id,
    });
    showModalBottomSheet(
      context: rootContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => FoodDetailSheet(
        foodItem: FoodItem(
          id: food.id,
          name: food.name,
          calories: food.calories.value,
          servingSize: '${food.servingSize} ${food.servingUnit}',
          protein: food.macros.protein,
          carbs: food.macros.carbs,
          fat: food.macros.fat,
          brand: food.brand,
          imageUrl: null,
        ),
        onAdd: (quantity) {
          () async {
            final decision = await ref
                .read(mealLogGateProvider)
                .tryConsumeAllowance();
            if (!decision.allowed) {
              if (sheetContext.mounted) Navigator.pop(sheetContext);
              if (!mounted) return;
              if (decision.blockReason ==
                  MealLogBlockReason.challengeUsedToday) {
                await ref.read(analyticsServiceProvider).logEvent(
                  'challenge_used_today_blocked',
                  {'source': 'add_food_ai'},
                );
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Você já registrou a refeição do desafio hoje. Volte amanhã.',
                    ),
                    action: SnackBarAction(
                      label: 'Premium',
                      onPressed: () {
                        context.push('/premium');
                      },
                    ),
                  ),
                );
                return;
              }
              await context.push('/premium');
              return;
            }

            await ref
                .read(diaryNotifierProvider.notifier)
                .addFoodToMeal(
                  MealType.values.firstWhere((e) => e.name == widget.mealType),
                  food,
                  quantity,
                );
            final addedCalories = (food.calories.value * quantity).round();
            await analytics.logEvent('meal_item_added', {
              'meal_type': widget.mealType,
              'source': 'ai',
              'food_id': food.id,
              'calories': food.calories.value.round(),
            });
            await analytics.logTimeToFirstMealIfNeeded(
              mealType: widget.mealType,
            );
            if (mounted) setState(() => _sessionAddedCount += 1);
            unawaited(
              ref.read(foodSearchNotifierProvider.notifier).loadRecents(),
            );
            ref.read(aiFoodNotifierProvider.notifier).clearResult();
            if (sheetContext.mounted)
              Navigator.pop(sheetContext); // Fecha sheet
            if (!mounted) return;
            _showAddedSnackBar(
              pageContext: context,
              foodName: food.name,
              calories: addedCalories,
            );

            if (decision.consumedFreeMeal) {
              await _showFirstMealWowSheet(
                pageContext: context,
                foodName: food.name,
                proteinAddedGrams: food.macros.protein * quantity,
                caloriesAdded: addedCalories,
              );
            } else if (decision.challengeCompletedNow) {
              await _showChallengeCompletedOffer(context);
            } else {
              await _maybeShowPostLogUpsell(context, source: 'ai');
            }
          }();
        },
      ),
    );
  }

  void _openFoodSheet(FoodItem food) {
    FocusScope.of(context).unfocus();
    ref.read(analyticsServiceProvider).logEvent('food_selected', {
      'meal_type': widget.mealType,
      'source': 'search',
      'food_id': food.id,
      'food_name': food.name,
    });
    ref.read(analyticsServiceProvider).logEvent('portion_edit_view', {
      'meal_type': widget.mealType,
      'source': 'search',
      'food_id': food.id,
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => FoodDetailSheet(
        foodItem: food,
        onAdd: (quantity) {
          () async {
            final decision = await ref
                .read(mealLogGateProvider)
                .tryConsumeAllowance();
            if (!decision.allowed) {
              if (sheetContext.mounted) Navigator.pop(sheetContext);
              if (!mounted) return;
              if (decision.blockReason ==
                  MealLogBlockReason.challengeUsedToday) {
                await ref.read(analyticsServiceProvider).logEvent(
                  'challenge_used_today_blocked',
                  {'source': 'add_food_search'},
                );
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Você já registrou a refeição do desafio hoje. Volte amanhã.',
                    ),
                    action: SnackBarAction(
                      label: 'Premium',
                      onPressed: () {
                        context.push('/premium');
                      },
                    ),
                  ),
                );
                return;
              }
              await context.push('/premium');
              return;
            }

            await ref
                .read(diaryNotifierProvider.notifier)
                .addFoodToMeal(
                  MealType.values.firstWhere((e) => e.name == widget.mealType),
                  food.toDomain(),
                  quantity,
                );
            final addedCalories = (food.calories * quantity).round();
            final analytics = ref.read(analyticsServiceProvider);
            await analytics.logEvent('meal_item_added', {
              'meal_type': widget.mealType,
              'source': 'search',
              'food_id': food.id,
              'calories': food.calories.round(),
            });
            await analytics.logTimeToFirstMealIfNeeded(
              mealType: widget.mealType,
            );
            if (mounted) setState(() => _sessionAddedCount += 1);
            unawaited(
              ref.read(foodSearchNotifierProvider.notifier).loadRecents(),
            );
            if (sheetContext.mounted) Navigator.pop(sheetContext);
            if (!mounted) return;
            _showAddedSnackBar(
              pageContext: context,
              foodName: food.name,
              calories: addedCalories,
            );

            if (decision.consumedFreeMeal) {
              await _showFirstMealWowSheet(
                pageContext: context,
                foodName: food.name,
                proteinAddedGrams: food.protein * quantity,
                caloriesAdded: addedCalories,
              );
            } else if (decision.challengeCompletedNow) {
              await _showChallengeCompletedOffer(context);
            } else {
              await _maybeShowPostLogUpsell(context, source: 'search');
            }
          }();
        },
      ),
    );
  }

  Future<void> _showFirstMealWowSheet({
    required BuildContext pageContext,
    required String foodName,
    required double proteinAddedGrams,
    required int caloriesAdded,
  }) async {
    final profile = ref.read(profileNotifierProvider);
    final remainingProtein = (profile.proteinGrams - proteinAddedGrams).round();
    final remainingCalories = profile.calculatedCalories - caloriesAdded;
    final analytics = ref.read(analyticsServiceProvider);
    await analytics.logEvent('first_meal_wow_shown', {
      'meal_type': widget.mealType,
      'remaining_protein_g': remainingProtein,
    });

    if (!pageContext.mounted) return;
    await showModalBottomSheet<void>(
      context: pageContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ajuste automático do seu dia',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Boa. Você registrou $foodName. Agora falta pouco para ficar no trilho.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              _InlineMessageCard(
                icon: Icons.bolt_rounded,
                title: 'Próximo passo (simples)',
                subtitle:
                    'Tente bater proteína hoje. Faltam ~${remainingProtein < 0 ? 0 : remainingProtein}g '
                    'e ~${remainingCalories < 0 ? 0 : remainingCalories} kcal.',
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Sugestões rápidas',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const _InlineMessageCard(
                icon: Icons.check_circle_outline,
                title: 'Opções ricas em proteína',
                subtitle:
                    'Ovos • iogurte grego • frango/peixe • queijo cottage • whey.',
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await analytics.logEvent('first_meal_wow_cta_tap', {
                      'meal_type': widget.mealType,
                    });
                    if (ctx.mounted) Navigator.of(ctx).pop();
                    if (pageContext.mounted) await pageContext.push('/premium');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.premium,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Desbloquear IA por foto'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Continuar depois'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showChallengeCompletedOffer(BuildContext pageContext) async {
    final analytics = ref.read(analyticsServiceProvider);
    await analytics.logEvent('challenge_completed_offer_shown', {});
    if (!pageContext.mounted) return;

    await showDialog<void>(
      context: pageContext,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Desafio concluído'),
          content: const Text(
            'Você completou 3 dias. Quer destravar a análise por foto e continuar no automático?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Agora não'),
            ),
            ElevatedButton(
              onPressed: () async {
                await analytics.logEvent('challenge_completed_offer_tap', {});
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (pageContext.mounted) await pageContext.push('/premium');
              },
              child: const Text('Ver planos'),
            ),
          ],
        );
      },
    );
  }

  void _startAiCapture(ImageSource source) {
    if (ref.read(aiFoodNotifierProvider).isLoading) return;
    if (!ref.read(mealLogGateProvider).canUseAiPhoto()) {
      context.push('/premium');
      return;
    }
    ref.read(aiFoodNotifierProvider.notifier).pickAndAnalyzeImage(source);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aiState = ref.watch(aiFoodNotifierProvider);
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = keyboardInset > 0;

    ref.listen(aiFoodNotifierProvider, (previous, next) {
      if (next.analyzedFood != null && !next.isLoading) {
        _showFoodConfirmationDialog(context, next.analyzedFood!);
      }
      if (next.error != null &&
          next.error != previous?.error &&
          mounted &&
          !next.isLoading) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    if (aiState.error != null) {
      ref.read(analyticsServiceProvider).logEvent('error_shown', {
        'error_context': 'ai_food',
        'meal_type': widget.mealType,
        'error_message': aiState.error!,
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary.withValues(alpha: 0.9),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _mealDisplayName,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _mainTabController,
              children: [_buildAICameraTab(aiState), _buildSearchTab()],
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: isKeyboardOpen
                ? const SizedBox.shrink()
                : _BottomTabs(controller: _mainTabController),
          ),
        ],
      ),
    );
  }

  Widget _buildAICameraTab(AiFoodState aiState) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        bottomPadding + 120,
      ),
      children: [
        const SectionHeader(title: 'Câmera com IA'),
        _Card(
          padding: const EdgeInsets.all(AppSpacing.lg),
          onTap: aiState.isLoading
              ? null
              : () => _startAiCapture(ImageSource.camera),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: AppColors.accent,
                  size: 26,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Reconhecimento por foto',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.premium.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            'IA',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Tire uma foto do prato e confirme as informações antes de adicionar ao diário.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (aiState.error != null) ...[
          const SizedBox(height: AppSpacing.md),
          _InlineMessageCard(
            icon: Icons.error_outline_rounded,
            title: 'Não foi possível analisar a foto',
            subtitle: aiState.error!,
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: aiState.isLoading
                ? null
                : () => _startAiCapture(ImageSource.camera),
            icon: aiState.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.camera_alt_rounded),
            label: Text(aiState.isLoading ? 'Analisando…' : 'Tirar foto'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              textStyle: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: aiState.isLoading
              ? null
              : () => _startAiCapture(ImageSource.gallery),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: const TextStyle(fontWeight: FontWeight.w900),
          ),
          child: const Text('Escolher da galeria'),
        ),
        const SizedBox(height: AppSpacing.lg),
        const _InlineMessageCard(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacidade',
          subtitle: 'Suas fotos ficam apenas no seu dispositivo.',
        ),
      ],
    );
  }

  Widget _buildSearchTab() {
    final theme = Theme.of(context);
    final state = ref.watch(foodSearchNotifierProvider);
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final showDoneBar = _sessionAddedCount > 0 && !isKeyboardOpen;
    final showFilters = !isKeyboardOpen;
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    final bottomTabsHeight = kBottomNavigationBarHeight + bottomSafe;
    final doneBarHeight = showDoneBar ? (isKeyboardOpen ? 68.0 : 80.0) : 0.0;
    final doneBarBottom = showDoneBar
        ? (isKeyboardOpen ? 0.0 : bottomTabsHeight)
        : 0.0;
    final listBottomPadding =
        doneBarHeight +
        AppSpacing.sm +
        (isKeyboardOpen ? 0.0 : bottomTabsHeight);

    return Stack(
      fit: StackFit.expand,
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: _SearchFieldCard(
                controller: _searchController,
                hintText:
                    'O que você comeu no ${_mealDisplayName.toLowerCase()}?',
                autofocus: widget.focusSearch && widget.startOnSearch,
                onChanged: (value) {
                  _onSearchChanged(value);
                  _logSearchQuery(value);
                },
                onBarcodeTap: () => _comingSoon(context, 'Código de barras'),
                onClear: () {
                  _searchController.clear();
                  _searchDebounce?.cancel();
                  final notifier = ref.read(
                    foodSearchNotifierProvider.notifier,
                  );
                  notifier.setQuery('');
                  notifier.search('');
                  _logSearchQuery('');
                  FocusScope.of(context).unfocus();
                },
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: showFilters
                  ? Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          child: Row(
                            children: [
                              _CategoryTile(
                                icon: Icons.restaurant_rounded,
                                label: 'Alimentos',
                                isSelected:
                                    _selectedCategory == _SearchCategory.foods,
                                onTap: () => setState(() {
                                  _selectedCategory = _SearchCategory.foods;
                                }),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              _CategoryTile(
                                icon: Icons.restaurant_menu_rounded,
                                label: 'Refeições',
                                isSelected:
                                    _selectedCategory == _SearchCategory.meals,
                                onTap: () {
                                  setState(
                                    () => _selectedCategory =
                                        _SearchCategory.meals,
                                  );
                                  _comingSoon(context, 'Refeições');
                                },
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              _CategoryTile(
                                icon: Icons.menu_book_rounded,
                                label: 'Receitas',
                                isSelected:
                                    _selectedCategory ==
                                    _SearchCategory.recipes,
                                onTap: () {
                                  setState(
                                    () => _selectedCategory =
                                        _SearchCategory.recipes,
                                  );
                                  _comingSoon(context, 'Receitas');
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusXl,
                            ),
                            border: Border.all(color: AppColors.border),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: TabBar(
                            controller: _searchTabController,
                            labelColor: AppColors.primary,
                            unselectedLabelColor: AppColors.textSecondary,
                            indicatorColor: AppColors.primary,
                            indicatorWeight: 3,
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.2,
                            ),
                            unselectedLabelStyle: const TextStyle(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                            tabs: const [
                              Tab(text: 'FREQUENTES'),
                              Tab(text: 'RECENTES'),
                              Tab(text: 'FAVORITOS'),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
            Expanded(
              child: TabBarView(
                controller: _searchTabController,
                children: [
                  _buildFoodTab(
                    state,
                    tab: _SearchSubTab.frequent,
                    bottomPadding: listBottomPadding,
                  ),
                  _buildFoodTab(
                    state,
                    tab: _SearchSubTab.recent,
                    bottomPadding: listBottomPadding,
                  ),
                  _buildFoodTab(
                    state,
                    tab: _SearchSubTab.favorites,
                    bottomPadding: listBottomPadding,
                  ),
                ],
              ),
            ),
          ],
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          child: showDoneBar
              ? AnimatedPositioned(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  left: 0,
                  right: 0,
                  bottom: doneBarBottom,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm, // Menos espaço vertical
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border(top: BorderSide(color: AppColors.border)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow.withValues(alpha: 0.10),
                          blurRadius: 14,
                          offset: const Offset(0, -6),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            ref
                                .read(analyticsServiceProvider)
                                .logEvent('food_search_done_tap', {
                                  'meal_type': widget.mealType,
                                  'items_added': _sessionAddedCount,
                                });
                            context.pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: isKeyboardOpen
                                  ? 10
                                  : 12, // Botão um pouco mais fino
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                            textStyle: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize:
                                  15, // Fonte levemente menor para compensar
                            ),
                          ),
                          child: Text(_doneLabel),
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildFoodTab(
    FoodSearchState state, {
    required _SearchSubTab tab,
    required double bottomPadding,
  }) {
    if (_selectedCategory != _SearchCategory.foods) {
      return const _EmptyState(
        icon: Icons.auto_awesome_rounded,
        title: 'Em breve',
        subtitle: 'Estamos preparando mais opções para você.',
      );
    }

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.error != null) {
      ref.read(analyticsServiceProvider).logEvent('error_shown', {
        'error_context': 'food_search',
        'meal_type': widget.mealType,
        'error_message': state.error!,
      });
      return const _InlineMessageCard(
        icon: Icons.cloud_off_rounded,
        title: 'Sem conexão',
        subtitle: 'Não foi possível buscar alimentos agora.',
      );
    }

    if (tab == _SearchSubTab.recent && state.query.isEmpty) {
      if (state.recentFoods.isEmpty) {
        return const _EmptyState(
          icon: Icons.history_rounded,
          title: 'Nada recente',
          subtitle: 'Seus itens recentes aparecerão aqui.',
        );
      }
    }

    final List<FoodItem> items;
    if (tab == _SearchSubTab.favorites) {
      if (state.query.isEmpty) {
        items = state.favoriteFoods;
      } else {
        final lowerQuery = state.query.toLowerCase();
        items = state.favoriteFoods
            .where(
              (food) =>
                  food.name.toLowerCase().contains(lowerQuery) ||
                  (food.brand ?? '').toLowerCase().contains(lowerQuery),
            )
            .toList();
      }
    } else if (tab == _SearchSubTab.recent && state.query.isEmpty) {
      items = state.recentFoods;
    } else {
      items = state.results;
    }

    if (items.isNotEmpty) {
      return ListView.separated(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          bottomPadding,
        ),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final food = items[index];
          final query = state.query;
          final notifier = ref.read(foodSearchNotifierProvider.notifier);
          return _FoodResultTile(
            food: food,
            onTap: () => _openFoodSheet(food),
            isFavorite: notifier.isFavorite(food),
            onFavoriteToggle: () => notifier.toggleFavorite(food),
            highlightQuery: query.isEmpty ? null : query,
          );
        },
      );
    }

    if (state.query.isNotEmpty) {
      return const _EmptyState(
        icon: Icons.search_off_rounded,
        title: 'Nenhum resultado',
        subtitle: 'Tente outro termo ou procure por marca.',
      );
    }

    if (tab == _SearchSubTab.favorites) {
      return const _EmptyState(
        icon: Icons.star_border_rounded,
        title: 'Sem favoritos',
        subtitle: 'Toque na estrela para salvar seus alimentos.',
      );
    }

    return const _EmptyState(
      icon: Icons.search_rounded,
      title: 'Busque um alimento',
      subtitle: 'Digite para buscar ou use o código de barras.',
    );
  }
}

enum _SearchCategory { foods, meals, recipes }

enum _SearchSubTab { frequent, recent, favorites }

class _BottomTabs extends StatelessWidget {
  final TabController controller;

  const _BottomTabs({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: TabBar(
          controller: controller,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
          tabs: const [
            Tab(icon: Icon(Icons.camera_alt_rounded), text: 'CÂMERA IA'),
            Tab(icon: Icon(Icons.search_rounded), text: 'BUSCAR'),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const _Card({required this.child, required this.padding, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: Ink(
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.10),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SearchFieldCard extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool autofocus;
  final ValueChanged<String> onChanged;
  final VoidCallback onBarcodeTap;
  final VoidCallback onClear;

  const _SearchFieldCard({
    required this.controller,
    required this.hintText,
    this.autofocus = false,
    required this.onChanged,
    required this.onBarcodeTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _Card(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: AppColors.textHint),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              autofocus: autofocus,
              textInputAction: TextInputAction.search,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              onPressed: onClear,
              icon: Icon(Icons.close_rounded, color: AppColors.textHint),
              tooltip: 'Limpar',
            ),
          IconButton(
            onPressed: onBarcodeTap,
            icon: Icon(
              Icons.qr_code_scanner_rounded,
              color: AppColors.textHint,
            ),
            tooltip: 'Código de barras',
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.10)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.35)
                    : AppColors.border,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textPrimary.withValues(alpha: 0.45),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FoodResultTile extends StatelessWidget {
  final FoodItem food;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final String? highlightQuery;

  const _FoodResultTile({
    required this.food,
    required this.onTap,
    required this.isFavorite,
    required this.onFavoriteToggle,
    this.highlightQuery,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(
                  Icons.restaurant_rounded,
                  color: AppColors.textPrimary.withValues(alpha: 0.35),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HighlightedText(text: food.name, query: highlightQuery),
                    const SizedBox(height: 4),
                    Text(
                      '${food.calories.round()} kcal',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      children: [
                        _MetaPill(
                          icon: Icons.straighten_rounded,
                          label: food.servingSize,
                        ),
                        if (food.id.isNotEmpty)
                          _SourcePill(isLocal: food.id.startsWith('local_')),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: onFavoriteToggle,
                    icon: Icon(
                      isFavorite
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: isFavorite
                          ? AppColors.secondary
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                    tooltip: isFavorite
                        ? 'Remover favorito'
                        : 'Salvar favorito',
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
                    splashRadius: 18,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add_rounded),
                      color: AppColors.primary,
                      iconSize: 18,
                      onPressed: onTap,
                      tooltip: 'Adicionar',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _MacroPill(
                  label: 'C ${food.carbs.toStringAsFixed(0)}g',
                  color: AppColors.carbs,
                ),
                _MacroPill(
                  label: 'P ${food.protein.toStringAsFixed(0)}g',
                  color: AppColors.protein,
                ),
                _MacroPill(
                  label: 'G ${food.fat.toStringAsFixed(0)}g',
                  color: AppColors.fat,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textHint),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightedText extends StatelessWidget {
  final String text;
  final String? query;

  const _HighlightedText({required this.text, this.query});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w900,
      fontSize: 15,
      color: AppColors.textPrimary,
    );

    final rawQuery = query?.trim();
    if (rawQuery == null || rawQuery.isEmpty) {
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: baseStyle,
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = rawQuery.toLowerCase();
    final matchIndex = lowerText.indexOf(lowerQuery);

    if (matchIndex < 0) {
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: baseStyle,
      );
    }

    final before = text.substring(0, matchIndex);
    final match = text.substring(matchIndex, matchIndex + rawQuery.length);
    final after = text.substring(matchIndex + rawQuery.length);

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: before),
          TextSpan(
            text: match,
            style: baseStyle?.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w900,
            ),
          ),
          TextSpan(text: after),
        ],
      ),
    );
  }
}

class _SourcePill extends StatelessWidget {
  final bool isLocal;

  const _SourcePill({required this.isLocal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isLocal ? AppColors.primary : AppColors.accent;
    final label = isLocal ? 'Local' : 'Online';
    final icon = isLocal ? Icons.offline_bolt_rounded : Icons.cloud_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroPill extends StatelessWidget {
  final String label;
  final Color color;

  const _MacroPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 11,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(icon, color: AppColors.textHint),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineMessageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InlineMessageCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _Card(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, color: AppColors.textHint),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
