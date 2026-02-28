import '../../features/premium/domain/entities/paywall_variant.dart';

class PaywallAnalyticsTracker {
  PaywallAnalyticsTracker({
    required this.paywallId,
    required this.variant,
    required this.logEvent,
  });

  final String paywallId;
  final PaywallVariant variant;
  final Future<void> Function(String, Map<String, Object?>) logEvent;

  bool _viewLogged = false;

  Map<String, Object?> withBase(Map<String, Object?> extra) {
    return {
      'paywall_id': paywallId,
      'paywall_variant': variant.analyticsValue,
      ...extra,
    };
  }

  Future<void> trackPaywallView() async {
    if (_viewLogged) return;
    _viewLogged = true;
    await logEvent('paywall_view', withBase(const {}));
  }

  Future<void> trackDismissed({String? source}) {
    return logEvent(
      'paywall_dismissed',
      withBase({if (source != null && source.isNotEmpty) 'source': source}),
    );
  }

  Future<void> trackCtaTap({
    required String planId,
    required String plan,
    String? productId,
  }) {
    return logEvent(
      'paywall_cta_tap',
      withBase({
        'plan_id': planId,
        'plan': plan,
        if (productId != null) 'product_id': productId,
      }),
    );
  }

  Future<void> trackPurchaseStart({
    required String planId,
    required String plan,
    required String productId,
  }) {
    return logEvent(
      'purchase_start',
      withBase({'plan_id': planId, 'plan': plan, 'product_id': productId}),
    );
  }

  Future<void> trackPurchaseComplete({
    required String planId,
    required String plan,
    required String productId,
  }) {
    return logEvent(
      'purchase_complete',
      withBase({'plan_id': planId, 'plan': plan, 'product_id': productId}),
    );
  }

  Future<void> trackPurchaseFailed({
    required String planId,
    required String plan,
    required String reason,
    String? productId,
  }) {
    return logEvent(
      'purchase_failed',
      withBase({
        'plan_id': planId,
        'plan': plan,
        'reason': normalizeFailureReason(reason),
        if (productId != null) 'product_id': productId,
      }),
    );
  }

  static String normalizeFailureReason(String raw) {
    final normalized = raw
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    if (normalized.isEmpty) return 'unknown';
    return normalized.length <= 50 ? normalized : normalized.substring(0, 50);
  }
}
