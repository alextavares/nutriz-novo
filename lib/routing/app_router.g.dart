// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appRouterHash() => r'99c5bf71027f759801ca70ab5d2c55af0169a576';

/// See also [appRouter].
@ProviderFor(appRouter)
final appRouterProvider = AutoDisposeProvider<GoRouter>.internal(
  appRouter,
  name: r'appRouterProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appRouterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AppRouterRef = AutoDisposeProviderRef<GoRouter>;
String _$onboardingStatusHash() => r'ffd4b810a92b1308e2010f513afb20590f4115e3';

/// Provider to track if onboarding has been completed
///
/// Copied from [OnboardingStatus].
@ProviderFor(OnboardingStatus)
final onboardingStatusProvider =
    AutoDisposeAsyncNotifierProvider<OnboardingStatus, bool>.internal(
  OnboardingStatus.new,
  name: r'onboardingStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$onboardingStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$OnboardingStatus = AutoDisposeAsyncNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
