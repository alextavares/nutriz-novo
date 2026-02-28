import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../core/analytics/analytics_providers.dart';
import '../../../../core/analytics/paywall_analytics_tracker.dart';
import '../../../../core/monetization/promo_offer.dart';
import '../../domain/entities/paywall_variant.dart';
import '../providers/paywall_variant_provider.dart';
import '../providers/subscription_provider.dart';

String _formatCountdown(Duration duration) {
  final totalSeconds = duration.inSeconds.clamp(0, 24 * 60 * 60);
  final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

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
      logEvent: (name, props) {
        return ref.read(analyticsServiceProvider).logEvent(name, props);
      },
    );
    Future.microtask(() {
      _tracker.trackPaywallView();
    });
    ref
        .read(promoOfferProvider.notifier)
        .ensureActive(
          duration: const Duration(minutes: 10),
          discountPercent: 75,
          source: 'offer_paywall_view',
        );
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Spacer(),
                  Text(
                    'Assine o PRO',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Fechar',
                    onPressed: _handleClose,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.schedule,
                          size: 36,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Pare de Digitar Calorias',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Desbloqueie o Escaneamento Infinito por IA. Reconhecimento instantâneo para qualquer prato.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w900,
                          fontSize: 26,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        price,
                        style: GoogleFonts.inter(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w900,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'COMEÇAR MINHA DIETA FÁCIL',
                        style: GoogleFonts.inter(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Corra! A oferta termina em',
                        style: GoogleFonts.inter(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      if (annualPackage == null && offeringsError != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          'Planos indisponíveis no momento.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Consumer(
                        builder: (context, ref, _) {
                          final now =
                              ref
                                  .watch(promoOfferTickerProvider)
                                  .asData
                                  ?.value ??
                              DateTime.now();
                          final remaining = ref
                              .watch(promoOfferProvider)
                              .remaining(now);
                          return Text(
                            _formatCountdown(remaining),
                            style: GoogleFonts.robotoMono(
                              fontWeight: FontWeight.w800,
                              fontSize: 44,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_isPurchasing || _isRestoring)
                          ? null
                          : () => _handlePurchase(
                              pkg: annualPackage,
                              lookup: annualLookup,
                              offerings: offerings,
                              offeringsError: offeringsError,
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isPurchasing
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'APROVEITAR AGORA',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                letterSpacing: 0.4,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
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
                      const Text(' | '),
                      TextButton(
                        onPressed: (_isPurchasing || _isRestoring)
                            ? null
                            : _handleRestore,
                        child: _isRestoring
                            ? const SizedBox(
                                height: 14,
                                width: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Restaurar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
