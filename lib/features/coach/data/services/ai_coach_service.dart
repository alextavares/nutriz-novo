import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/network/worker_endpoints.dart';
import '../../../coach/domain/models/chat_message.dart';
import '../../../profile/domain/models/user_profile.dart';
import '../../domain/models/daily_diary_context.dart';

class CoachChatResponse {
  final String reply;
  final List<String> quickReplies;

  const CoachChatResponse({required this.reply, required this.quickReplies});
}

class AiCoachService {
  static const _chatPath = '/coach-chat';

  final Dio _dio = Dio(
    BaseOptions(
      // Cloudflare Worker + Gemini can take time on cold start / longer prompts.
      connectTimeout: const Duration(seconds: 35),
      sendTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 90),
    ),
  );

  /// Sends a user message along with the conversation [history] and the user's
  /// [profile] and [dailyContext] so the AI can give contextual answers.
  ///
  /// [history] should be all messages exchanged so far, EXCLUDING the current
  /// [message] (which is appended by the worker before calling Gemini).
  Future<CoachChatResponse> sendMessage({
    required String message,
    required UserProfile profile,
    DailyDiaryContext? dailyContext,
    List<ChatMessage> history = const [],
  }) async {
    // Trim history to last 20 turns to avoid bloating the request.
    final trimmedHistory = history.length > 20
        ? history.sublist(history.length - 20)
        : history;

    final response = await _dio.post(
      '${resolveWorkerBaseUrl()}$_chatPath',
      data: {
        'message': message,
        'profile': {
          'gender': profile.gender.name,
          'age': _age(profile.birthDate),
          'height_cm': profile.height,
          'current_weight_kg': profile.currentWeight,
          'target_weight_kg': profile.targetWeight,
          'calorie_target': profile.calculatedCalories,
          'protein_g': profile.proteinGrams,
          'carbs_g': profile.carbsGrams,
          'fat_g': profile.fatGrams,
          'main_goal': profile.mainGoal.name,
          'dietary_preference': profile.dietaryPreference.name,
        },
        if (dailyContext != null) 'dailyContext': dailyContext.toJson(),
        // Conversation history so the AI maintains context across turns.
        'history': trimmedHistory
            .map((m) => {'role': m.role.name, 'text': m.text})
            .toList(),
      },
      options: Options(
        responseType: ResponseType.plain,
        contentType: Headers.jsonContentType,
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao gerar resposta (${response.statusCode}).');
    }

    var body = response.data.toString();
    body = body.replaceAll('```json', '').replaceAll('```', '').trim();

    final json = jsonDecode(body) as Map<String, dynamic>;
    final reply = (json['reply'] as String?)?.trim();
    if (reply == null || reply.isEmpty) {
      throw Exception('Resposta vazia da IA.');
    }
    final quickReplies =
        (json['quickReplies'] as List?)
            ?.whereType<String>()
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList() ??
        const <String>[];

    return CoachChatResponse(reply: reply, quickReplies: quickReplies);
  }

  int _age(DateTime birthDate) {
    final now = DateTime.now();
    var years = now.year - birthDate.year;
    final birthdayThisYear = DateTime(now.year, birthDate.month, birthDate.day);
    if (birthdayThisYear.isAfter(now)) years -= 1;
    return years;
  }
}
