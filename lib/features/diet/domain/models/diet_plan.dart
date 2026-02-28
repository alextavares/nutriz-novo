import 'diet_meal.dart';

class DietPlanDay {
  final DateTime date;
  final Map<DietMealType, String> mealIdsByType;
  final Set<DietMealType> lockedTypes;

  const DietPlanDay({
    required this.date,
    required this.mealIdsByType,
    this.lockedTypes = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'date': DateTime(date.year, date.month, date.day).toIso8601String(),
      'meals': mealIdsByType.map((k, v) => MapEntry(k.name, v)),
      if (lockedTypes.isNotEmpty)
        'locked': lockedTypes.map((t) => t.name).toList(growable: false),
    };
  }

  static DietPlanDay fromJson(Map<String, dynamic> json) {
    final date = DateTime.parse(json['date'] as String);
    final meals = (json['meals'] as Map).cast<String, dynamic>();
    final map = <DietMealType, String>{};
    for (final entry in meals.entries) {
      map[dietMealTypeFromString(entry.key)] = entry.value as String;
    }

    final lockedRaw = json['locked'];
    final locked = <DietMealType>{};
    if (lockedRaw is List) {
      for (final raw in lockedRaw.whereType<String>()) {
        try {
          locked.add(dietMealTypeFromString(raw));
        } catch (_) {
          // ignore unknown
        }
      }
    }

    return DietPlanDay(
      date: DateTime(date.year, date.month, date.day),
      mealIdsByType: map,
      lockedTypes: locked,
    );
  }
}

class DietPlanWeek {
  final DateTime weekStart; // normalized date-only (Sunday)
  final List<DietPlanDay> days; // 7 days

  const DietPlanWeek({required this.weekStart, required this.days});

  Map<String, dynamic> toJson() {
    return {
      'weekStart': DateTime(weekStart.year, weekStart.month, weekStart.day).toIso8601String(),
      'days': days.map((d) => d.toJson()).toList(growable: false),
    };
  }

  static DietPlanWeek fromJson(Map<String, dynamic> json) {
    final ws = DateTime.parse(json['weekStart'] as String);
    final daysRaw = (json['days'] as List).whereType<Map>().cast<Map<String, dynamic>>();
    return DietPlanWeek(
      weekStart: DateTime(ws.year, ws.month, ws.day),
      days: daysRaw.map(DietPlanDay.fromJson).toList(growable: false),
    );
  }
}
