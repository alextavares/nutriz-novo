import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'analytics_service.dart';

final analyticsFilePathProvider = Provider<String>((ref) {
  return 'analytics_events.jsonl';
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final path = ref.watch(analyticsFilePathProvider);
  return AnalyticsService(filePath: path);
});

