import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../domain/entities/subscription_status.dart';

// Provider para inicializar o RevenueCat (deve ser chamado no main.dart)
final revenueCatInitializerProvider = FutureProvider<void>((ref) async {
  // TODO: Substituir pela chave real do RevenueCat
  // await Purchases.configure(PurchasesConfiguration("YOUR_API_KEY"));
});

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionStatus>((ref) {
      return SubscriptionNotifier();
    });

class SubscriptionNotifier extends StateNotifier<SubscriptionStatus> {
  SubscriptionNotifier() : super(SubscriptionStatus.free) {
    _checkSubscriptionStatus();
  }

  Future<void> _checkSubscriptionStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final isPro = customerInfo.entitlements.all['premium']?.isActive ?? false;
      state = isPro ? SubscriptionStatus.premium : SubscriptionStatus.free;
    } catch (e) {
      // Em caso de erro (ex: sem internet ou não configurado), assume free por segurança
      state = SubscriptionStatus.free;
    }
  }

  Future<void> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      final isPro = customerInfo.entitlements.all['premium']?.isActive ?? false;
      state = isPro ? SubscriptionStatus.premium : SubscriptionStatus.free;
    } catch (e) {
      // Tratar erro
    }
  }

  // Método para simular assinatura (para testes/debug)
  void debugSetPro(bool isPro) {
    state = isPro ? SubscriptionStatus.premium : SubscriptionStatus.free;
  }
}
