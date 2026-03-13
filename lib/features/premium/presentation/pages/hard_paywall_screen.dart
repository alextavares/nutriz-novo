import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../core/analytics/analytics_providers.dart';
import '../../../../core/analytics/paywall_analytics_tracker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/monetization/meal_log_gate.dart';
import '../../domain/entities/paywall_variant.dart';
import '../providers/paywall_variant_provider.dart';
import '../providers/subscription_provider.dart';

enum _HardPaywallPlan { annual, monthly }

extension on _HardPaywallPlan {
  String get planId => switch (this) {
    _HardPaywallPlan.annual => 'annual',
    _HardPaywallPlan.monthly => 'monthly',
  };

  String get label => switch (this) {
    _HardPaywallPlan.annual => 'anual',
    _HardPaywallPlan.monthly => 'mensal',
  };

  PackageType get packageType => switch (this) {
    _HardPaywallPlan.annual => PackageType.annual,
    _HardPaywallPlan.monthly => PackageType.monthly,
  };
}

class HardPaywallScreen extends ConsumerStatefulWidget {
  const HardPaywallScreen({super.key});

  @override
  ConsumerState<HardPaywallScreen> createState() => _HardPaywallScreenState();
}

class _HardPaywallScreenState extends ConsumerState<HardPaywallScreen> {
  bool _isLoading = false;
  bool _isRestoring = false;
  _HardPaywallPlan _selectedPlan = _HardPaywallPlan.annual;
  late final PaywallVariant _paywallVariant;
  late final PaywallAnalyticsTracker _tracker;

  @override
  void initState() {
    super.initState();
    _paywallVariant = ref.read(paywallVariantProvider);
    _tracker = PaywallAnalyticsTracker(
      paywallId: 'hard_paywall_screen',
      variant: _paywallVariant,
      source: 'hard_gate',
      logEvent: (name, props) {
        return ref.read(analyticsServiceProvider).logEvent(name, props);
      },
    );
    Future.microtask(_tracker.trackPaywallView);
  }

  RevenueCatPackageLookupResult _lookupForPlan(
    Offerings? offerings,
    _HardPaywallPlan plan,
  ) {
    return findPackageForPlanDetailed(offerings, plan.packageType);
  }

  String _priceLabel(Package? package, {required String fallback}) {
    final product = package?.storeProduct;
    if (product == null) return fallback;
    return product.priceString;
  }

  Future<void> _handleClose() async {
    await ref
        .read(mealLogGateProvider)
        .recordPaywallDismissed(
          paywallId: 'hard_paywall_screen',
          paywallVariant: _paywallVariant.analyticsValue,
          source: 'close_button',
        );
    if (!mounted) return;
    if (Navigator.of(context).canPop()) {
      context.pop();
      return;
    }
    context.go('/diary');
  }

  Future<void> _handleRestore() async {
    if (_isRestoring) return;
    setState(() => _isRestoring = true);
    try {
      await ref.read(subscriptionProvider.notifier).restorePurchases();
      await ref.read(subscriptionProvider.notifier).refresh();
      if (!mounted) return;
      final isPro = ref.read(subscriptionProvider).isPro;
      if (isPro) {
        context.go('/diary');
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma compra para restaurar.')),
      );
    } on StateError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message.toString())));
    } on PlatformException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao restaurar: ${e.message ?? 'tente novamente'}'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível restaurar compras.')),
      );
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  Future<void> _handlePurchase({
    required _HardPaywallPlan plan,
    required Package? package,
    required RevenueCatPackageLookupResult lookup,
    required Offerings? offerings,
    required String? offeringsError,
  }) async {
    final analytics = _tracker;
    unawaited(analytics.trackCtaTap(planId: plan.planId, plan: plan.label));

    if (package == null) {
      final reason = revenueCatSelectedPackageNullReason(
        offerings: offerings,
        lookup: lookup,
        offeringsError: offeringsError,
      );
      final technicalReason = revenueCatSelectedPackageNullTechnicalReason(
        offerings: offerings,
        lookup: lookup,
        offeringsError: offeringsError,
      );
      logRevenueCatRuntime(
        'selected_package_null screen=hard_paywall_screen plan=${plan.planId} '
        'reason=$reason details="$technicalReason"',
      );
      await analytics.trackPurchaseFailed(
        planId: plan.planId,
        plan: plan.label,
        productId: 'unavailable',
        reason: reason,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            revenueCatPackageNotFoundMessage(
              planLabel: plan.label,
              offeringsError: offeringsError,
              technicalReason: technicalReason,
            ),
          ),
        ),
      );
      ref.invalidate(revenueCatOfferingsProvider);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await analytics.trackPurchaseStart(
        planId: plan.planId,
        plan: plan.label,
        productId: package.storeProduct.identifier,
      );
      await ref.read(subscriptionProvider.notifier).purchasePackage(package);
      await ref.read(subscriptionProvider.notifier).refresh();
      await analytics.trackPurchaseComplete(
        planId: plan.planId,
        plan: plan.label,
        productId: package.storeProduct.identifier,
      );

      if (!mounted) return;

      final isPro = ref.read(subscriptionProvider).isPro;
      if (isPro) {
        context.go('/diary');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Assinatura não ativada. Tente novamente.'),
          ),
        );
      }
    } on StateError catch (e) {
      await analytics.trackPurchaseFailed(
        planId: plan.planId,
        plan: plan.label,
        reason: 'sdk_not_configured',
        productId: package.storeProduct.identifier,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message.toString())));
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      final reason = code == PurchasesErrorCode.purchaseCancelledError
          ? 'cancelled'
          : code.name;
      await analytics.trackPurchaseFailed(
        planId: plan.planId,
        plan: plan.label,
        reason: reason,
        productId: package.storeProduct.identifier,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            code == PurchasesErrorCode.purchaseCancelledError
                ? 'Compra cancelada.'
                : 'Erro: ${e.message}',
          ),
        ),
      );
    } catch (_) {
      await analytics.trackPurchaseFailed(
        planId: plan.planId,
        plan: plan.label,
        reason: 'unknown',
        productId: package.storeProduct.identifier,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao processar pagamento.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final offeringsAsync = ref.watch(revenueCatOfferingsProvider);
    final offeringsError = ref.watch(revenueCatOfferingsErrorProvider);
    final offerings = offeringsAsync.asData?.value;

    final annualLookup = _lookupForPlan(offerings, _HardPaywallPlan.annual);
    final monthlyLookup = _lookupForPlan(offerings, _HardPaywallPlan.monthly);
    final annualPackage = annualLookup.package;
    final monthlyPackage = monthlyLookup.package;

    final selectedPackage = _selectedPlan == _HardPaywallPlan.annual
        ? annualPackage
        : monthlyPackage;
    final selectedLookup = _selectedPlan == _HardPaywallPlan.annual
        ? annualLookup
        : monthlyLookup;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.sm,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Text(
                      'Premium',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _isRestoring ? null : _handleRestore,
                      child: _isRestoring
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Restaurar'),
                    ),
                    IconButton(
                      tooltip: 'Fechar',
                      onPressed: _handleClose,
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    120,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Continue sem complicação',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Desbloqueie mais praticidade para registrar refeições e acompanhar seu dia.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary.withValues(alpha: 0.10),
                              AppColors.premium.withValues(alpha: 0.18),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusXl,
                          ),
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.06),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.premium.withValues(
                                  alpha: 0.22,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: AppColors.premium,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mais consistência, menos esforço',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    'Use IA por foto, registros ilimitados e recursos avançados para manter o foco.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const _HardBenefitTile(
                        icon: Icons.camera_alt_rounded,
                        title: 'IA por foto',
                        subtitle:
                            'Tire uma foto da refeição e registre em segundos.',
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const _HardBenefitTile(
                        icon: Icons.lock_open_rounded,
                        title: 'Registros ilimitados',
                        subtitle: 'Acompanhe seu dia inteiro sem travas.',
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const _HardBenefitTile(
                        icon: Icons.insights_rounded,
                        title: 'Recursos avançados',
                        subtitle:
                            'Tenha mais apoio para seguir proteína, calorias e consistência.',
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _HardPlanTile(
                        title: 'Plano anual',
                        price: _priceLabel(annualPackage, fallback: '—'),
                        subtitle: '7 dias grátis • menos de R\$ 12,50 por mês',
                        badge: 'Melhor escolha',
                        isSelected: _selectedPlan == _HardPaywallPlan.annual,
                        onTap: () => setState(
                          () => _selectedPlan = _HardPaywallPlan.annual,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _HardPlanTile(
                        title: 'Plano mensal',
                        price: _priceLabel(monthlyPackage, fallback: '—'),
                        subtitle: 'Mais flexível para começar',
                        isSelected: _selectedPlan == _HardPaywallPlan.monthly,
                        onTap: () => setState(
                          () => _selectedPlan = _HardPaywallPlan.monthly,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
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
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
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
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: (_isLoading || _isRestoring)
                            ? null
                            : () => _handlePurchase(
                                plan: _selectedPlan,
                                package: selectedPackage,
                                lookup: selectedLookup,
                                offerings: offerings,
                                offeringsError: offeringsError,
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusLg,
                            ),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _selectedPlan == _HardPaywallPlan.annual
                                    ? 'Ativar 7 dias grátis'
                                    : 'Desbloquear Premium',
                              ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      TextButton(
                        onPressed: (_isLoading || _isRestoring)
                            ? null
                            : _handleClose,
                        child: const Text('Agora não'),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () => context.push('/legal/privacy'),
                            child: const Text('Privacidade'),
                          ),
                          const Text(' | '),
                          TextButton(
                            onPressed: () => context.push('/legal/terms'),
                            child: const Text('Termos'),
                          ),
                        ],
                      ),
                    ],
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

class _HardBenefitTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _HardBenefitTile({
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
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
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

class _HardPlanTile extends StatelessWidget {
  final String title;
  final String price;
  final String subtitle;
  final String? badge;
  final bool isSelected;
  final VoidCallback onTap;

  const _HardPlanTile({
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
