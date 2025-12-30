import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../domain/entities/subscription_status.dart';

const _premiumEntitlementId = 'premium';

String _resolveRevenueCatSdkKey() {
  // Chave obtida do painel do RevenueCat (Projeto NutriZ-z)
  const hardcodedAndroidKey = 'test_iFodMDRffUeTdZuGuMOUdebdhOa';

  final androidKey = const String.fromEnvironment(
    'REVENUECAT_PUBLIC_SDK_KEY_ANDROID',
    defaultValue: hardcodedAndroidKey,
  );
  final iosKey = const String.fromEnvironment('REVENUECAT_PUBLIC_SDK_KEY_IOS');
  final fallbackKey = const String.fromEnvironment('REVENUECAT_PUBLIC_SDK_KEY');

  if (Platform.isAndroid)
    return androidKey.isNotEmpty ? androidKey : hardcodedAndroidKey;
  if (Platform.isIOS && iosKey.isNotEmpty) return iosKey;
  return fallbackKey;
}

bool _revenueCatConfigured = false;
Future<void>? _revenueCatConfigureFuture;

Future<void> _ensureRevenueCatConfigured() async {
  if (_revenueCatConfigured) return;

  _revenueCatConfigureFuture ??= () async {
    final apiKey = _resolveRevenueCatSdkKey();
    if (apiKey.isEmpty) return;

    if (kDebugMode) {
      Purchases.setLogLevel(LogLevel.debug);
    }

    await Purchases.configure(PurchasesConfiguration(apiKey));
    _revenueCatConfigured = true;
  }();

  await _revenueCatConfigureFuture;
}

// Provider para inicializar o RevenueCat (deve ser chamado no main.dart)
final revenueCatInitializerProvider = FutureProvider<bool>((ref) async {
  await _ensureRevenueCatConfigured();
  return _revenueCatConfigured;
});

final revenueCatOfferingsProvider = FutureProvider<Offerings?>((ref) async {
  await _ensureRevenueCatConfigured();
  if (!_revenueCatConfigured) return null;

  try {
    return await Purchases.getOfferings();
  } catch (_) {
    return null;
  }
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
    await _ensureRevenueCatConfigured();
    if (!_revenueCatConfigured) {
      state = SubscriptionStatus.free;
      return;
    }

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      // ignore: deprecated_member_use
      final isPro =
          customerInfo.entitlements.all[_premiumEntitlementId]?.isActive ??
          false;
      state = isPro ? SubscriptionStatus.premium : SubscriptionStatus.free;
    } catch (e) {
      // Em caso de erro (ex: sem internet ou não configurado), assume free por segurança
      state = SubscriptionStatus.free;
    }
  }

  Future<void> refresh() => _checkSubscriptionStatus();

  Future<void> restorePurchases() async {
    await _ensureRevenueCatConfigured();
    if (!_revenueCatConfigured) {
      throw StateError('RevenueCat não configurado (SDK key ausente).');
    }

    try {
      final customerInfo = await Purchases.restorePurchases();
      // ignore: deprecated_member_use
      final isPro =
          customerInfo.entitlements.all[_premiumEntitlementId]?.isActive ??
          false;
      state = isPro ? SubscriptionStatus.premium : SubscriptionStatus.free;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> purchasePackage(Package package) async {
    await _ensureRevenueCatConfigured();
    if (!_revenueCatConfigured) {
      throw StateError('RevenueCat não configurado (SDK key ausente).');
    }

    // ignore: deprecated_member_use
    final dynamic purchaseResult = await Purchases.purchasePackage(package);
    final CustomerInfo customerInfo = () {
      try {
        return purchaseResult.customerInfo as CustomerInfo;
      } catch (_) {
        return purchaseResult as CustomerInfo;
      }
    }();
    // ignore: deprecated_member_use
    final isPro =
        customerInfo.entitlements.all[_premiumEntitlementId]?.isActive ?? false;
    state = isPro ? SubscriptionStatus.premium : SubscriptionStatus.free;
  }

  // Método para simular assinatura (para testes/debug)
  void debugSetPro(bool isPro) {
    state = isPro ? SubscriptionStatus.premium : SubscriptionStatus.free;
  }
}
