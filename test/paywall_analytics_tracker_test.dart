import 'package:flutter_test/flutter_test.dart';
import 'package:nutriz/core/analytics/paywall_analytics_tracker.dart';
import 'package:nutriz/features/premium/domain/entities/paywall_variant.dart';

void main() {
  test('não duplica paywall_view na mesma sessão de tracker', () async {
    final events = <Map<String, Object?>>[];
    final tracker = PaywallAnalyticsTracker(
      paywallId: 'premium_screen',
      variant: PaywallVariant.variantB,
      logEvent: (name, props) async {
        events.add({'name': name, ...props});
      },
    );

    await tracker.trackPaywallView();
    await tracker.trackPaywallView();

    final views = events.where((event) => event['name'] == 'paywall_view');
    expect(views.length, 1);
    expect(views.first['paywall_variant'], 'variant_b');
  });

  test('inclui paywall_variant em eventos críticos', () async {
    final events = <Map<String, Object?>>[];
    final tracker = PaywallAnalyticsTracker(
      paywallId: 'hard_paywall_screen',
      variant: PaywallVariant.variantA,
      logEvent: (name, props) async {
        events.add({'name': name, ...props});
      },
    );

    await tracker.trackCtaTap(planId: 'monthly', plan: 'mensal');
    await tracker.trackPurchaseStart(
      planId: 'monthly',
      plan: 'mensal',
      productId: 'prod_1',
    );
    await tracker.trackPurchaseComplete(
      planId: 'monthly',
      plan: 'mensal',
      productId: 'prod_1',
    );
    await tracker.trackPurchaseFailed(
      planId: 'monthly',
      plan: 'mensal',
      productId: 'prod_1',
      reason: 'PURCHASE CANCELLED',
    );

    for (final event in events) {
      expect(event['paywall_variant'], 'variant_a');
    }

    final failed = events.firstWhere(
      (event) => event['name'] == 'purchase_failed',
    );
    expect(failed['reason'], 'purchase_cancelled');
  });
}
