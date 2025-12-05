import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'app.dart';
import 'features/diary/data/models/diary_schemas.dart';
import 'features/diary/data/models/water_intake_schema.dart';
import 'features/gamification/data/models/gamification_schemas.dart';
import 'features/gamification/presentation/providers/gamification_providers.dart';
import 'features/measurements/data/models/measurement_schemas.dart';
import 'features/profile/data/models/user_profile_schema.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await getApplicationDocumentsDirectory();

  final isar = await Isar.open([
    DiaryDaySchemaSchema,
    WaterIntakeSchemaSchema,
    UserLevelSchemaSchema,
    StreakSchemaSchema,
    AchievementSchemaSchema,
    UserPointsSchemaSchema,
    DailyChallengeSchemaSchema,
    MeasurementSchemaSchema,
    UserProfileEntitySchema,
  ], directory: dir.path);

  runApp(
    ProviderScope(
      overrides: [isarProvider.overrideWithValue(isar)],
      child: const NutrizApp(),
    ),
  );
}
