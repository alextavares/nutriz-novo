import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/network/worker_endpoints.dart';
import '../../../profile/domain/models/user_profile.dart';
import '../../domain/models/diet_meal.dart';

class DietReplaceResult {
  final Map<DietMealType, String> mealIdsByType;

  const DietReplaceResult({required this.mealIdsByType});
}

class AiDietService {
  static const _replaceDayPath = '/diet-replace-day';
  static const _replaceMealPath = '/diet-replace-meal';

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 35),
      sendTimeout: const Duration(seconds: 40),
      receiveTimeout: const Duration(seconds: 90),
    ),
  );

  Future<DietReplaceResult> replaceDay({
    required UserProfile profile,
    required DateTime day,
    required List<DietMeal> catalog,
    Map<DietMealType, String>? currentDayMealIds,
    Set<DietMealType>? lockedTypes,
  }) async {
    final response = await _dio.post(
      '${resolveWorkerBaseUrl()}$_replaceDayPath',
      data: {
        'day': DateTime(day.year, day.month, day.day).toIso8601String(),
        'profile': {
          'calorie_target': profile.calculatedCalories,
          'protein_g': profile.proteinGrams,
          'carbs_g': profile.carbsGrams,
          'fat_g': profile.fatGrams,
          'dietary_preference': profile.dietaryPreference.name,
          'main_goal': profile.mainGoal.name,
        },
        'catalog': catalog
            .map(
              (m) => {
                'id': m.id,
                'mealType': m.mealType.name,
                'title': m.title,
                'kcal': m.kcal,
                'protein_g': m.proteinG,
                'carbs_g': m.carbsG,
                'fat_g': m.fatG,
              },
            )
            .toList(growable: false),
        if (currentDayMealIds != null)
          'current': currentDayMealIds.map((k, v) => MapEntry(k.name, v)),
        if (lockedTypes != null && lockedTypes.isNotEmpty)
          'locked': lockedTypes.map((t) => t.name).toList(growable: false),
      },
      options: Options(
        responseType: ResponseType.plain,
        contentType: Headers.jsonContentType,
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao gerar troca (${response.statusCode}).');
    }

    var body = response.data.toString();
    body = body.replaceAll('```json', '').replaceAll('```', '').trim();

    final json = jsonDecode(body) as Map<String, dynamic>;
    final rawMeals = (json['meals'] as Map?)?.cast<String, dynamic>();
    if (rawMeals == null) {
      throw Exception('Resposta inválida do Worker (missing meals).');
    }

    final map = <DietMealType, String>{};
    for (final entry in rawMeals.entries) {
      map[dietMealTypeFromString(entry.key)] = entry.value as String;
    }

    for (final type in DietMealType.values) {
      if (!map.containsKey(type) || map[type]!.trim().isEmpty) {
        throw Exception('Resposta inválida (missing ${type.name}).');
      }
    }

    return DietReplaceResult(mealIdsByType: map);
  }

  Future<String> replaceMeal({
    required UserProfile profile,
    required DateTime day,
    required DietMealType mealType,
    required List<DietMeal> catalog,
    required Map<DietMealType, String> currentDayMealIds,
    List<String>? weekUsedSameTypeMealIds,
    List<String>? dayOtherMealIds,
    Map<String, int>? remaining,
    List<String>? hints,
  }) async {
    final response = await _dio.post(
      '${resolveWorkerBaseUrl()}$_replaceMealPath',
      data: {
        'day': DateTime(day.year, day.month, day.day).toIso8601String(),
        'mealType': mealType.name,
        'profile': {
          'calorie_target': profile.calculatedCalories,
          'protein_g': profile.proteinGrams,
          'carbs_g': profile.carbsGrams,
          'fat_g': profile.fatGrams,
          'dietary_preference': profile.dietaryPreference.name,
          'main_goal': profile.mainGoal.name,
        },
        'catalog': catalog
            .map(
              (m) => {
                'id': m.id,
                'mealType': m.mealType.name,
                'title': m.title,
                'kcal': m.kcal,
                'protein_g': m.proteinG,
                'carbs_g': m.carbsG,
                'fat_g': m.fatG,
                'ingredients': m.ingredients.take(8).toList(growable: false),
              },
            )
            .toList(growable: false),
        'current': currentDayMealIds.map((k, v) => MapEntry(k.name, v)),
        if (weekUsedSameTypeMealIds != null) 'weekUsedSameType': weekUsedSameTypeMealIds,
        if (dayOtherMealIds != null) 'dayOtherMealIds': dayOtherMealIds,
        if (remaining != null) 'remaining': remaining,
        if (hints != null) 'hints': hints,
      },
      options: Options(
        responseType: ResponseType.plain,
        contentType: Headers.jsonContentType,
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao trocar refeição (${response.statusCode}).');
    }

    var body = response.data.toString();
    body = body.replaceAll('```json', '').replaceAll('```', '').trim();

    final json = jsonDecode(body) as Map<String, dynamic>;
    final mealId = (json['mealId'] as String?)?.trim();
    if (mealId == null || mealId.isEmpty) {
      throw Exception('Resposta inválida do Worker (missing mealId).');
    }

    final byId = {for (final m in catalog) m.id: m};
    final picked = byId[mealId];
    if (picked == null) {
      throw Exception('Resposta inválida (id fora do catálogo).');
    }
    if (picked.mealType != mealType) {
      throw Exception('Resposta inválida (mealType incorreto).');
    }

    return mealId;
  }
}
