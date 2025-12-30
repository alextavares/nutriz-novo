import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'app.dart';
import 'core/analytics/analytics_providers.dart';
import 'features/diary/data/models/diary_schemas.dart';
import 'features/diary/data/models/water_intake_schema.dart';
import 'features/gamification/data/models/gamification_schemas.dart';
import 'features/gamification/presentation/providers/gamification_providers.dart';
import 'features/measurements/data/models/measurement_schemas.dart';
import 'features/profile/data/models/user_profile_schema.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  ];

  late final Isar isar;
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

  final analyticsPath = '${dir.path}/analytics_events.jsonl';

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
        analyticsFilePathProvider.overrideWithValue(analyticsPath),
      ],
      child: const NutrizApp(),
    ),
  );
}
