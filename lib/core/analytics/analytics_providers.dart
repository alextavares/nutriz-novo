import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'analytics_service.dart';

final analyticsFilePathProvider = Provider<String>((ref) {
  return 'analytics_events.jsonl';
});

final firebaseAnalyticsProvider = Provider<FirebaseAnalytics?>((ref) {
  return null;
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final path = ref.watch(analyticsFilePathProvider);
  final firebaseAnalytics = ref.watch(firebaseAnalyticsProvider);
  return AnalyticsService(filePath: path, firebaseAnalytics: firebaseAnalytics);
});
