import 'dart:convert';
import 'dart:io';

import '../debug/debug_flags.dart';

class AnalyticsService {
  final String filePath;
  final bool enabled;
  Future<void> _writeChain = Future.value();
  DateTime? _appOpenAt;
  bool _loggedTimeToFirstMeal = false;

  AnalyticsService({required this.filePath, this.enabled = true});

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

    _writeChain = _writeChain.then((_) async {
      final file = File(filePath);
      await file.parent.create(recursive: true);
      await file.writeAsString('${jsonEncode(payload)}\n', mode: FileMode.append);
    }).catchError((_) {});

    return _writeChain;
  }
}
