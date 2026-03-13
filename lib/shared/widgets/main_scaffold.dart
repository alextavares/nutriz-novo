import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/debug/debug_flags.dart';
import '../../core/monetization/promo_offer.dart';
import '../../core/monetization/promo_offer_badge.dart';
import '../../features/premium/presentation/providers/subscription_provider.dart';
import 'bottom_nav_bar.dart';

/// MainScaffold with WidgetsBindingObserver to intercept the back button
/// at the platform level, before GoRouter processes it.
class MainScaffold extends ConsumerStatefulWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() async {
    final currentIndex = _calculateSelectedIndex(context);

    if (DebugFlags.canVerbose) {
      debugPrint('DEBUG: didPopRoute called, currentIndex=$currentIndex');
    }

    if (currentIndex != 0) {
      context.go('/diary');
      return true;
    }

    return false;
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/diary')) return 0;
    if (location.startsWith('/coach')) return 1;
    if (location.startsWith('/fasting')) return 2;
    if (location.startsWith('/diet')) return 3;
    if (location.startsWith('/recipes')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/diary');
        break;
      case 1:
        context.go('/coach');
        break;
      case 2:
        context.go('/fasting');
        break;
      case 3:
        context.go('/diet');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);

    final isPro = ref.watch(subscriptionProvider).isPro;
    final offer = ref.watch(promoOfferProvider);
    final showOfferBadge = !isPro && offer.isActive;
    final bottomOffset =
        MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight + 36;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          widget.child,
          if (showOfferBadge)
            Positioned(
              right: 16,
              bottom: bottomOffset,
              child: PromoOfferBadge(
                onTap: () => context.push('/premium/offer'),
              ),
            ),
        ],
      ),
      bottomNavigationBar: NutrizBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) => _onItemTapped(index, context),
      ),
    );
  }
}
