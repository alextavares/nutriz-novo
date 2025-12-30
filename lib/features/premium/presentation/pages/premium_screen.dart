import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/services.dart';
import 'package:nutriz/core/monetization/meal_log_gate.dart';
import 'package:nutriz/features/profile/presentation/notifiers/profile_notifier.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/analytics/analytics_providers.dart';
import '../providers/subscription_provider.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  PremiumPlan _selectedPlan = PremiumPlan.annual;
  bool _isRestoring = false;
  late final PageController _pageController;
  int _stepIndex = 0;

  Future<void> _handleClose() async {
    final navigator = Navigator.of(context);
    final router = GoRouter.of(context);
    final isPro = ref.read(subscriptionProvider).isPro;
    if (!isPro) {
      await ref.read(mealLogGateProvider).recordPaywallDismissed();
      if (!mounted) return;

      final profile = ref.read(profileNotifierProvider);
      final now = DateTime.now();
      final shouldOfferChallenge =
          profile.freeMealsRemaining == 0 &&
          profile.challengeMealsRemaining == 0 &&
          ref.read(mealLogGateProvider).peekBlockReason(profile, now) ==
              MealLogBlockReason.locked;

      if (shouldOfferChallenge) {
        final joinChallenge = await showDialog<bool>(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: const Text('Topa um desafio de 3 dias?'),
              content: const Text(
                'Registre 1 refeição por dia e foque na proteína. '
                'No dia 3, a gente te mostra uma oferta para desbloquear a IA por foto.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Agora não'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Começar'),
                ),
              ],
            );
          },
        );

        if (joinChallenge == true) {
          await ref.read(mealLogGateProvider).start3DayChallenge();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Desafio iniciado: 3 dias.')),
          );
        }
      }
    }

    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    router.go('/diary');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int index) {
    if (index < 0 || index > 2) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    Future.microtask(() {
      final analytics = ref.read(analyticsServiceProvider);
      analytics.logEvent('paywall_view', {'paywall_id': 'premium_screen'});
      analytics.logEvent('paywall_step_view', {
        'paywall_id': 'premium_screen',
        'step': 0,
      });
    });
  }

  Package? _packageForPlan(Offerings? offerings, PremiumPlan plan) {
    final current = offerings?.current;
    if (current == null) return null;

    final packages = current.availablePackages;
    final wantedType = switch (plan) {
      PremiumPlan.annual => PackageType.annual,
      PremiumPlan.monthly => PackageType.monthly,
    };

    for (final p in packages) {
      if (p.packageType == wantedType) return p;
    }
    return null;
  }

  String _priceLabel(Package? package, {required String fallback}) {
    final product = package?.storeProduct;
    if (product == null) return fallback;
    return product.priceString;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subscriptionStatus = ref.watch(subscriptionProvider);
    final offeringsAsync = ref.watch(revenueCatOfferingsProvider);
    final offerings = offeringsAsync.asData?.value;

    final annualPackage = _packageForPlan(offerings, PremiumPlan.annual);
    final monthlyPackage = _packageForPlan(offerings, PremiumPlan.monthly);
    final isLastStep = _stepIndex == 2;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _handleClose,
          tooltip: 'Fechar',
        ),
        title: const Text('Premium'),
        actions: [
          TextButton(
            onPressed: _isRestoring
                ? null
                : () async {
                    setState(() => _isRestoring = true);
                    try {
                      await ref
                          .read(subscriptionProvider.notifier)
                          .restorePurchases();
                      await ref.read(subscriptionProvider.notifier).refresh();
                      if (!context.mounted) return;
                      final isPro = ref.read(subscriptionProvider).isPro;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isPro
                                ? 'Compras restauradas. Premium ativo.'
                                : 'Compras restauradas. Nenhuma assinatura ativa encontrada.',
                          ),
                        ),
                      );
                    } catch (_) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Não foi possível restaurar compras.'),
                        ),
                      );
                    } finally {
                      if (mounted) setState(() => _isRestoring = false);
                    }
                  },
            child: _isRestoring
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Restaurar'),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() => _stepIndex = index);
              unawaited(
                ref.read(analyticsServiceProvider).logEvent('paywall_step_view', {
                  'paywall_id': 'premium_screen',
                  'step': index,
                }),
              );
            },
            children: [
              _PaywallStep(
                title: 'Comece com clareza',
                subtitle: 'Menos esforço. Mais consistência.',
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeroCard(isPro: subscriptionStatus.isPro),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'O Premium é feito para te dar um “próximo passo” fácil todos os dias.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const _InlineBullet(
                      icon: Icons.camera_alt_rounded,
                      title: 'IA por foto (Premium)',
                      subtitle: 'Analise refeições por imagem e confirme em segundos.',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const _InlineBullet(
                      icon: Icons.bolt_rounded,
                      title: 'Ajuste automático do dia',
                      subtitle: 'Foco em proteína e metas — sem complicar.',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const _InlineBullet(
                      icon: Icons.lock_open_rounded,
                      title: 'Sem limites para registrar refeições',
                      subtitle: 'Registre quantas refeições quiser.',
                    ),
                  ],
                ),
              ),
              _PaywallStep(
                title: 'Sem pegadinhas',
                subtitle: 'Teste grátis e controle total.',
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Teste grátis (quando disponível)',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Você pode cancelar quando quiser.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const _InlineBullet(
                            icon: Icons.notifications_active_rounded,
                            title: 'Sem surpresa',
                            subtitle:
                                'Na hora de assinar, a loja mostra a data de renovação e você pode cancelar quando quiser.',
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          const _InlineBullet(
                            icon: Icons.receipt_long_rounded,
                            title: 'Transparência',
                            subtitle:
                                'Os preços e a cobrança são processados pela loja (Google/Apple).',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Pronto para destravar a IA por foto?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              _PaywallStep(
                title: 'Escolha seu plano',
                subtitle: 'Desbloqueie tudo e siga no automático.',
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeroCard(isPro: subscriptionStatus.isPro),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'O que você desbloqueia',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const _BenefitsList(),
                    const SizedBox(height: AppSpacing.lg),
                    _PlanTile(
                      title: '12 meses',
                      price: _priceLabel(annualPackage, fallback: '—'),
                      subtitle: 'Mais popular • melhor custo',
                      badge: 'Mais popular',
                      isSelected: _selectedPlan == PremiumPlan.annual,
                      onTap: () =>
                          setState(() => _selectedPlan = PremiumPlan.annual),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _PlanTile(
                      title: '1 mês',
                      price: _priceLabel(monthlyPackage, fallback: '—'),
                      subtitle: 'Para começar agora',
                      isSelected: _selectedPlan == PremiumPlan.monthly,
                      onTap: () =>
                          setState(() => _selectedPlan = PremiumPlan.monthly),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _SocialProofCard(),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Cancele quando quiser. Sem compromisso.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Ao continuar, você concorda com os Termos e Política de Privacidade.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          _BottomCtaBar(
            isPro: subscriptionStatus.isPro,
            title: subscriptionStatus.isPro
                ? 'Premium ativo'
                : isLastStep
                ? 'Desbloquear IA por foto'
                : 'Continuar',
            buttonLabel: subscriptionStatus.isPro
                ? 'OK'
                : isLastStep
                ? 'Ativar teste grátis'
                : 'Continuar',
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);

              if (subscriptionStatus.isPro) {
                await _handleClose();
                return;
              }

              if (!isLastStep) {
                unawaited(
                  ref.read(analyticsServiceProvider).logEvent('paywall_next_tap', {
                    'paywall_id': 'premium_screen',
                    'step': _stepIndex,
                  }),
                );
                _goToStep(_stepIndex + 1);
                return;
              }

              final analytics = ref.read(analyticsServiceProvider);
              await analytics.logEvent('paywall_cta_tap', {
                'paywall_id': 'premium_screen',
                'plan': _selectedPlan.label,
              });
              if (!mounted) return;

              final selectedPackage = _selectedPlan == PremiumPlan.annual
                  ? annualPackage
                  : monthlyPackage;

              if (selectedPackage == null) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'Plano indisponível. Configure Offering/Packages no RevenueCat (${_selectedPlan.label}).',
                    ),
                  ),
                );
                return;
              }

              try {
                await analytics.logEvent('purchase_start', {
                  'paywall_id': 'premium_screen',
                  'plan': _selectedPlan.label,
                  'product_id': selectedPackage.storeProduct.identifier,
                });

                await ref
                    .read(subscriptionProvider.notifier)
                    .purchasePackage(selectedPackage);
                await ref.read(subscriptionProvider.notifier).refresh();

                await analytics.logEvent('purchase_complete', {
                  'paywall_id': 'premium_screen',
                  'plan': _selectedPlan.label,
                  'product_id': selectedPackage.storeProduct.identifier,
                });

                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(content: Text('Premium ativado. Obrigado!')),
                );
              } on PlatformException catch (e) {
                final code = PurchasesErrorHelper.getErrorCode(e);
                if (code == PurchasesErrorCode.purchaseCancelledError) {
                  await analytics.logEvent('purchase_failed', {
                    'reason': 'cancelled',
                    'paywall_id': 'premium_screen',
                    'plan': _selectedPlan.label,
                  });
                  if (!mounted) return;
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Compra cancelada.')),
                  );
                  return;
                }

                await analytics.logEvent('purchase_failed', {
                  'reason': code.name,
                  'paywall_id': 'premium_screen',
                  'plan': _selectedPlan.label,
                });
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(content: Text('Erro na compra: ${code.name}')),
                );
              } catch (_) {
                await analytics.logEvent('purchase_failed', {
                  'reason': 'unknown',
                  'paywall_id': 'premium_screen',
                  'plan': _selectedPlan.label,
                });
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(content: Text('Erro ao processar compra.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

enum PremiumPlan { annual, monthly }

extension PremiumPlanX on PremiumPlan {
  String get label => switch (this) {
        PremiumPlan.annual => '12 meses',
        PremiumPlan.monthly => '1 mês',
      };
}

class _HeroCard extends StatelessWidget {
  final bool isPro;

  const _HeroCard({required this.isPro});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            AppColors.premium.withValues(alpha: 0.18),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.premium.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.star_rounded, color: AppColors.premium),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPro ? 'Premium ativo' : 'Desbloqueie o Premium',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  isPro
                      ? 'Aproveite todos os recursos sem limitações.'
                      : 'Mais consistência e resultados com recursos avançados.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
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

class _BenefitsList extends StatelessWidget {
  const _BenefitsList();

  @override
  Widget build(BuildContext context) {
    const benefits = [
      (Icons.analytics_rounded, 'Estatísticas avançadas'),
      (Icons.camera_alt_rounded, 'Reconhecimento por IA'),
      (Icons.qr_code_scanner_rounded, 'Scanner de código de barras'),
      (Icons.block_rounded, 'Sem anúncios'),
      (Icons.sync_rounded, 'Sincronização com wearables'),
    ];

    return Column(
      children: benefits
          .map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _BenefitRow(icon: b.$1, text: b.$2),
            ),
          )
          .toList(),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: AppColors.success),
        ],
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  final String title;
  final String price;
  final String subtitle;
  final String? badge;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanTile({
    required this.title,
    required this.price,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = isSelected ? AppColors.primary : Colors.black12;
    final background = isSelected
        ? AppColors.primary.withValues(alpha: 0.08)
        : AppColors.surface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(color: borderColor.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.premium.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            badge!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? AppColors.primary : AppColors.textHint,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialProofCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              5,
              (index) => const Icon(
                Icons.star_rounded,
                size: 18,
                color: AppColors.premium,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '“Muito mais fácil manter consistência com o resumo e metas.”',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '— Avaliação verificada',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomCtaBar extends StatelessWidget {
  final bool isPro;
  final String title;
  final String buttonLabel;
  final VoidCallback onPressed;

  const _BottomCtaBar({
    required this.isPro,
    required this.title,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        minimum: const EdgeInsets.all(AppSpacing.md),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPro ? AppColors.success : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                ),
                child: Text(buttonLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaywallStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget body;

  const _PaywallStep({
    required this.title,
    required this.subtitle,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        120,
      ),
      children: [
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        body,
      ],
    );
  }
}

class _InlineBullet extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InlineBullet({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
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
