import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../core/debug/debug_flags.dart';
import '../../domain/entities/subscription_status.dart';

const _premiumEntitlementId = 'premium';
const _debugForcePro = bool.fromEnvironment(
  'NUTRIZ_DEBUG_FORCE_PRO',
  defaultValue: false,
);

final revenueCatOfferingsErrorProvider = StateProvider<String?>((ref) => null);

String _currentPlatformLabel() {
  if (Platform.isAndroid) return 'android';
  if (Platform.isIOS) return 'ios';
  return Platform.operatingSystem;
}

String _resolveRevenueCatSdkKey({
  required String platform,
  required String androidKey,
  required String iosKey,
  required String fallbackKey,
}) {
  if (platform == 'android') {
    if (androidKey.isNotEmpty) return androidKey;
    return fallbackKey;
  }
  if (platform == 'ios') {
    if (iosKey.isNotEmpty) return iosKey;
    return fallbackKey;
  }
  return fallbackKey;
}

String revenueCatMissingSdkKeyMessage([String? platform]) {
  final current = platform ?? _currentPlatformLabel();
  return 'RevenueCat não configurado: SDK key ausente para $current. '
      'Use --dart-define=REVENUECAT_PUBLIC_SDK_KEY_${current.toUpperCase()}=... '
      'ou --dart-define=REVENUECAT_PUBLIC_SDK_KEY=...';
}

String revenueCatOfferingEmptyMessage({String? offeringsError}) {
  if (offeringsError != null && offeringsError.trim().isNotEmpty) {
    return offeringsError;
  }
  return 'Nenhum plano disponível no Offering atual do RevenueCat. '
      'Verifique Offering/Packages (mensal/anual).';
}

String revenueCatPackageNotFoundMessage({
  required String planLabel,
  String? offeringsError,
}) {
  final base = revenueCatOfferingEmptyMessage(offeringsError: offeringsError);
  return 'Plano $planLabel indisponível. $base';
}

Package? findPackageForPlan(Offerings? offerings, PackageType packageType) {
  final current = offerings?.current;
  if (current == null) return null;

  for (final package in current.availablePackages) {
    if (package.packageType == packageType) {
      return package;
    }
  }
  return null;
}

abstract class RevenueCatClient {
  Future<void> configure(String apiKey, {required bool verboseLogs});
  Future<Offerings> getOfferings();
  Future<bool> hasActivePremiumEntitlement();
  Future<bool> restorePremiumEntitlement();
  Future<bool> purchasePackage(Package package);
}

class PurchasesRevenueCatClient implements RevenueCatClient {
  bool _isPremium(CustomerInfo customerInfo) {
    // ignore: deprecated_member_use
    return customerInfo.entitlements.all[_premiumEntitlementId]?.isActive ??
        false;
  }

  @override
  Future<void> configure(String apiKey, {required bool verboseLogs}) async {
    if (kDebugMode) {
      Purchases.setLogLevel(verboseLogs ? LogLevel.debug : LogLevel.warn);
    }
    await Purchases.configure(PurchasesConfiguration(apiKey));
  }

  @override
  Future<Offerings> getOfferings() => Purchases.getOfferings();

  @override
  Future<bool> hasActivePremiumEntitlement() async {
    final customerInfo = await Purchases.getCustomerInfo();
    return _isPremium(customerInfo);
  }

  @override
  Future<bool> restorePremiumEntitlement() async {
    final customerInfo = await Purchases.restorePurchases();
    return _isPremium(customerInfo);
  }

  @override
  Future<bool> purchasePackage(Package package) async {
    // ignore: deprecated_member_use
    final dynamic purchaseResult = await Purchases.purchasePackage(package);
    final CustomerInfo customerInfo = () {
      try {
        return purchaseResult.customerInfo as CustomerInfo;
      } catch (_) {
        return purchaseResult as CustomerInfo;
      }
    }();
    return _isPremium(customerInfo);
  }
}

class RevenueCatGateway {
  RevenueCatGateway({
    required this.client,
    required this.platform,
    required this.androidSdkKey,
    required this.iosSdkKey,
    required this.fallbackSdkKey,
  });

  final RevenueCatClient client;
  final String platform;
  final String androidSdkKey;
  final String iosSdkKey;
  final String fallbackSdkKey;

  bool _configured = false;
  Future<void>? _configureFuture;

  Future<void> ensureConfigured() async {
    if (_configured) return;

    _configureFuture ??= () async {
      final apiKey = _resolveRevenueCatSdkKey(
        platform: platform,
        androidKey: androidSdkKey,
        iosKey: iosSdkKey,
        fallbackKey: fallbackSdkKey,
      );
      if (apiKey.isEmpty) {
        throw StateError(revenueCatMissingSdkKeyMessage(platform));
      }
      await client.configure(apiKey, verboseLogs: DebugFlags.canVerbose);
      _configured = true;
    }();

    await _configureFuture;
  }
}

final revenueCatClientProvider = Provider<RevenueCatClient>((ref) {
  return PurchasesRevenueCatClient();
});

final revenueCatGatewayProvider = Provider<RevenueCatGateway>((ref) {
  return RevenueCatGateway(
    client: ref.watch(revenueCatClientProvider),
    platform: _currentPlatformLabel(),
    androidSdkKey: const String.fromEnvironment(
      'REVENUECAT_PUBLIC_SDK_KEY_ANDROID',
    ),
    iosSdkKey: const String.fromEnvironment('REVENUECAT_PUBLIC_SDK_KEY_IOS'),
    fallbackSdkKey: const String.fromEnvironment('REVENUECAT_PUBLIC_SDK_KEY'),
  );
});

// Provider para inicializar o RevenueCat (deve ser chamado no app startup)
final revenueCatInitializerProvider = FutureProvider<bool>((ref) async {
  final gateway = ref.watch(revenueCatGatewayProvider);
  try {
    await gateway.ensureConfigured();
    return true;
  } catch (e) {
    if (kDebugMode && DebugFlags.canLog) {
      debugPrint('DEBUG: RevenueCat init skipped: $e');
    }
    return false;
  }
});

final revenueCatOfferingsProvider = FutureProvider<Offerings?>((ref) async {
  final gateway = ref.watch(revenueCatGatewayProvider);
  ref.read(revenueCatOfferingsErrorProvider.notifier).state = null;

  try {
    await gateway.ensureConfigured();
  } on StateError catch (e) {
    final text = e.message.toString();
    ref.read(revenueCatOfferingsErrorProvider.notifier).state = text;
    if (kDebugMode && DebugFlags.canLog) {
      debugPrint('DEBUG: RevenueCat config error: $text');
    }
    return null;
  } catch (e) {
    final text = 'Falha ao inicializar RevenueCat: $e';
    ref.read(revenueCatOfferingsErrorProvider.notifier).state = text;
    if (kDebugMode && DebugFlags.canLog) {
      debugPrint('DEBUG: RevenueCat config error: $text');
    }
    return null;
  }

  try {
    final offerings = await gateway.client.getOfferings();
    final current = offerings.current;
    if (current == null || current.availablePackages.isEmpty) {
      ref.read(revenueCatOfferingsErrorProvider.notifier).state =
          revenueCatOfferingEmptyMessage();
    }
    return offerings;
  } on PlatformException catch (e) {
    final code = PurchasesErrorHelper.getErrorCode(e);
    final msg = e.message ?? e.toString();
    final text = '${code.name}: $msg';
    ref.read(revenueCatOfferingsErrorProvider.notifier).state = text;
    if (kDebugMode && DebugFlags.canLog) {
      debugPrint('DEBUG: Purchases.getOfferings failed: $text');
    }
    return null;
  } catch (e) {
    ref.read(revenueCatOfferingsErrorProvider.notifier).state = e.toString();
    if (kDebugMode && DebugFlags.canLog) {
      debugPrint('DEBUG: Purchases.getOfferings failed: $e');
    }
    return null;
  }
});

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionStatus>((ref) {
      return SubscriptionNotifier(
        gateway: ref.watch(revenueCatGatewayProvider),
      );
    });

class SubscriptionNotifier extends StateNotifier<SubscriptionStatus> {
  SubscriptionNotifier({
    required RevenueCatGateway gateway,
    this.debugForceProEnabled = _debugForcePro,
  }) : _gateway = gateway,
       super(SubscriptionStatus.free) {
    _checkSubscriptionStatus();
  }

  final RevenueCatGateway _gateway;
  final bool debugForceProEnabled;
  bool _checking = false;

  Future<void> _checkSubscriptionStatus() async {
    if (_checking) return;
    _checking = true;

    if (kDebugMode && debugForceProEnabled) {
      state = SubscriptionStatus.premium;
      _checking = false;
      return;
    }

    try {
      await _gateway.ensureConfigured();
    } on StateError catch (_) {
      state = SubscriptionStatus.free;
      _checking = false;
      return;
    }

    try {
      final isPro = await _gateway.client.hasActivePremiumEntitlement();
      state = isPro ? SubscriptionStatus.premium : SubscriptionStatus.free;
    } catch (e) {
      // Em caso de erro (ex: sem internet/SDK), não derruba Premium para evitar flicker.
      // O estado será revalidado na próxima chamada bem-sucedida.
      if (state.isFree) {
        state = SubscriptionStatus.free;
      }
    } finally {
      _checking = false;
    }
  }

  Future<void> refresh() => _checkSubscriptionStatus();

  Future<void> restorePurchases() async {
    await _gateway.ensureConfigured();
    final isPro = await _gateway.client.restorePremiumEntitlement();
    state = isPro ? SubscriptionStatus.premium : SubscriptionStatus.free;
  }

  Future<void> purchasePackage(Package package) async {
    await _gateway.ensureConfigured();
    final isPro = await _gateway.client.purchasePackage(package);
    state = isPro ? SubscriptionStatus.premium : SubscriptionStatus.free;
  }

  // Método para simular assinatura (para testes/debug)
  void debugSetPro(bool isPro) {
    state = isPro ? SubscriptionStatus.premium : SubscriptionStatus.free;
  }
}
