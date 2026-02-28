import 'dart:convert';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';

import '../debug/debug_flags.dart';

class AnalyticsService {
  final String filePath;
  final bool enabled;
  final FirebaseAnalytics? firebaseAnalytics;
  Future<void> _writeChain = Future.value();
  DateTime? _appOpenAt;
  bool _loggedTimeToFirstMeal = false;

  AnalyticsService({
    required this.filePath,
    this.enabled = true,
    this.firebaseAnalytics,
  });

  void markAppOpen([DateTime? at]) {
    _appOpenAt = at ?? DateTime.now();
    _loggedTimeToFirstMeal = false;
  }

  Future<void> logTimeToFirstMealIfNeeded({String? mealType}) async {
    if (_loggedTimeToFirstMeal) return;
    final start = _appOpenAt;
    if (start == null) return;
    _loggedTimeToFirstMeal = true;

    final minutes = DateTime.now().difference(start).inMinutes;
    await logEvent('time_to_first_meal_minutes', {
      'minutes': minutes,
      if (mealType != null) 'meal_type': mealType,
    });
  }

  Map<String, Object?> _defaults() {
    return {
      'platform': Platform.operatingSystem,
      'app_version': const String.fromEnvironment(
        'APP_VERSION',
        defaultValue: 'unknown',
      ),
      'locale': Platform.localeName,
      'timezone': DateTime.now().timeZoneName,
    };
  }

  String _sanitizeEventName(String raw) {
    var out = raw.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    out = out.replaceAll(RegExp(r'_+'), '_');
    if (out.isEmpty) out = 'event';
    if (!RegExp(r'^[a-z]').hasMatch(out)) {
      out = 'e_$out';
    }
    if (out.length > 40) {
      out = out.substring(0, 40);
    }
    return out;
  }

  String _sanitizeParamName(String raw) {
    var out = raw.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    out = out.replaceAll(RegExp(r'_+'), '_');
    if (out.isEmpty) out = 'param';
    if (!RegExp(r'^[a-z]').hasMatch(out)) {
      out = 'p_$out';
    }
    if (out.length > 40) {
      out = out.substring(0, 40);
    }
    return out;
  }

  String _truncate(String input, int max) {
    if (input.length <= max) return input;
    return input.substring(0, max);
  }

  Object? _sanitizeParamValue(Object? value) {
    if (value == null) return null;
    if (value is String) return _truncate(value, 100);
    if (value is int) return value;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is bool) return value ? 1 : 0;
    if (value is DateTime) return _truncate(value.toIso8601String(), 100);
    if (value is Enum) return _truncate(value.name, 100);
    if (value is List || value is Map) {
      return _truncate(jsonEncode(value), 100);
    }
    return _truncate(value.toString(), 100);
  }

  Future<void> _logFirebase(
    String eventName,
    Map<String, Object?> props,
  ) async {
    final analytics = firebaseAnalytics;
    if (analytics == null) return;

    final merged = <String, Object?>{..._defaults(), ...props};
    final params = <String, Object>{};
    var index = 0;
    for (final entry in merged.entries) {
      if (index >= 25) break;
      final key = _sanitizeParamName(entry.key);
      if (params.containsKey(key)) continue;
      final value = _sanitizeParamValue(entry.value);
      if (value == null) continue;
      params[key] = value;
      index++;
    }

    final safeName = _sanitizeEventName(eventName);
    try {
      await analytics.logEvent(name: safeName, parameters: params);
      if (DebugFlags.canVerbose && DebugFlags.analyticsConsoleEnabled) {
        // ignore: avoid_print
        print('ANALYTICS_FIREBASE $safeName $params');
      }
    } catch (e) {
      if (DebugFlags.canVerbose && DebugFlags.analyticsConsoleEnabled) {
        // ignore: avoid_print
        print('ANALYTICS_FIREBASE_FAIL $safeName $e');
      }
    }
  }

  Future<void> logEvent(String name, [Map<String, Object?> props = const {}]) {
    if (!enabled) return Future.value();

    final now = DateTime.now();
    final payload = <String, Object?>{
      'ts': now.toIso8601String(),
      'name': name,
      ..._defaults(),
      ...props,
    };

    if (DebugFlags.canVerbose && DebugFlags.analyticsConsoleEnabled) {
      // ignore: avoid_print
      print('ANALYTICS $name $props');
    }

    _writeChain = _writeChain
        .then((_) async {
          final file = File(filePath);
          await file.parent.create(recursive: true);
          await file.writeAsString(
            '${jsonEncode(payload)}\n',
            mode: FileMode.append,
          );
        })
        .catchError((_) {});

    return Future.wait<void>([_writeChain, _logFirebase(name, props)]);
  }
}
