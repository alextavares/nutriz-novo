import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../profile/presentation/notifiers/profile_notifier.dart';
import '../../domain/entities/paywall_variant.dart';

final paywallVariantResolverProvider = Provider<PaywallVariantResolver>((ref) {
  return const PaywallVariantResolver();
});

final paywallVariantProvider = Provider.autoDispose<PaywallVariant>((ref) {
  final userId = ref.watch(
    profileNotifierProvider.select((profile) => profile.id),
  );
  return ref.watch(paywallVariantResolverProvider).resolveForUserId(userId);
});
