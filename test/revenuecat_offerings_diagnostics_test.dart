import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutriz/features/premium/presentation/providers/subscription_provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class _MockOfferings extends Mock implements Offerings {}

class _MockOffering extends Mock implements Offering {}

class _MockPackage extends Mock implements Package {}

class _FakeRevenueCatClient implements RevenueCatClient {
  int configureCalls = 0;
  int failConfigureTimes = 0;

  @override
  Future<void> configure(String apiKey, {required bool verboseLogs}) async {
    configureCalls++;
    if (failConfigureTimes > 0) {
      failConfigureTimes--;
      throw PlatformException(code: 'configure_failed');
    }
  }

  @override
  Future<Offerings> getOfferings() {
    throw UnimplementedError();
  }

  @override
  Future<bool> hasActivePremiumEntitlement() async => false;

  @override
  Future<bool> restorePremiumEntitlement() async => false;

  @override
  Future<bool> purchasePackage(Package package) async => false;
}

void main() {
  test('lookup retorna offerings_null quando Offerings está null', () {
    final result = findPackageForPlanDetailed(null, PackageType.monthly);
    expect(result.package, isNull);
    expect(result.reasonCode, 'offerings_null');
  });

  test('lookup retorna current_offering_null quando current está null', () {
    final offerings = _MockOfferings();
    when(() => offerings.current).thenReturn(null);
    when(() => offerings.all).thenReturn(const {});

    final result = findPackageForPlanDetailed(offerings, PackageType.annual);
    expect(result.package, isNull);
    expect(result.reasonCode, 'current_offering_null');
  });

  test('lookup retorna package_type_not_found quando tipo não existe', () {
    final offerings = _MockOfferings();
    final current = _MockOffering();
    final monthly = _MockPackage();

    when(() => offerings.current).thenReturn(current);
    when(() => offerings.all).thenReturn({'main': current});
    when(() => current.identifier).thenReturn('main');
    when(() => current.availablePackages).thenReturn([monthly]);
    when(() => monthly.packageType).thenReturn(PackageType.monthly);

    final result = findPackageForPlanDetailed(offerings, PackageType.annual);
    expect(result.package, isNull);
    expect(result.reasonCode, 'package_type_not_found');
  });

  test('lookup encontra pacote quando packageType existe', () {
    final offerings = _MockOfferings();
    final current = _MockOffering();
    final annual = _MockPackage();

    when(() => offerings.current).thenReturn(current);
    when(() => offerings.all).thenReturn({'main': current});
    when(() => current.identifier).thenReturn('main');
    when(() => current.availablePackages).thenReturn([annual]);
    when(() => annual.packageType).thenReturn(PackageType.annual);

    final result = findPackageForPlanDetailed(offerings, PackageType.annual);
    expect(result.package, annual);
    expect(result.reasonCode, 'package_found');
  });

  test('evidência de offering carregado com monthly/annual disponíveis', () {
    final offerings = _MockOfferings();
    final current = _MockOffering();
    final monthly = _MockPackage();
    final annual = _MockPackage();

    when(() => offerings.current).thenReturn(current);
    when(() => offerings.all).thenReturn({'main': current});
    when(() => current.identifier).thenReturn('main');
    when(() => current.availablePackages).thenReturn([monthly, annual]);
    when(() => monthly.packageType).thenReturn(PackageType.monthly);
    when(() => annual.packageType).thenReturn(PackageType.annual);

    final monthlyLookup = findPackageForPlanDetailed(offerings, PackageType.monthly);
    final annualLookup = findPackageForPlanDetailed(offerings, PackageType.annual);

    expect(monthlyLookup.reasonCode, 'package_found');
    expect(annualLookup.reasonCode, 'package_found');

    // ignore: avoid_print
    print(
      'OFFERING_EVIDENCE current=${current.identifier} monthly=${monthlyLookup.reasonCode} annual=${annualLookup.reasonCode}',
    );
  });

  test('reason sdk_key_missing tem prioridade quando offeringsError informa chave ausente', () {
    final lookup = RevenueCatPackageLookupResult(
      packageType: PackageType.monthly,
      package: null,
      reasonCode: 'offerings_null',
      technicalReason: 'Offerings retornou null.',
    );
    final reason = revenueCatSelectedPackageNullReason(
      offerings: null,
      lookup: lookup,
      offeringsError: revenueCatMissingSdkKeyMessage('android'),
    );
    expect(reason, 'sdk_key_missing');
  });

  test('gateway tenta configurar novamente após falha transitória', () async {
    final client = _FakeRevenueCatClient()..failConfigureTimes = 1;
    final gateway = RevenueCatGateway(
      client: client,
      platform: 'android',
      androidSdkKey: 'android_key',
      iosSdkKey: '',
      fallbackSdkKey: '',
    );

    await expectLater(gateway.ensureConfigured(), throwsA(isA<PlatformException>()));
    await gateway.ensureConfigured();

    expect(client.configureCalls, 2);
  });
}
