enum SubscriptionStatus { free, premium }

extension SubscriptionStatusX on SubscriptionStatus {
  bool get isPro => this == SubscriptionStatus.premium;
  bool get isFree => this == SubscriptionStatus.free;
}
