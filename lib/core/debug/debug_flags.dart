import 'package:flutter/foundation.dart';

/// Flags de debug controladas por `--dart-define`.
///
/// Exemplo:
/// `flutter run --dart-define=NUTRIZ_DEBUG_LOGS=true`
class DebugFlags {
  static const bool logsEnabled = bool.fromEnvironment(
    'NUTRIZ_DEBUG_LOGS',
    defaultValue: false,
  );

  static const bool verboseEnabled = bool.fromEnvironment(
    'NUTRIZ_DEBUG_VERBOSE',
    defaultValue: false,
  );

  static const bool analyticsConsoleEnabled = bool.fromEnvironment(
    'NUTRIZ_DEBUG_ANALYTICS_CONSOLE',
    defaultValue: false,
  );

  static bool get canLog => kDebugMode && logsEnabled;
  static bool get canVerbose => canLog && verboseEnabled;
}
