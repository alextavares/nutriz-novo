import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/services.dart';
import 'package:nutriz/core/monetization/meal_log_gate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/analytics/paywall_analytics_tracker.dart';
import '../../../../core/analytics/analytics_providers.dart';
import '../../domain/entities/paywall_variant.dart';
import '../providers/paywall_variant_provider.dart';
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
  late final PaywallVariant _paywallVariant;
  late final PaywallAnalyticsTracker _tracker;
  int _stepIndex = 2;

  Future<void> _handleClose() async {
    final navigator = Navigator.of(context);
    final router = GoRouter.of(context);
    final isPro = ref.read(subscriptionProvider).isPro;
    if (!isPro) {
      await ref
          .read(mealLogGateProvider)
          .recordPaywallDismissed(
            paywallId: 'premium_screen',
            paywallVariant: _paywallVariant.analyticsValue,
            source: 'close_button',
          );
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
    _paywallVariant = ref.read(paywallVariantProvider);
    _selectedPlan = PremiumPlan.annual;
    _tracker = PaywallAnalyticsTracker(
      paywallId: 'premium_screen',
      variant: _paywallVariant,
      source: 'premium_tab_entry',
      logEvent: (name, props) {
        return ref.read(analyticsServiceProvider).logEvent(name, props);
      },
    );
    _pageController = PageController(initialPage: 2);
    Future.microtask(() {
      _tracker.trackPaywallView();
      _tracker.logEvent('paywall_step_view', _tracker.withBase({'step': 2}));
    });
  }

  RevenueCatPackageLookupResult _lookupForPlan(
    Offerings? offerings,
    PremiumPlan plan,
  ) {
    final wantedType = switch (plan) {
      PremiumPlan.annual => PackageType.annual,
      PremiumPlan.monthly => PackageType.monthly,
    };
    return findPackageForPlanDetailed(offerings, wantedType);
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
    final offeringsError = ref.watch(revenueCatOfferingsErrorProvider);
    final isOfferingsLoading = offeringsAsync.isLoading;

    final annualLookup = _lookupForPlan(offerings, PremiumPlan.annual);
    final monthlyLookup = _lookupForPlan(offerings, PremiumPlan.monthly);
    final annualPackage = annualLookup.package;
    final monthlyPackage = monthlyLookup.package;
    final plansUnavailable = annualPackage == null || monthlyPackage == null;
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
                    } on StateError catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.message.toString())),
                      );
                    } on PlatformException catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Não foi possível restaurar compras: ${e.message ?? 'tente novamente'}',
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
                _tracker.logEvent(
                  'paywall_step_view',
                  _tracker.withBase({'step': index}),
                ),
              );
            },
            children: [
              _PaywallStep(
                title: 'Emagreça sem complicação.',
                subtitle:
                    'Registre refeições mais rápido, acompanhe sua meta e mantenha consistência todos os dias.',
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeroCard(isPro: subscriptionStatus.isPro),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'O Premium reduz o atrito no seu dia e ajuda você a manter consistência com menos esforço.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const _InlineBullet(
                      icon: Icons.camera_alt_rounded,
                      title: 'IA por foto (Premium)',
                      subtitle:
                          'Analise refeições por imagem e confirme em segundos.',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const _InlineBullet(
                      icon: Icons.bolt_rounded,
                      title: 'Registros ilimitados',
                      subtitle: 'Acompanhe seu dia inteiro sem travas.',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const _InlineBullet(
                      icon: Icons.lock_open_rounded,
                      title: 'Recursos avançados',
                      subtitle:
                          'Tenha mais apoio para seguir calorias, proteína e consistência.',
                    ),
                  ],
                ),
              ),
              _PaywallStep(
                title: 'Grátis x Premium',
                subtitle:
                    'No grátis você começa. No Premium você continua com menos esforço.',
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusXl,
                        ),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Grátis',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'O essencial para começar.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const _InlineBullet(
                            icon: Icons.edit_rounded,
                            title: 'Registro manual',
                            subtitle: 'Diário, água, peso e metas básicas.',
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          const _InlineBullet(
                            icon: Icons.receipt_long_rounded,
                            title: 'Resumo diário básico',
                            subtitle:
                                'Veja calorias, proteína e progresso geral.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'No Premium você registra mais rápido e reduz a fricção para manter o foco.',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              _PaywallStep(
                title: 'Escolha seu plano',
                subtitle:
                    'Mais praticidade para registrar refeições e manter consistência.',
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
                    if (isOfferingsLoading) ...[
                      const _OfferingsStatusCard(
                        icon: Icons.sync_rounded,
                        title: 'Carregando planos',
                        message:
                            'Estamos buscando os precos e opcoes de assinatura.',
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ] else if (plansUnavailable) ...[
                      _OfferingsStatusCard(
                        icon: Icons.info_outline_rounded,
                        title: 'Planos indisponiveis agora',
                        message:
                            offeringsError ??
                            'Nao foi possivel carregar os planos de assinatura. Verifique a configuracao do RevenueCat e os produtos da loja.',
                        actionLabel: 'Tentar de novo',
                        onAction: () {
                          ref.invalidate(revenueCatOfferingsProvider);
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    _PlanTile(
                      title: 'Plano anual',
                      price: _priceLabel(annualPackage, fallback: '—'),
                      subtitle: '7 dias grátis • menos de R\$ 12,50 por mês',
                      badge: 'Melhor escolha',
                      isSelected: _selectedPlan == PremiumPlan.annual,
                      onTap: () =>
                          setState(() => _selectedPlan = PremiumPlan.annual),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _PlanTile(
                      title: 'Plano mensal',
                      price: _priceLabel(monthlyPackage, fallback: '—'),
                      subtitle: 'Mais flexível para começar',
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
                ? 'Desbloquear Premium'
                : 'Continuar',
            buttonLabel: subscriptionStatus.isPro
                ? 'OK'
                : isLastStep
                ? _selectedPlan == PremiumPlan.annual
                      ? 'Ativar 7 dias grátis'
                      : 'Desbloquear Premium'
                : 'Continuar',
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);

              if (subscriptionStatus.isPro) {
                await _handleClose();
                return;
              }

              if (!isLastStep) {
                unawaited(
                  _tracker.logEvent(
                    'paywall_next_tap',
                    _tracker.withBase({'step': _stepIndex}),
                  ),
                );
                _goToStep(_stepIndex + 1);
                return;
              }

              await _tracker.trackCtaTap(
                planId: _selectedPlan.planId,
                plan: _selectedPlan.label,
              );
              if (!mounted) return;

              final selectedPackage = _selectedPlan == PremiumPlan.annual
                  ? annualPackage
                  : monthlyPackage;
              final selectedLookup = _selectedPlan == PremiumPlan.annual
                  ? annualLookup
                  : monthlyLookup;

              if (selectedPackage == null) {
                final reason = revenueCatSelectedPackageNullReason(
                  offerings: offerings,
                  lookup: selectedLookup,
                  offeringsError: offeringsError,
                );
                final technicalReason =
                    revenueCatSelectedPackageNullTechnicalReason(
                      offerings: offerings,
                      lookup: selectedLookup,
                      offeringsError: offeringsError,
                    );
                logRevenueCatRuntime(
                  'selected_package_null screen=premium_screen plan=${_selectedPlan.planId} '
                  'reason=$reason details="$technicalReason"',
                );
                await _tracker.trackPurchaseFailed(
                  planId: _selectedPlan.planId,
                  plan: _selectedPlan.label,
                  productId: 'unavailable',
                  reason: reason,
                );
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      revenueCatPackageNotFoundMessage(
                        planLabel: _selectedPlan.label,
                        offeringsError: offeringsError,
                        technicalReason: technicalReason,
                      ),
                    ),
                  ),
                );
                ref.invalidate(revenueCatOfferingsProvider);
                return;
              }

              try {
                await _tracker.trackPurchaseStart(
                  planId: _selectedPlan.planId,
                  plan: _selectedPlan.label,
                  productId: selectedPackage.storeProduct.identifier,
                );

                await ref
                    .read(subscriptionProvider.notifier)
                    .purchasePackage(selectedPackage);
                await ref.read(subscriptionProvider.notifier).refresh();

                await _tracker.trackPurchaseComplete(
                  planId: _selectedPlan.planId,
                  plan: _selectedPlan.label,
                  productId: selectedPackage.storeProduct.identifier,
                );

                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(content: Text('Premium ativado. Obrigado!')),
                );
              } on PlatformException catch (e) {
                final code = PurchasesErrorHelper.getErrorCode(e);
                if (code == PurchasesErrorCode.purchaseCancelledError) {
                  await _tracker.trackPurchaseFailed(
                    planId: _selectedPlan.planId,
                    plan: _selectedPlan.label,
                    productId: selectedPackage.storeProduct.identifier,
                    reason: 'cancelled',
                  );
                  if (!mounted) return;
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Compra cancelada.')),
                  );
                  return;
                }

                await _tracker.trackPurchaseFailed(
                  planId: _selectedPlan.planId,
                  plan: _selectedPlan.label,
                  productId: selectedPackage.storeProduct.identifier,
                  reason: code.name,
                );
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(content: Text('Erro na compra: ${code.name}')),
                );
              } on StateError catch (e) {
                await _tracker.trackPurchaseFailed(
                  planId: _selectedPlan.planId,
                  plan: _selectedPlan.label,
                  productId: selectedPackage.storeProduct.identifier,
                  reason: 'sdk_not_configured',
                );
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(content: Text(e.message.toString())),
                );
              } catch (_) {
                await _tracker.trackPurchaseFailed(
                  planId: _selectedPlan.planId,
                  plan: _selectedPlan.label,
                  productId: selectedPackage.storeProduct.identifier,
                  reason: 'unknown',
                );
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
    PremiumPlan.annual => 'anual',
    PremiumPlan.monthly => 'mensal',
  };

  String get planId => switch (this) {
    PremiumPlan.annual => 'annual',
    PremiumPlan.monthly => 'monthly',
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
                  isPro ? 'Premium ativo' : 'Menos atrito no seu dia',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  isPro
                      ? 'Aproveite todos os recursos sem limitações.'
                      : 'Registre mais rápido, acompanhe sua meta e mantenha consistência.',
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
      (
        Icons.camera_alt_rounded,
        'IA por foto para registrar refeições em segundos',
      ),
      (
        Icons.lock_open_rounded,
        'Registros ilimitados para acompanhar o dia inteiro',
      ),
      (
        Icons.analytics_rounded,
        'Recursos avançados para seguir proteína e calorias',
      ),
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
            children: [
              const Icon(
                Icons.shield_rounded,
                size: 18,
                color: AppColors.premium,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Assinatura transparente',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Cancele quando quiser pela App Store ou Google Play.',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Pagamento seguro. Restaurar compra disponível a qualquer momento.',
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
                  backgroundColor: isPro
                      ? AppColors.success
                      : AppColors.primary,
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

class _OfferingsStatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _OfferingsStatusCard({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
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
