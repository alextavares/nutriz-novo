import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PremiumLockOverlay extends StatelessWidget {
  final VoidCallback? onTap;

  const PremiumLockOverlay({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.white.withValues(alpha: 0.7),
        child: InkWell(
          onTap: onTap,
          child: const Center(
            child: Icon(Icons.lock, color: AppColors.premium, size: 32),
          ),
        ),
      ),
    );
  }
}
