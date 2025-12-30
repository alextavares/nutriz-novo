import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/debug/debug_flags.dart';
import 'bottom_nav_bar.dart';

/// MainScaffold with WidgetsBindingObserver to intercept the back button
/// at the platform level, before GoRouter processes it.
class MainScaffold extends StatefulWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold>
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

    // Debug print to verify this is being called
    if (DebugFlags.canVerbose) {
      debugPrint('DEBUG: didPopRoute called, currentIndex=$currentIndex');
    }

    // If we're NOT on the home/diary tab, navigate to diary instead of exiting
    if (currentIndex != 0) {
      context.go('/diary');
      return true; // We handled it, prevent default behavior (exit)
    }

    // If on diary, let the system handle it (exit app)
    return false;
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/diary')) return 0;
    if (location.startsWith('/fasting')) return 1;
    if (location.startsWith('/recipes')) return 2;
    if (location.startsWith('/profile')) return 3;
    if (location.startsWith('/premium')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/diary');
        break;
      case 1:
        context.go('/fasting');
        break;
      case 2:
        context.go('/recipes');
        break;
      case 3:
        context.go('/profile');
        break;
      case 4:
        context.go('/premium');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      extendBody: true,
      body: widget.child,
      bottomNavigationBar: NutrizBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) => _onItemTapped(index, context),
      ),
    );
  }
}
