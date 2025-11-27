import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/subscription_status.dart';
import '../providers/subscription_provider.dart';

class PremiumFeatureWrapper extends ConsumerWidget {
  final Widget child;
  final String featureName;
  final String? customMessage;

  const PremiumFeatureWrapper({
    super.key,
    required this.child,
    required this.featureName,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionStatus = ref.watch(subscriptionProvider);

    if (subscriptionStatus.isPro) {
      return child;
    }

    return Stack(
      children: [
        Opacity(opacity: 0.3, child: IgnorePointer(child: child)),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // TODO: Navegar para tela de Paywall
                // context.push('/paywall');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Feature "$featureName" disponível apenas no PRO!',
                    ),
                  ),
                );
              },
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock, size: 48, color: Colors.amber),
                    const SizedBox(height: 8),
                    Text(
                      customMessage ?? 'Disponível apenas no PRO',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87, // Ajustar conforme tema
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Navegar para tela de Paywall
                        // context.push('/paywall');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Feature "$featureName" disponível apenas no PRO!',
                            ),
                          ),
                        );
                      },
                      child: const Text('Ver Planos'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
