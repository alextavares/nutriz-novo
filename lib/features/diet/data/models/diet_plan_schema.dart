import 'dart:convert';

import 'package:isar/isar.dart';

import '../../domain/models/diet_plan.dart';

part 'diet_plan_schema.g.dart';

@collection
class DietPlanWeekEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late DateTime weekStart;

  late String planJson;

  late DateTime updatedAt;

  DietPlanWeek toDomain() {
    final map = jsonDecode(planJson) as Map<String, dynamic>;
    return DietPlanWeek.fromJson(map);
  }

  static DietPlanWeekEntity fromDomain(DietPlanWeek plan) {
    return DietPlanWeekEntity()
      ..weekStart = DateTime(plan.weekStart.year, plan.weekStart.month, plan.weekStart.day)
      ..planJson = jsonEncode(plan.toJson())
      ..updatedAt = DateTime.now();
  }
}

