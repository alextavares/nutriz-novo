import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/ai_food_provider.dart';
import '../notifiers/ai_food_notifier.dart';
import '../providers/diary_providers.dart';
import '../../domain/entities/food.dart';
import '../../domain/entities/food_item.dart';
import '../../domain/entities/meal.dart' hide FoodItem;
import '../notifiers/food_search_notifier.dart';
import '../widgets/food_detail_sheet.dart';

class AddFoodPage extends ConsumerStatefulWidget {
  final String mealType;

  const AddFoodPage({super.key, required this.mealType});

  @override
  ConsumerState<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends ConsumerState<AddFoodPage>
    with TickerProviderStateMixin {
  late TabController _mainTabController;
  late TabController _searchTabController;
  final TextEditingController _searchController = TextEditingController();

  String get _mealDisplayName {
    switch (widget.mealType) {
      case 'breakfast':
        return 'Café da Manhã';
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
    _mainTabController = TabController(length: 2, vsync: this);
    _searchTabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _searchTabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showFoodConfirmationDialog(BuildContext context, Food food) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FoodDetailSheet(
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
          ref
              .read(diaryNotifierProvider.notifier)
              .addFoodToMeal(
                MealType.values.firstWhere((e) => e.name == widget.mealType),
                food,
                quantity,
              );
          ref.read(aiFoodNotifierProvider.notifier).clearResult();
          context.pop(); // Close sheet
          context.pop(); // Close screen
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiFoodNotifierProvider);

    ref.listen(aiFoodNotifierProvider, (previous, next) {
      if (next.analyzedFood != null && !next.isLoading) {
        _showFoodConfirmationDialog(context, next.analyzedFood!);
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
        title: Text(
          _mealDisplayName,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Main content
          Expanded(
            child: TabBarView(
              controller: _mainTabController,
              children: [_buildAICameraTab(aiState), _buildSearchTab()],
            ),
          ),
          // Bottom tabs
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: TabBar(
                controller: _mainTabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                tabs: const [
                  Tab(icon: Icon(Icons.camera_alt), text: 'AI Camera'),
                  Tab(icon: Icon(Icons.search), text: 'Search'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAICameraTab(AiFoodState aiState) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Demo Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, size: 20),
                          onPressed: () {},
                        ),
                        const Text(
                          'Meal Summary',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Food Image
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Food preview',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Grilled halloumi with quinoa, tomato and cucumber salad, pita bread, hummus and lemonade',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Promo Section
            const Text(
              'You snap it, we track it!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI-powered photo recognition offers a range of powerful benefits.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Action Button
            if (aiState.isLoading)
              const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            else
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showImageSourceSheet(context),
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      label: const Text(
                        'Take a Photo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => _showImageSourceSheet(context),
                    child: const Text(
                      'Choose from Gallery',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
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
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  ref
                      .read(aiFoodNotifierProvider.notifier)
                      .pickAndAnalyzeImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
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

  Widget _buildSearchTab() {
    final state = ref.watch(foodSearchNotifierProvider);

    return Column(
      children: [
        // Search Field
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
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
                hintText:
                    'What did you have for ${_mealDisplayName.toLowerCase()}?',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  color: Colors.grey[600],
                  onPressed: () {
                    // TODO: Barcode scanner
                  },
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        // Category Icons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildCategoryChip('🍎', 'Foods', true),
              const SizedBox(width: 12),
              _buildCategoryChip('🍽️', 'Meals', false),
              const SizedBox(width: 12),
              _buildCategoryChip('📖', 'Recipes', false),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Sub Tabs
        TabBar(
          controller: _searchTabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: AppColors.primary,
          indicatorWeight: 2,
          tabs: const [
            Tab(text: 'FREQUENT'),
            Tab(text: 'RECENT'),
            Tab(text: 'FAVORITES'),
          ],
        ),
        // Food List
        Expanded(
          child: TabBarView(
            controller: _searchTabController,
            children: [
              _buildFoodList(state), // Frequent
              _buildFoodList(state), // Recent
              _buildPlaceholder('No favorites yet'),
            ],
          ),
        ),
        // Done Button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String emoji, String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
            : null,
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? AppColors.primary : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodList(FoodSearchState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.query.isNotEmpty && state.results.isNotEmpty) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: state.results.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final food = state.results[index];
          return _buildFoodItem(food);
        },
      );
    }

    // Show placeholder for frequent foods
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Start typing to search',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    food.servingSize,
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Text(
              '${food.calories.round()} Cal',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.grey, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star_border, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
