import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutriz/features/premium/domain/entities/subscription_status.dart';
import 'package:nutriz/features/premium/presentation/providers/subscription_provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class _MockPackage extends Mock implements Package {}

class _FakeRevenueCatClient implements RevenueCatClient {
  bool configured = false;
  bool isPremiumFromStatus = false;
  bool isPremiumFromRestore = false;
  bool isPremiumFromPurchase = false;
  Object? purchaseError;

  @override
  Future<void> configure(String apiKey, {required bool verboseLogs}) async {
    configured = true;
  }

  @override
  Future<Offerings> getOfferings() {
    throw UnimplementedError();
  }

  @override
  Future<bool> hasActivePremiumEntitlement() async => isPremiumFromStatus;

  @override
  Future<bool> restorePremiumEntitlement() async => isPremiumFromRestore;

  @override
  Future<bool> purchasePackage(Package package) async {
    if (purchaseError != null) {
      throw purchaseError!;
    }
    return isPremiumFromPurchase;
  }
}

void main() {
  test('estado inicial permanece free sem SDK key', () async {
    final client = _FakeRevenueCatClient();
    final gateway = RevenueCatGateway(
      client: client,
      platform: 'android',
      androidSdkKey: '',
      iosSdkKey: '',
      fallbackSdkKey: '',
    );

    final notifier = SubscriptionNotifier(gateway: gateway);
    await Future<void>.delayed(Duration.zero);

    expect(notifier.state, SubscriptionStatus.free);
    expect(client.configured, isFalse);
  });

  test('compra bem-sucedida ativa premium', () async {
    final client = _FakeRevenueCatClient()..isPremiumFromPurchase = true;
    final gateway = RevenueCatGateway(
      client: client,
      platform: 'android',
      androidSdkKey: 'android_key',
      iosSdkKey: '',
      fallbackSdkKey: '',
    );

    final notifier = SubscriptionNotifier(gateway: gateway);
    await notifier.purchasePackage(_MockPackage());

    expect(notifier.state, SubscriptionStatus.premium);
  });

  test('restore sem entitlement mantém free', () async {
    final client = _FakeRevenueCatClient()
      ..isPremiumFromStatus = false
      ..isPremiumFromRestore = false;
    final gateway = RevenueCatGateway(
      client: client,
      platform: 'android',
      androidSdkKey: 'android_key',
      iosSdkKey: '',
      fallbackSdkKey: '',
    );

    final notifier = SubscriptionNotifier(gateway: gateway);
    await notifier.restorePurchases();

    expect(notifier.state, SubscriptionStatus.free);
  });

  test('erro de compra preserva estado free e propaga exceção', () async {
    final client = _FakeRevenueCatClient()
      ..isPremiumFromStatus = false
      ..purchaseError = PlatformException(code: 'purchase_error');
    final gateway = RevenueCatGateway(
      client: client,
      platform: 'android',
      androidSdkKey: 'android_key',
      iosSdkKey: '',
      fallbackSdkKey: '',
    );

    final notifier = SubscriptionNotifier(gateway: gateway);
    await expectLater(
      notifier.purchasePackage(_MockPackage()),
      throwsA(isA<PlatformException>()),
    );

    expect(notifier.state, SubscriptionStatus.free);
  });
}
