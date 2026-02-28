import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'app.dart';
import 'core/analytics/analytics_providers.dart';
import 'core/debug/debug_flags.dart';
import 'features/diary/data/models/diary_schemas.dart';
import 'features/diary/data/models/water_intake_schema.dart';
import 'features/gamification/data/models/gamification_schemas.dart';
import 'features/gamification/presentation/providers/gamification_providers.dart';
import 'features/measurements/data/models/measurement_schemas.dart';
import 'features/profile/data/models/user_profile_schema.dart';
import 'features/diet/data/models/diet_plan_schema.dart';
import 'features/fasting/data/repositories/fasting_repository.dart';
import 'features/diary/data/models/custom_food_schema.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  FirebaseAnalytics? firebaseAnalytics;
  try {
    await Firebase.initializeApp();
    firebaseAnalytics = FirebaseAnalytics.instance;
    if (DebugFlags.canVerbose && DebugFlags.analyticsConsoleEnabled) {
      // ignore: avoid_print
      print('ANALYTICS Firebase initialized');
    }
  } catch (e) {
    if (DebugFlags.canVerbose && DebugFlags.analyticsConsoleEnabled) {
      // ignore: avoid_print
      print('ANALYTICS Firebase unavailable, fallback local only: $e');
    }
  }

  final dir = await getApplicationDocumentsDirectory();

  final schemas = [
    DiaryDaySchemaSchema,
    WaterIntakeSchemaSchema,
    UserLevelSchemaSchema,
    StreakSchemaSchema,
    AchievementSchemaSchema,
    UserPointsSchemaSchema,
    DailyChallengeSchemaSchema,
    MeasurementSchemaSchema,
    UserProfileEntitySchema,
    DietPlanWeekEntitySchema,
    FastingStateEntitySchema,
    CustomFoodSchemaSchema,
  ];

  late final Isar isar;
  // Hot restart keeps the native Android process alive, so an Isar instance may
  // already be open. Reuse it to avoid noisy "already open"/initialization
  // errors during development.
  final existingIsar = Isar.getInstance();
  if (existingIsar != null) {
    isar = existingIsar;
  } else {
    try {
      isar = await Isar.open(schemas, directory: dir.path);
    } catch (_) {
      // Isar doesn't support migrations; schema changes can prevent opening an
      // existing database. In beta, prefer a clean start over crashing on boot.
      try {
        final folder = Directory(dir.path);
        if (await folder.exists()) {
          await for (final entity in folder.list()) {
            final name = entity.uri.pathSegments.isEmpty
                ? ''
                : entity.uri.pathSegments.last;
            if (name.startsWith('${Isar.defaultName}.isar')) {
              try {
                await entity.delete(recursive: true);
              } catch (_) {}
            }
          }
        }
      } catch (_) {}
      isar = await Isar.open(schemas, directory: dir.path);
    }
  }

  final analyticsPath = '${dir.path}/analytics_events.jsonl';

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
        analyticsFilePathProvider.overrideWithValue(analyticsPath),
        firebaseAnalyticsProvider.overrideWithValue(firebaseAnalytics),
      ],
      child: const NutrizApp(),
    ),
  );
}
