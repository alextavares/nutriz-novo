import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../core/analytics/analytics_providers.dart';
import '../../../../core/analytics/paywall_analytics_tracker.dart';
import '../../../../core/monetization/meal_log_gate.dart';
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

class HardPaywallScreen extends ConsumerStatefulWidget {
  const HardPaywallScreen({super.key});

  @override
  ConsumerState<HardPaywallScreen> createState() => _HardPaywallScreenState();
}

class _HardPaywallScreenState extends ConsumerState<HardPaywallScreen> {
  bool _isLoading = false;
  bool _isRestoring = false;
  late final PaywallVariant _paywallVariant;
  late final PaywallAnalyticsTracker _tracker;

  @override
  void initState() {
    super.initState();
    _paywallVariant = ref.read(paywallVariantProvider);
    _tracker = PaywallAnalyticsTracker(
      paywallId: 'hard_paywall_screen',
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
          source: 'hard_paywall_view',
        );
  }

  Future<void> _handleClose() async {
    await ref
        .read(mealLogGateProvider)
        .recordPaywallDismissed(
          paywallId: 'hard_paywall_screen',
          paywallVariant: _paywallVariant.analyticsValue,
          source: 'close_button',
        );
    ref
        .read(promoOfferProvider.notifier)
        .ensureActive(
          duration: const Duration(minutes: 10),
          discountPercent: 75,
          source: 'hard_paywall_close',
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

  @override
  Widget build(BuildContext context) {
    final offeringsAsync = ref.watch(revenueCatOfferingsProvider);
    final offeringsError = ref.watch(revenueCatOfferingsErrorProvider);
    final offerings = offeringsAsync.asData?.value;
    final monthlyLookup = findPackageForPlanDetailed(
      offerings,
      PackageType.monthly,
    );
    final monthlyPackage = monthlyLookup.package;

    final priceString = monthlyPackage?.storeProduct.priceString ?? '—';

    return PopScope(
      canPop: false, // prevent Android back (supports predictive back)
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Header with Timer + Close
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                color: Colors.red[50],
                child: Row(
                  children: [
                    Text(
                      'OFERTA EXPIRA EM:',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
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
                            fontWeight: FontWeight.w700,
                            color: Colors.red[700],
                            fontSize: 16,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      tooltip: 'Fechar',
                      onPressed: _handleClose,
                      icon: const Icon(Icons.close),
                      color: Colors.black87,
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Seu Plano Está Pronto!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1E1E1E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Baseado no seu perfil, criamos um protocolo exclusivo para você.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),

                      _buildCheckItem('Protocolo Anti-Inchaço (7 Dias)'),
                      _buildCheckItem('Cardápio Detox de Cortisol'),
                      _buildCheckItem('Lista de Compras Inteligente'),
                      _buildCheckItem('Acesso Ilimitado ao Diário'),

                      const SizedBox(height: 40),

                      // Offer Box
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF4CAF50),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          color: const Color(
                            0xFF4CAF50,
                          ).withValues(alpha: 0.05),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: const BoxDecoration(
                                color: Color(0xFF4CAF50),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: Text(
                                'MAIS ESCOLHIDO',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Plano Mensal',
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Text(
                                        'Acesso total imediato',
                                        style: GoogleFonts.inter(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        priceString,
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 24,
                                          color: const Color(0xFF4CAF50),
                                        ),
                                      ),
                                      Text(
                                        '/mês',
                                        style: GoogleFonts.inter(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Sticky Button
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_isLoading || _isRestoring)
                            ? null
                            : () => _handlePurchase(
                                package: monthlyPackage,
                                lookup: monthlyLookup,
                                offerings: offerings,
                                offeringsError: offeringsError,
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'CONTINUAR',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Garantia de 7 dias ou seu dinheiro de volta',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
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
                          onPressed: (_isLoading || _isRestoring)
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
                              : const Text('Restaurar compra'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 24),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePurchase({
    required Package? package,
    required RevenueCatPackageLookupResult lookup,
    required Offerings? offerings,
    required String? offeringsError,
  }) async {
    final analytics = _tracker;
    unawaited(analytics.trackCtaTap(planId: 'monthly', plan: 'mensal'));

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
        'selected_package_null screen=hard_paywall_screen plan=monthly '
        'reason=$reason details="$technicalReason"',
      );
      await analytics.trackPurchaseFailed(
        planId: 'monthly',
        plan: 'mensal',
        productId: 'unavailable',
        reason: reason,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            revenueCatPackageNotFoundMessage(
              planLabel: 'mensal',
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
        planId: 'monthly',
        plan: 'mensal',
        productId: package.storeProduct.identifier,
      );
      await ref.read(subscriptionProvider.notifier).purchasePackage(package);
      await ref.read(subscriptionProvider.notifier).refresh();
      await analytics.trackPurchaseComplete(
        planId: 'monthly',
        plan: 'mensal',
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
        planId: 'monthly',
        plan: 'mensal',
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
        planId: 'monthly',
        plan: 'mensal',
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
        planId: 'monthly',
        plan: 'mensal',
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
}
