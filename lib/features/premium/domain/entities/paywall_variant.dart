enum PaywallVariant { variantA, variantB }

extension PaywallVariantX on PaywallVariant {
  String get analyticsValue => switch (this) {
    PaywallVariant.variantA => 'variant_a',
    PaywallVariant.variantB => 'variant_b',
  };
}

class PaywallVariantResolver {
  const PaywallVariantResolver();

  PaywallVariant resolveForUserId(String userId) {
    if (userId.isEmpty) return PaywallVariant.variantA;

    var hash = 0;
    for (final rune in userId.runes) {
      hash = ((hash * 31) + rune) & 0x7fffffff;
    }
    return hash.isEven ? PaywallVariant.variantA : PaywallVariant.variantB;
  }
}
