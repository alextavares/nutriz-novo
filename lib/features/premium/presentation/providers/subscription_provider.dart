import 'dart:io';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../core/debug/debug_flags.dart';
import '../../domain/entities/subscription_status.dart';

const _premiumEntitlementId = 'premium';
const _debugForcePro = bool.fromEnvironment(
  'NUTRIZ_DEBUG_FORCE_PRO',
  defaultValue: true, // Forçando PRO para testes do usuário
);

final revenueCatOfferingsErrorProvider = StateProvider<String?>((ref) => null);

void logRevenueCatRuntime(
  String message, {
  Object? error,
  StackTrace? stackTrace,
}) {
  developer.log(
    message,
    name: 'RevenueCat',
    error: error,
    stackTrace: stackTrace,
  );
  if (DebugFlags.canLog) {
    debugPrint('RC: $message');
  }
}

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
  String? technicalReason,
}) {
  return 'O plano $planLabel está indisponível no momento. Tente novamente mais tarde.';
}

class RevenueCatPackageLookupResult {
  const RevenueCatPackageLookupResult({
    required this.packageType,
    required this.package,
    required this.reasonCode,
    required this.technicalReason,
  });

  final PackageType packageType;
  final Package? package;
  final String reasonCode;
  final String technicalReason;
}

RevenueCatPackageLookupResult findPackageForPlanDetailed(
  Offerings? offerings,
  PackageType packageType,
) {
  if (offerings == null) {
    return RevenueCatPackageLookupResult(
      packageType: packageType,
      package: null,
      reasonCode: 'offerings_null',
      technicalReason: 'Offerings retornou null.',
    );
  }

  final current = offerings.current;
  if (current == null) {
    return RevenueCatPackageLookupResult(
      packageType: packageType,
      package: null,
      reasonCode: 'current_offering_null',
      technicalReason:
          'Offerings.current é null. Offerings disponíveis: ${offerings.all.keys.join(', ')}.',
    );
  }

  for (final package in current.availablePackages) {
    if (package.packageType == packageType) {
      return RevenueCatPackageLookupResult(
        packageType: packageType,
        package: package,
        reasonCode: 'package_found',
        technicalReason:
            'Pacote ${packageType.name} encontrado no offering ${current.identifier}.',
      );
    }
  }

  final available = current.availablePackages
      .map((p) => p.packageType.name)
      .join(', ');
  return RevenueCatPackageLookupResult(
    packageType: packageType,
    package: null,
    reasonCode: 'package_type_not_found',
    technicalReason:
        'Offering ${current.identifier} sem pacote ${packageType.name}. Tipos disponíveis: $available.',
  );
}

String revenueCatSelectedPackageNullReason({
  required Offerings? offerings,
  required RevenueCatPackageLookupResult lookup,
  String? offeringsError,
}) {
  final text = offeringsError?.trim();
  if (text != null && text.isNotEmpty) {
    if (text.contains('SDK key ausente')) {
      return 'sdk_key_missing';
    }
    return 'offerings_error';
  }
  if (offerings == null) return 'offerings_null';
  if (offerings.current == null) return 'current_offering_null';
  return lookup.reasonCode;
}

String revenueCatSelectedPackageNullTechnicalReason({
  required Offerings? offerings,
  required RevenueCatPackageLookupResult lookup,
  String? offeringsError,
}) {
  final reason = revenueCatSelectedPackageNullReason(
    offerings: offerings,
    lookup: lookup,
    offeringsError: offeringsError,
  );
  final errorText = offeringsError?.trim();
  final offeringId = offerings?.current?.identifier ?? 'null';
  final availableTypes =
      offerings?.current?.availablePackages
          .map((p) => p.packageType.name)
          .join(', ') ??
      '';
  if (errorText != null && errorText.isNotEmpty) {
    return 'reason=$reason; error="$errorText"; current_offering=$offeringId; available_types=[$availableTypes]';
  }
  return 'reason=$reason; ${lookup.technicalReason}';
}

Package? findPackageForPlan(Offerings? offerings, PackageType packageType) {
  return findPackageForPlanDetailed(offerings, packageType).package;
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

  String _sdkKeySource() {
    if (platform == 'android' && androidSdkKey.isNotEmpty) {
      return 'android_define';
    }
    if (platform == 'ios' && iosSdkKey.isNotEmpty) {
      return 'ios_define';
    }
    if (fallbackSdkKey.isNotEmpty) {
      return 'fallback_define';
    }
    return 'missing';
  }

  Future<void> ensureConfigured() async {
    if (_configured) return;
    if (_configureFuture != null) {
      await _configureFuture;
      return;
    }

    _configureFuture = () async {
      final keySource = _sdkKeySource();
      logRevenueCatRuntime(
        'init_start platform=$platform key_source=$keySource '
        'android_define_present=${androidSdkKey.isNotEmpty} '
        'ios_define_present=${iosSdkKey.isNotEmpty} '
        'fallback_define_present=${fallbackSdkKey.isNotEmpty}',
      );
      final apiKey = _resolveRevenueCatSdkKey(
        platform: platform,
        androidKey: androidSdkKey,
        iosKey: iosSdkKey,
        fallbackKey: fallbackSdkKey,
      );
      if (apiKey.isEmpty) {
        logRevenueCatRuntime(
          'init_failed reason=sdk_key_missing platform=$platform key_source=$keySource',
        );
        throw StateError(revenueCatMissingSdkKeyMessage(platform));
      }
      await client.configure(apiKey, verboseLogs: DebugFlags.canVerbose);
      _configured = true;
      logRevenueCatRuntime(
        'init_success platform=$platform key_source=$keySource',
      );
    }();

    try {
      await _configureFuture;
    } finally {
      _configureFuture = null;
    }
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
  logRevenueCatRuntime('offerings_fetch_start platform=${gateway.platform}');

  try {
    await gateway.ensureConfigured();
  } on StateError catch (e) {
    final text = e.message.toString();
    ref.read(revenueCatOfferingsErrorProvider.notifier).state = text;
    logRevenueCatRuntime(
      'offerings_fetch_failed reason=sdk_key_missing error=$text',
    );
    if (kDebugMode && DebugFlags.canLog) {
      debugPrint('DEBUG: RevenueCat config error: $text');
    }
    return null;
  } catch (e) {
    final text = 'Falha ao inicializar RevenueCat: $e';
    ref.read(revenueCatOfferingsErrorProvider.notifier).state = text;
    logRevenueCatRuntime(
      'offerings_fetch_failed reason=init_error error=$text',
    );
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
      logRevenueCatRuntime(
        'offerings_fetch_result current_offering=null_or_empty '
        'offerings_all=[${offerings.all.keys.join(', ')}]',
      );
    } else {
      final packagesSummary = current.availablePackages
          .map(
            (p) =>
                '${p.packageType.name}:${p.identifier}:${p.storeProduct.priceString}',
          )
          .join(' | ');
      logRevenueCatRuntime(
        'offerings_fetch_result current_offering=${current.identifier} '
        'packages=$packagesSummary',
      );
    }

    final monthlyLookup = findPackageForPlanDetailed(
      offerings,
      PackageType.monthly,
    );
    final annualLookup = findPackageForPlanDetailed(
      offerings,
      PackageType.annual,
    );
    logRevenueCatRuntime(
      'offerings_lookup monthly=${monthlyLookup.reasonCode} '
      'annual=${annualLookup.reasonCode}',
    );
    if (monthlyLookup.package == null || annualLookup.package == null) {
      final currentError = ref.read(revenueCatOfferingsErrorProvider);
      ref.read(revenueCatOfferingsErrorProvider.notifier).state =
          currentError ??
          'Offering sem pacotes obrigatórios: monthly=${monthlyLookup.reasonCode}, annual=${annualLookup.reasonCode}.';
    }
    return offerings;
  } on PlatformException catch (e) {
    final code = PurchasesErrorHelper.getErrorCode(e);
    final msg = e.message ?? e.toString();
    final text = '${code.name}: $msg';
    ref.read(revenueCatOfferingsErrorProvider.notifier).state = text;
    logRevenueCatRuntime(
      'offerings_fetch_failed reason=platform_exception code=${code.name} error=$msg',
      error: e,
    );
    if (kDebugMode && DebugFlags.canLog) {
      debugPrint('DEBUG: Purchases.getOfferings failed: $text');
    }
    return null;
  } catch (e) {
    ref.read(revenueCatOfferingsErrorProvider.notifier).state = e.toString();
    logRevenueCatRuntime(
      'offerings_fetch_failed reason=unknown error=$e',
      error: e,
    );
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
