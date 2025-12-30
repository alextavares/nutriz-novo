import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class QuickWeightLogCard extends StatefulWidget {
  final double currentWeight;
  final double startWeight;
  final double goalWeight;
  final Function(double) onWeightChanged;
  final VoidCallback? onTapMore; // Add this parameter

  const QuickWeightLogCard({
    super.key,
    required this.currentWeight,
    required this.startWeight,
    required this.goalWeight,
    required this.onWeightChanged,
    this.onTapMore, // Add this
  });

  @override
  State<QuickWeightLogCard> createState() => _QuickWeightLogCardState();
}

class _QuickWeightLogCardState extends State<QuickWeightLogCard> {
  late double _tempWeight;

  @override
  void initState() {
    super.initState();
    _tempWeight = widget.currentWeight;
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        ((widget.startWeight - _tempWeight) /
                (widget.startWeight - widget.goalWeight))
            .clamp(0.0, 1.0);

    final weightDiff = _tempWeight - widget.currentWeight;
    final hasChanged =
        weightDiff.abs() > 0.05; // Changed if difference > 0.05kg

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: hasChanged
            ? Border.all(
                color: AppColors.primary.withValues(alpha: 0.22),
                width: 1.5,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            GestureDetector(
              onTap: widget.onTapMore,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.monitor_weight_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Peso',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  const Spacer(),
                  if (widget.onTapMore != null)
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textHint,
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Current Weight Display
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Atual',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                // Minus Button
                _AdjustButton(
                  icon: Icons.remove_rounded,
                  onTap: () {
                    setState(() {
                      _tempWeight = (_tempWeight - 0.1).clamp(0.0, 300.0);
                    });
                  },
                ),
                const SizedBox(width: 16),
                // Weight Display
                Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _tempWeight.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            'kg',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (weightDiff != 0) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            weightDiff > 0
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            size: 12,
                            color: weightDiff > 0 ? Colors.red : Colors.green,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${weightDiff.abs().toStringAsFixed(1)} kg',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: weightDiff > 0 ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                const SizedBox(width: 16),
                // Plus Button
                _AdjustButton(
                  icon: Icons.add_rounded,
                  onTap: () {
                    setState(() {
                      _tempWeight = (_tempWeight + 0.1).clamp(0.0, 300.0);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.surfaceVariant,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 8),

            // Start and Goal Labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _WeightLabel(label: 'Inicial', value: widget.startWeight),
                _WeightLabel(label: 'Meta', value: widget.goalWeight),
              ],
            ),
            const SizedBox(height: 16),

            // Save Button
            if (weightDiff != 0)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onWeightChanged(_tempWeight);
                    setState(() {
                      // Reset after save
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Salvar peso',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
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

class _AdjustButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _AdjustButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, size: 20, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _WeightLabel extends StatelessWidget {
  final String label;
  final double value;

  const _WeightLabel({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey[500],
          ),
        ),
        Text(
          '${value.toStringAsFixed(1)} kg',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
