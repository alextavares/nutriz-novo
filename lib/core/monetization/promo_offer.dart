import 'package:flutter_riverpod/flutter_riverpod.dart';

class PromoOfferState {
  final DateTime? endsAt;
  final int discountPercent;
  final String? source;

  const PromoOfferState({this.endsAt, this.discountPercent = 0, this.source});

  bool get isActive => endsAt != null && endsAt!.isAfter(DateTime.now());

  Duration remaining(DateTime now) {
    final end = endsAt;
    if (end == null || !end.isAfter(now)) return Duration.zero;
    return end.difference(now);
  }
}

class PromoOfferNotifier extends StateNotifier<PromoOfferState> {
  PromoOfferNotifier() : super(const PromoOfferState());

  void ensureActive({
    required Duration duration,
    int discountPercent = 0,
    String? source,
    DateTime? now,
  }) {
    final currentNow = now ?? DateTime.now();
    final end = state.endsAt;
    if (end != null && end.isAfter(currentNow)) return;

    state = PromoOfferState(
      endsAt: currentNow.add(duration),
      discountPercent: discountPercent,
      source: source,
    );
  }

  void clear() => state = const PromoOfferState();
}

final promoOfferProvider =
    StateNotifierProvider<PromoOfferNotifier, PromoOfferState>((ref) {
      return PromoOfferNotifier();
    });

/// Ticker used to update countdown UI (badge/paywall) once per second.
final promoOfferTickerProvider = StreamProvider.autoDispose<DateTime>((ref) async* {
  while (true) {
    yield DateTime.now();
    await Future<void>.delayed(const Duration(seconds: 1));
  }
});
