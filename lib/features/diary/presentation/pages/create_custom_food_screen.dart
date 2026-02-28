import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../gamification/presentation/providers/gamification_providers.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/food.dart';
import '../../data/services/custom_food_service.dart';
import '../../../../core/value_objects/calories.dart';
import '../../../../core/value_objects/macro_nutrients.dart';
import '../notifiers/food_search_notifier.dart';

class CreateCustomFoodScreen extends ConsumerStatefulWidget {
  const CreateCustomFoodScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateCustomFoodScreen> createState() =>
      _CreateCustomFoodScreenState();
}

class _CreateCustomFoodScreenState
    extends ConsumerState<CreateCustomFoodScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _servingSizeController = TextEditingController(text: '100');

  String _servingUnit = 'g';

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _servingSizeController.dispose();
    super.dispose();
  }

  void _saveFood() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final isar = ref.read(isarProvider);
      final service = CustomFoodService(isar: isar);

      final food = Food(
        id: '', // Will be assigned upon Isar save and generation
        name: _nameController.text.trim(),
        brand: _brandController.text.trim().isEmpty
            ? null
            : _brandController.text.trim(),
        calories: Calories(double.parse(_caloriesController.text)),
        macros: MacroNutrients(
          protein: double.parse(_proteinController.text),
          carbs: double.parse(_carbsController.text),
          fat: double.parse(_fatController.text),
        ),
        servingSize: double.parse(_servingSizeController.text),
        servingUnit: _servingUnit,
      );

      await service.saveCustomFood(food);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${food.name} salvo com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true); // Retorna true indicando sucesso
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar alimento: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Alimento'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Informações Básicas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _nameController,
              label: 'Nome do alimento *',
              hint: 'Ex: Arroz Integral Caseiro',
              textInputAction: TextInputAction.next,
              validator: (val) {
                if (val == null || val.trim().isEmpty)
                  return 'Nome é obrigatório';
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _brandController,
              label: 'Marca (Opcional)',
              hint: 'Ex: Tio João',
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 32),
            const Text(
              'Informação Nutricional',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: AppTextField(
                    controller: _servingSizeController,
                    label: 'Porção *',
                    hint: '100',
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Obrigatório';
                      if (double.tryParse(val) == null) return 'Inválido';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _servingUnit,
                    decoration: InputDecoration(
                      labelText: 'Unidade',
                      labelStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'g', child: Text('g')),
                      DropdownMenuItem(value: 'ml', child: Text('ml')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _servingUnit = val);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            AppTextField(
              controller: _caloriesController,
              label: 'Calorias (kcal) *',
              hint: 'Ex: 130',
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              validator: (val) {
                if (val == null || val.isEmpty) return 'Obrigatório';
                if (double.tryParse(val) == null) return 'Inválido';
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _proteinController,
                    label: 'Proteínas (g) *',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Obrigatório';
                      if (double.tryParse(val) == null) return 'Inválido';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppTextField(
                    controller: _carbsController,
                    label: 'Carboidratos (g) *',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Obrigatório';
                      if (double.tryParse(val) == null) return 'Inválido';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _fatController,
              label: 'Gorduras (g) *',
              hint: '0',
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _saveFood(),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Obrigatório';
                if (double.tryParse(val) == null) return 'Inválido';
                return null;
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: PrimaryButton(text: 'Salvar Alimento', onPressed: _saveFood),
        ),
      ),
    );
  }
}
