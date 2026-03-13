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
import '../../domain/entities/paywall_variant.dart';
import '../providers/paywall_variant_provider.dart';
import '../providers/subscription_provider.dart';

class OfferPaywallScreen extends ConsumerStatefulWidget {
  final VoidCallback? onClose;
  final VoidCallback? onSuccess;

  const OfferPaywallScreen({super.key, this.onClose, this.onSuccess});

  @override
  ConsumerState<OfferPaywallScreen> createState() => _OfferPaywallScreenState();
}

class _OfferPaywallScreenState extends ConsumerState<OfferPaywallScreen> {
  bool _isPurchasing = false;
  bool _isRestoring = false;
  late final PaywallVariant _paywallVariant;
  late final PaywallAnalyticsTracker _tracker;

  @override
  void initState() {
    super.initState();
    _paywallVariant = ref.read(paywallVariantProvider);
    _tracker = PaywallAnalyticsTracker(
      paywallId: 'offer_paywall_screen',
      variant: _paywallVariant,
      source: 'offer_contextual',
      logEvent: (name, props) {
        return ref.read(analyticsServiceProvider).logEvent(name, props);
      },
    );
    Future.microtask(_tracker.trackPaywallView);
  }

  Future<void> _handleClose() async {
    await _tracker.trackDismissed(source: 'close_button');
    if (!mounted) return;
    if (widget.onClose != null) {
      widget.onClose!();
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go('/diary');
    }
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
        if (widget.onSuccess != null) {
          widget.onSuccess!();
        } else {
          context.go('/diary');
        }
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
    required Package? pkg,
    required RevenueCatPackageLookupResult lookup,
    required Offerings? offerings,
    required String? offeringsError,
  }) async {
    final analytics = _tracker;
    unawaited(analytics.trackCtaTap(planId: 'annual', plan: 'anual'));

    if (pkg == null) {
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
        'selected_package_null screen=offer_paywall_screen plan=annual '
        'reason=$reason details="$technicalReason"',
      );
      await analytics.trackPurchaseFailed(
        planId: 'annual',
        plan: 'anual',
        productId: 'unavailable',
        reason: reason,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            revenueCatPackageNotFoundMessage(
              planLabel: 'anual',
              offeringsError: offeringsError,
              technicalReason: technicalReason,
            ),
          ),
        ),
      );
      ref.invalidate(revenueCatOfferingsProvider);
      return;
    }

    if (_isPurchasing) return;
    setState(() => _isPurchasing = true);
    try {
      await analytics.trackPurchaseStart(
        planId: 'annual',
        plan: 'anual',
        productId: pkg.storeProduct.identifier,
      );
      await ref.read(subscriptionProvider.notifier).purchasePackage(pkg);
      await ref.read(subscriptionProvider.notifier).refresh();
      await analytics.trackPurchaseComplete(
        planId: 'annual',
        plan: 'anual',
        productId: pkg.storeProduct.identifier,
      );
      if (!mounted) return;
      final isPro = ref.read(subscriptionProvider).isPro;
      if (isPro) {
        if (widget.onSuccess != null) {
          widget.onSuccess!();
        } else {
          context.go('/diary');
        }
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Assinatura não ativada. Tente novamente.'),
        ),
      );
    } on StateError catch (e) {
      await analytics.trackPurchaseFailed(
        planId: 'annual',
        plan: 'anual',
        reason: 'sdk_not_configured',
        productId: pkg.storeProduct.identifier,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message.toString())));
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        await analytics.trackPurchaseFailed(
          planId: 'annual',
          plan: 'anual',
          reason: 'cancelled',
          productId: pkg.storeProduct.identifier,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Compra cancelada.')));
        return;
      }
      await analytics.trackPurchaseFailed(
        planId: 'annual',
        plan: 'anual',
        reason: code.name,
        productId: pkg.storeProduct.identifier,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro na compra: ${code.name}')));
    } catch (_) {
      await analytics.trackPurchaseFailed(
        planId: 'annual',
        plan: 'anual',
        reason: 'unknown',
        productId: pkg.storeProduct.identifier,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao processar compra.')),
      );
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final offeringsAsync = ref.watch(revenueCatOfferingsProvider);
    final offerings = offeringsAsync.asData?.value;
    final offeringsError = ref.watch(revenueCatOfferingsErrorProvider);
    final annualLookup = findPackageForPlanDetailed(
      offerings,
      PackageType.annual,
    );
    final annualPackage = annualLookup.package;
    final price = annualPackage?.storeProduct.priceString ?? '—';

    return Scaffold(
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
                    'Oferta especial',
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
                      'Seu próximo passo, sem complicação',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Desbloqueie o Premium para continuar com mais praticidade e consistência.',
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
                              color: AppColors.premium.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.workspace_premium_rounded,
                              color: AppColors.premium,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Oferta contextual do anual',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Ative o plano anual e aproveite 7 dias grátis para continuar sem travas.',
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
                    const _OfferBenefitTile(
                      icon: Icons.camera_alt_rounded,
                      title: 'Registre por foto com IA',
                      subtitle:
                          'Mais rapidez para registrar refeições no dia a dia.',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const _OfferBenefitTile(
                      icon: Icons.lock_open_rounded,
                      title: 'Acompanhe seu dia sem limites',
                      subtitle:
                          'Continue registrando refeições sem travas no fluxo principal.',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const _OfferBenefitTile(
                      icon: Icons.insights_rounded,
                      title: 'Mais consistência com menos esforço',
                      subtitle:
                          'Tenha recursos avançados para seguir proteína, calorias e rotina.',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusXl,
                        ),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.35),
                        ),
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
                                      'Plano anual',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.premium.withValues(
                                          alpha: 0.18,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        'Melhor escolha',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  '7 dias grátis • menos de R\$ 12,50 por mês',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            price,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (annualPackage == null && offeringsError != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Planos indisponíveis no momento.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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
                      onPressed: (_isPurchasing || _isRestoring)
                          ? null
                          : () => _handlePurchase(
                              pkg: annualPackage,
                              lookup: annualLookup,
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
                      child: _isPurchasing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Ativar 7 dias grátis'),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextButton(
                      onPressed: (_isPurchasing || _isRestoring)
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
    );
  }
}

class _OfferBenefitTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OfferBenefitTile({
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
