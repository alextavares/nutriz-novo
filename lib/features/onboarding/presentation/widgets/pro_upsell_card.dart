import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Tela de upselling PRO no final do onboarding
class ProUpsellCard extends StatelessWidget {
  final VoidCallback onContinueFree;
  final VoidCallback onTryPro;

  const ProUpsellCard({
    super.key,
    required this.onContinueFree,
    required this.onTryPro,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          // PRO Badge
          Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade600, Colors.orange.shade700],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'NUTRIZ PRO',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.8, 0.8), duration: 400.ms),
          const SizedBox(height: 24),
          // Title
          Text(
            'Desbloqueie todo o potencial',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 8),
          Text(
            'Alcance seus objetivos mais rápido',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 32),
          // Features list
          ..._buildFeatures(context),
          const SizedBox(height: 32),
          // CTA Button
          SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTryPro,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star),
                      SizedBox(width: 8),
                      Text(
                        'Experimentar PRO Grátis',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .animate(delay: 800.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2, duration: 400.ms),
          const SizedBox(height: 12),
          Text(
            '7 dias grátis, cancele quando quiser',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          // Continue free button
          TextButton(
            onPressed: onContinueFree,
            child: Text(
              'Continuar com versão gratuita',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  List<Widget> _buildFeatures(BuildContext context) {
    final features = [
      (Icons.restaurant_menu, 'Planos de refeição personalizados'),
      (Icons.qr_code_scanner, 'Scanner de código de barras'),
      (Icons.camera_alt, 'Reconhecimento de alimentos por IA'),
      (Icons.analytics, 'Estatísticas avançadas'),
      (Icons.block, 'Sem anúncios'),
      (Icons.sync, 'Sincronização com wearables'),
    ];

    return features.asMap().entries.map((entry) {
      final index = entry.key;
      final (icon, text) = entry.value;

      return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _FeatureRow(icon: icon, text: text),
          )
          .animate(delay: Duration(milliseconds: 400 + (index * 100)))
          .fadeIn(duration: 300.ms)
          .slideX(begin: -0.1, duration: 300.ms);
    }).toList();
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.amber.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.amber.shade700, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Icon(Icons.check_circle, color: Colors.green.shade400, size: 24),
      ],
    );
  }
}
