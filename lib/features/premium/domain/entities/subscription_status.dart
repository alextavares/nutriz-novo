enum SubscriptionStatus {
  free,
  premium;

  bool get isPro => this == SubscriptionStatus.premium;
  bool get isFree => this == SubscriptionStatus.free;
}
