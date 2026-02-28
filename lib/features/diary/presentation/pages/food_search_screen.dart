import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutriz/core/monetization/meal_log_gate.dart';
import 'package:nutriz/core/analytics/analytics_providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/food.dart';
import '../../domain/entities/food_item.dart';
import '../../domain/entities/meal.dart' hide FoodItem;
import '../notifiers/food_search_notifier.dart';
import '../providers/ai_food_provider.dart';
import '../providers/diary_providers.dart';
import '../widgets/food_detail_sheet.dart';
import 'create_custom_food_screen.dart';
import 'barcode_scanner_screen.dart';

class FoodSearchScreen extends ConsumerStatefulWidget {
  final String mealType;

  const FoodSearchScreen({super.key, required this.mealType});

  @override
  ConsumerState<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends ConsumerState<FoodSearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showFoodConfirmationDialog(BuildContext rootContext, Food food) {
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
          imageUrl: null, // AI might not give image URL immediately
        ),
        onAdd: (quantity) {
          () async {
            final decision = await ref
                .read(mealLogGateProvider)
                .tryConsumeAllowance();
            if (!decision.allowed) {
              if (sheetContext.mounted) sheetContext.pop(); // Close sheet
              if (!mounted) return;
              if (decision.blockReason ==
                  MealLogBlockReason.challengeUsedToday) {
                await ref.read(analyticsServiceProvider).logEvent(
                  'challenge_used_today_blocked',
                  {'source': 'food_search_ai'},
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

            await ref.read(analyticsServiceProvider).logEvent(
              'refeicao_registrada_ia',
              {'food_name': food.name, 'meal_type': widget.mealType},
            );

            await ref
                .read(diaryNotifierProvider.notifier)
                .addFoodToMeal(
                  MealType.values.firstWhere((e) => e.name == widget.mealType),
                  food,
                  quantity,
                );
            ref.read(aiFoodNotifierProvider.notifier).clearResult();
            if (sheetContext.mounted) sheetContext.pop(); // Close sheet
            if (!mounted) return;
            context.pop(); // Close screen
          }();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(foodSearchNotifierProvider);
    final aiState = ref.watch(aiFoodNotifierProvider);

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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              ref.read(foodSearchNotifierProvider.notifier).search(value);
            },
            decoration: InputDecoration(
              hintText: 'Buscar alimento...',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
              prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        actions: [
          if (aiState.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.black),
              tooltip: 'Reconhecimento por IA',
              onPressed: () => _showImageSourceSheet(context),
            ),
            IconButton(
              icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
              tooltip: 'Ler código de barras',
              onPressed: () async {
                final String? barcode = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BarcodeScannerScreen(),
                  ),
                );

                if (barcode != null && barcode.isNotEmpty && mounted) {
                  // Mostrar loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Buscando código de barras...'),
                    ),
                  );

                  final service = ref.read(foodServiceProvider);
                  final foodItem = await service.scanBarcode(barcode);

                  if (foodItem != null && mounted) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    // Converte FoodItem model base de volta para Food Entity padrão do _showFoodConfirmationDialog
                    // Nota: O método _showFoodConfirmationDialog aceita Food (domínio).
                    final food = Food(
                      id: foodItem.id,
                      name: foodItem.name,
                      calories: Calories(foodItem.calories),
                      macros: MacroNutrients(
                        protein: foodItem.protein,
                        carbs: foodItem.carbs,
                        fat: foodItem.fat,
                      ),
                      servingSize: 100, // OFF default is 100g
                      servingUnit: 'g',
                      brand: foodItem.brand,
                    );
                    _showFoodConfirmationDialog(context, food);
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Alimento não encontrado pelo código de barras.',
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.black),
              tooltip: 'Adicionar Alimento Manual',
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateCustomFoodScreen(),
                  ),
                );
                if (result == true) {
                  // Se o usuário adicionou um alimento, recarregamos a busca
                  ref
                      .read(foodSearchNotifierProvider.notifier)
                      .search(_searchController.text);
                }
              },
            ),
          ],
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: 'Histórico'),
              Tab(text: 'Favoritos'),
              Tab(text: 'Frequentes'),
              Tab(text: 'Novos'),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // AI Camera Entry Point (Yazio style banner/button)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: () {
                _showImageSourceSheet(context);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.2),
                      AppColors.primary.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Reconhecimento por IA',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'AI',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tire uma foto para adicionar alimentos rapidamente',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSearchResults(state),
                _buildPlaceholder('Favoritos'),
                _buildPlaceholder('Frequentes'),
                _buildPlaceholder('Novos'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceSheet(BuildContext sheetContext) {
    showModalBottomSheet(
      context: sheetContext,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tirar foto'),
                onTap: () {
                  Navigator.pop(context);
                  if (!ref.read(mealLogGateProvider).canUseAiPhoto()) {
                    if (mounted) this.context.push('/premium');
                    return;
                  }
                  ref.read(analyticsServiceProvider).logEvent('scan_iniciado', {
                    'source': 'camera',
                  });
                  ref
                      .read(aiFoodNotifierProvider.notifier)
                      .pickAndAnalyzeImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Escolher da galeria'),
                onTap: () {
                  Navigator.pop(context);
                  if (!ref.read(mealLogGateProvider).canUseAiPhoto()) {
                    if (mounted) this.context.push('/premium');
                    return;
                  }
                  ref.read(analyticsServiceProvider).logEvent('scan_iniciado', {
                    'source': 'gallery',
                  });
                  ref
                      .read(aiFoodNotifierProvider.notifier)
                      .pickAndAnalyzeImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(FoodSearchState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(child: Text(state.error!));
    }

    if (state.results.isEmpty && state.query.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Nenhum alimento encontrado',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (state.results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Digite para buscar',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: state.results.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final food = state.results[index];
        return _buildFoodItem(food);
      },
    );
  }

  Widget _buildFoodItem(FoodItem food) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => FoodDetailSheet(
            foodItem: food,
            onAdd: (quantity) {
              ref
                  .read(diaryNotifierProvider.notifier)
                  .addFoodToMeal(
                    MealType.values.firstWhere(
                      (e) => e.name == widget.mealType,
                    ),
                    food.toDomain(),
                    quantity,
                  );
              context.pop();
            },
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                image: food.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(food.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: food.imageUrl == null
                  ? Icon(Icons.restaurant, color: Colors.grey[400], size: 24)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${food.calories.round()} kcal',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        ' • ${food.servingSize}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: AppColors.primary, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No $title yet',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
