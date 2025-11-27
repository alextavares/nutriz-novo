import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class MacroBars extends StatelessWidget {
  final double carbs;
  final double protein;
  final double fat;
  final double carbsGoal;
  final double proteinGoal;
  final double fatGoal;

  const MacroBars({
    super.key,
    required this.carbs,
    required this.protein,
    required this.fat,
    this.carbsGoal = 210,
    this.proteinGoal = 140,
    this.fatGoal = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMacroItem('Carbs', carbs, carbsGoal, AppColors.carbs),
        _buildMacroItem('Protein', protein, proteinGoal, AppColors.protein),
        _buildMacroItem('Fat', fat, fatGoal, AppColors.fat),
      ],
    );
  }

  Widget _buildMacroItem(String label, double value, double goal, Color color) {
    final progress = (value / goal).clamp(0.0, 1.0);
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          width: 80,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${value.toInt()} / ${goal.toInt()} g',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}
