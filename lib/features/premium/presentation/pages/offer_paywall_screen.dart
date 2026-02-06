import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../core/analytics/analytics_providers.dart';
import '../../../../core/monetization/promo_offer.dart';
import '../providers/subscription_provider.dart';

String _formatCountdown(Duration duration) {
  final totalSeconds = duration.inSeconds.clamp(0, 24 * 60 * 60);
  final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

class OfferPaywallScreen extends ConsumerStatefulWidget {
  const OfferPaywallScreen({super.key});

  @override
  ConsumerState<OfferPaywallScreen> createState() => _OfferPaywallScreenState();
}

class _OfferPaywallScreenState extends ConsumerState<OfferPaywallScreen> {
  bool _isPurchasing = false;
  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(analyticsServiceProvider).logEvent('paywall_view', {
        'paywall_id': 'offer_paywall_screen',
      });
    });
    ref
        .read(promoOfferProvider.notifier)
        .ensureActive(
          duration: const Duration(minutes: 10),
          discountPercent: 75,
          source: 'offer_paywall_view',
        );
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

  Future<void> _handlePurchase(Package? pkg) async {
    final analytics = ref.read(analyticsServiceProvider);
    unawaited(
      analytics.logEvent('paywall_cta_tap', {
        'paywall_id': 'offer_paywall_screen',
        'plan_id': 'annual',
        'plan': 'anual',
      }),
    );

    if (pkg == null) {
      await analytics.logEvent('purchase_failed', {
        'paywall_id': 'offer_paywall_screen',
        'plan_id': 'annual',
        'plan': 'anual',
        'product_id': 'unavailable',
        'reason': 'package_not_found',
      });
      final offeringsError = ref.read(revenueCatOfferingsErrorProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            revenueCatPackageNotFoundMessage(
              planLabel: 'anual',
              offeringsError: offeringsError,
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
      await analytics.logEvent('purchase_start', {
        'paywall_id': 'offer_paywall_screen',
        'plan_id': 'annual',
        'plan': 'anual',
        'product_id': pkg.storeProduct.identifier,
      });
      await ref.read(subscriptionProvider.notifier).purchasePackage(pkg);
      await ref.read(subscriptionProvider.notifier).refresh();
      await analytics.logEvent('purchase_complete', {
        'paywall_id': 'offer_paywall_screen',
        'plan_id': 'annual',
        'plan': 'anual',
        'product_id': pkg.storeProduct.identifier,
      });
      if (!mounted) return;
      final isPro = ref.read(subscriptionProvider).isPro;
      if (isPro) {
        context.go('/diary');
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Assinatura não ativada. Tente novamente.'),
        ),
      );
    } on StateError catch (e) {
      await analytics.logEvent('purchase_failed', {
        'paywall_id': 'offer_paywall_screen',
        'plan_id': 'annual',
        'plan': 'anual',
        'reason': 'sdk_not_configured',
        'product_id': pkg.storeProduct.identifier,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message.toString())));
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        await analytics.logEvent('purchase_failed', {
          'paywall_id': 'offer_paywall_screen',
          'plan_id': 'annual',
          'plan': 'anual',
          'reason': 'cancelled',
          'product_id': pkg.storeProduct.identifier,
        });
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Compra cancelada.')));
        return;
      }
      await analytics.logEvent('purchase_failed', {
        'paywall_id': 'offer_paywall_screen',
        'plan_id': 'annual',
        'plan': 'anual',
        'reason': code.name,
        'product_id': pkg.storeProduct.identifier,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro na compra: ${code.name}')));
    } catch (_) {
      await analytics.logEvent('purchase_failed', {
        'paywall_id': 'offer_paywall_screen',
        'plan_id': 'annual',
        'plan': 'anual',
        'reason': 'unknown',
        'product_id': pkg.storeProduct.identifier,
      });
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
    final annualPackage = findPackageForPlan(offerings, PackageType.annual);
    final price = annualPackage?.storeProduct.priceString ?? '—';

    final offer = ref.watch(promoOfferProvider);
    final discount = offer.discountPercent > 0 ? offer.discountPercent : 75;

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
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.schedule,
                        size: 64,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Ano Novo, Vida Nova',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      '$discount% de desconto!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w900,
                        fontSize: 40,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      price,
                      style: GoogleFonts.inter(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w900,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'no seu primeiro ano',
                      style: GoogleFonts.inter(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 26),
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
                        'Erro ao carregar planos: $offeringsError',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Consumer(
                      builder: (context, ref, _) {
                        final now =
                            ref.watch(promoOfferTickerProvider).asData?.value ??
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
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_isPurchasing || _isRestoring)
                          ? null
                          : () => _handlePurchase(annualPackage),
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
