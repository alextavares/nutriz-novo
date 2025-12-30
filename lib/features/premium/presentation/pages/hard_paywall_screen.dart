import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../providers/subscription_provider.dart';

class HardPaywallScreen extends ConsumerStatefulWidget {
  const HardPaywallScreen({super.key});

  @override
  ConsumerState<HardPaywallScreen> createState() => _HardPaywallScreenState();
}

class _HardPaywallScreenState extends ConsumerState<HardPaywallScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final offeringsAsync = ref.watch(revenueCatOfferingsProvider);

    // Attempt to find the monthly package
    final offerings = offeringsAsync.asData?.value;
    final currentOffering = offerings?.current;
    final monthlyPackage = currentOffering?.availablePackages.firstWhere(
      (p) => p.packageType == PackageType.monthly,
      orElse: () => currentOffering.availablePackages.first, // Fallback
    );

    // If still loading or no package found, show loading state or fallback UI
    // For MVP, if loading, we show a spinner on the button or price
    final priceString = monthlyPackage?.storeProduct.priceString ?? "R\$ 49,90";

    return WillPopScope(
      onWillPop: () async => false, // PREVENT BACK NAVIGATION
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Header with Timer
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                color: Colors.red[50], // Urgency bg
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "OFERTA EXPIRA EM:",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      "09:59", // TODO: Implement real timer logic if needed
                      style: GoogleFonts.robotoMono(
                        fontWeight: FontWeight.w700,
                        color: Colors.red[700],
                        fontSize: 16,
                      ),
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
                        "Seu Plano Está Pronto!",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1E1E1E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Baseado no seu perfil, criamos um protocolo exclusivo para você.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Benefits Checkmarks
                      _buildCheckItem("Protocolo Anti-Inchaço (7 Dias)"),
                      _buildCheckItem("Cardápio Detox de Cortisol"),
                      _buildCheckItem("Lista de Compras Inteligente"),
                      _buildCheckItem("Acesso Ilimitado ao Diário"),

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
                          color: const Color(0xFF4CAF50).withOpacity(0.05),
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
                                "MAIS ESCOLHIDO",
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
                                        "Plano Mensal",
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Text(
                                        "Acesso total imediato",
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
                                        "/mês",
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
                        onPressed: _isLoading
                            ? null
                            : () => _handlePurchase(monthlyPackage),
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
                                "CONTINUAR",
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
                      "Garantia de 7 dias ou seu dinheiro de volta",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
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

  Future<void> _handlePurchase(Package? package) async {
    if (package == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Ocorreu um erro ao carregar o plano. Tente novamente.",
          ),
        ),
      );
      // Attempt to refresh/init
      ref.refresh(revenueCatOfferingsProvider);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(subscriptionProvider.notifier).purchasePackage(package);

      if (!mounted) return;

      // Success! Check status again to be safe
      final isPro = ref.read(subscriptionProvider).isPro;
      if (isPro) {
        context.go('/diary'); // Success Navigation
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Assinatura não ativada. Tente novamente."),
          ),
        );
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro: ${e.message}")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erro desconhecido ao processar pagamento."),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
