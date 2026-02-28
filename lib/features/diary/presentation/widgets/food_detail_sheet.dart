import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../shared/widgets/progress/macro_rings_row.dart';
import '../../domain/entities/food.dart';
import '../../domain/entities/food_item.dart';

class FoodDetailSheet extends StatefulWidget {
  final FoodItem foodItem;
  final ValueChanged<double> onAdd;

  const FoodDetailSheet({
    super.key,
    required this.foodItem,
    required this.onAdd,
  });

  @override
  State<FoodDetailSheet> createState() => _FoodDetailSheetState();
}

class _FoodDetailSheetState extends State<FoodDetailSheet> {
  late final Food _food;
  late final TextEditingController _amountController;
  double _amount = 0;

  static const Map<String, _QuickPortion> _portionPresets = {
    'local_pao_frances': _QuickPortion(50, '1 unidade'),
    'local_pao_integral': _QuickPortion(25, '1 fatia'),
    'local_pao_forma': _QuickPortion(25, '1 fatia'),
    'local_pao_forma_integral': _QuickPortion(25, '1 fatia'),
    'local_pao_hamburguer': _QuickPortion(60, '1 unidade'),
    'local_pao_hotdog': _QuickPortion(60, '1 unidade'),
    'local_pao_sirio': _QuickPortion(60, '1 unidade'),
    'local_pao_queijo': _QuickPortion(50, '1 unidade'),
    'local_pao_na_chapa': _QuickPortion(80, '1 unidade'),
    'local_pao_com_ovo': _QuickPortion(120, '1 unidade'),
    'local_pao_com_manteiga': _QuickPortion(70, '1 unidade'),
    'local_ovo_inteiro': _QuickPortion(50, '1 ovo'),
    'local_ovo_frito': _QuickPortion(50, '1 ovo'),
    'local_clara_ovo': _QuickPortion(33, '1 clara'),
    'local_gema_ovo': _QuickPortion(17, '1 gema'),
    'local_banana': _QuickPortion(100, '1 unidade'),
    'local_banana_nanica': _QuickPortion(100, '1 unidade'),
    'local_maca': _QuickPortion(150, '1 unidade'),
    'local_laranja': _QuickPortion(180, '1 unidade'),
    'local_pera': _QuickPortion(160, '1 unidade'),
    'local_iogurte_natural': _QuickPortion(170, '1 pote'),
    'local_iogurte_desnatado': _QuickPortion(170, '1 pote'),
    'local_iogurte_frutas': _QuickPortion(170, '1 pote'),
    'local_iogurte_grego': _QuickPortion(100, '1 pote'),
    'local_leite_integral': _QuickPortion(200, '1 copo'),
    'local_leite_desnatado': _QuickPortion(200, '1 copo'),
    'local_leite_semidesnatado': _QuickPortion(200, '1 copo'),
    'local_leite_zero_lactose': _QuickPortion(200, '1 copo'),
  };

  @override
  void initState() {
    super.initState();
    _food = widget.foodItem.toDomain();

    _amount = _food.servingSize;
    if (_amount <= 0) {
      final unit = _food.servingUnit.toLowerCase();
      _amount = (unit == 'g' || unit == 'ml') ? 100 : 1;
    }

    _amountController = TextEditingController(text: _formatAmount(_amount));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _step {
    final unit = _food.servingUnit.toLowerCase();
    if (unit == 'ml') return 50;
    if (unit == 'g') return 10;
    return 1;
  }

  String _formatAmount(double value) {
    if (value.truncateToDouble() == value) return value.toStringAsFixed(0);
    return value.toStringAsFixed(1);
  }

  void _setAmount(double value) {
    final normalized = value.isFinite && value > 0 ? value : 0.0;
    final formatted = _formatAmount(normalized);

    setState(() {
      _amount = normalized;
      _amountController.value = _amountController.value.copyWith(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
  }

  void _updateAmount(String value) {
    final parsed = double.tryParse(value.replaceAll(',', '.').trim());
    if (parsed == null) return;
    setState(() => _amount = parsed);
  }

  List<_QuickPortion> get _quickPortions {
    final unit = _food.servingUnit.toLowerCase();

    List<double> defaults;
    if (unit == 'ml') {
      defaults = <double>[100, 200, 300];
    } else if (unit == 'g') {
      defaults = <double>[50, 100, 150, 200];
    } else {
      defaults = <double>[0.5, 1, 1.5, 2];
    }
    final portions = <_QuickPortion>[];
    final preset = _portionPresets[widget.foodItem.id];

    if (preset != null) {
      portions.add(preset);
    }

    for (final value in defaults) {
      if (preset != null && (preset.amount - value).abs() < 0.1) continue;
      portions.add(_QuickPortion(value));
    }

    return portions;
  }

  String _portionLabel(_QuickPortion portion) {
    final valueLabel = '${_formatAmount(portion.amount)} ${_food.servingUnit}';
    final label = portion.label?.trim();
    if (label == null || label.isEmpty) {
      return valueLabel;
    }
    return '$label ($valueLabel)';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final multiplier = _food.servingSize > 0
        ? _amount / _food.servingSize
        : 1.0;

    final currentCalories = (_food.calories.value * multiplier).round();
    final currentCarbs = _food.macros.carbs * multiplier;
    final currentProtein = _food.macros.protein * multiplier;
    final currentFat = _food.macros.fat * multiplier;

    final contentPadding = EdgeInsets.fromLTRB(
      AppSpacing.lg,
      AppSpacing.sm,
      AppSpacing.lg,
      bottomInset + AppSpacing.lg,
    );

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: contentPadding,
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FoodAvatar(foodItem: widget.foodItem),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _food.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (widget.foodItem.brand != null &&
                            widget.foodItem.brand!.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.foodItem.brand!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        _KcalPill(kcal: currentCalories),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.textPrimary.withValues(alpha: 0.75),
                      ),
                    ),
                    tooltip: 'Fechar',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              MacroRingsRow(
                carbs: currentCarbs,
                protein: currentProtein,
                fat: currentFat,
              ),
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Porções rápidas',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _quickPortions.map((portion) {
                  final isSelected = (_amount - portion.amount).abs() < 0.1;
                  return ChoiceChip(
                    label: Text(_portionLabel(portion)),
                    selected: isSelected,
                    onSelected: (_) => _setAmount(portion.amount),
                    selectedColor: AppColors.primary.withValues(alpha: 0.16),
                    backgroundColor: AppColors.surfaceVariant,
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : AppColors.border,
                    ),
                    labelStyle: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              _AmountCard(
                unit: _food.servingUnit,
                controller: _amountController,
                onChanged: _updateAmount,
                onMinus: () => _setAmount((_amount - _step).clamp(0, 1000000)),
                onPlus: () => _setAmount(_amount + _step),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _amount > 0
                      ? () => widget.onAdd(multiplier)
                      : null,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Adicionar ao diário'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
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
}

class _QuickPortion {
  final double amount;
  final String? label;

  const _QuickPortion(this.amount, [this.label]);
}

class _FoodAvatar extends StatelessWidget {
  final FoodItem foodItem;

  const _FoodAvatar({required this.foodItem});

  @override
  Widget build(BuildContext context) {
    final url = foodItem.imageUrl;

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: url == null || url.trim().isEmpty
            ? Icon(
                Icons.restaurant_rounded,
                size: 34,
                color: AppColors.textPrimary.withValues(alpha: 0.35),
              )
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.restaurant_rounded,
                  size: 34,
                  color: AppColors.textPrimary.withValues(alpha: 0.35),
                ),
              ),
      ),
    );
  }
}

class _KcalPill extends StatelessWidget {
  final int kcal;

  const _KcalPill({required this.kcal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            size: 16,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 6),
          Text(
            '$kcal kcal',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountCard extends StatelessWidget {
  final String unit;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _AmountCard({
    required this.unit,
    required this.controller,
    required this.onChanged,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _StepButton(icon: Icons.remove_rounded, onPressed: onMinus),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              unit,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _StepButton(icon: Icons.add_rounded, onPressed: onPlus),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _StepButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        color: AppColors.textPrimary.withValues(alpha: 0.75),
        iconSize: 20,
        tooltip: icon == Icons.add_rounded ? 'Aumentar' : 'Diminuir',
      ),
    );
  }
}
