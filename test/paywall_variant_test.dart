import 'package:flutter_test/flutter_test.dart';
import 'package:nutriz/features/premium/domain/entities/paywall_variant.dart';

void main() {
  group('PaywallVariantResolver', () {
    const resolver = PaywallVariantResolver();

    test('retorna variante determinística para o mesmo userId', () {
      final first = resolver.resolveForUserId('user_123');
      final second = resolver.resolveForUserId('user_123');

      expect(second, first);
    });

    test('retorna variant_a para userId vazio', () {
      final variant = resolver.resolveForUserId('');

      expect(variant, PaywallVariant.variantA);
      expect(variant.analyticsValue, 'variant_a');
    });
  });
}
