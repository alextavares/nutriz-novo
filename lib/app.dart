import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/analytics/analytics_providers.dart';
import 'core/theme/app_theme.dart';
import 'features/premium/presentation/providers/subscription_provider.dart';
import 'routing/app_router.dart';

class NutrizApp extends ConsumerStatefulWidget {
  const NutrizApp({super.key});

  @override
  ConsumerState<NutrizApp> createState() => _NutrizAppState();
}

class _NutrizAppState extends ConsumerState<NutrizApp> {
  bool _loggedOpen = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(revenueCatInitializerProvider.future);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loggedOpen) return;
    _loggedOpen = true;
    final analytics = ref.read(analyticsServiceProvider);
    analytics.markAppOpen();
    analytics.logEvent('app_open');
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Nutriz',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
