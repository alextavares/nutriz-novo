import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../profile/domain/models/user_profile.dart';
import '../../data/services/ai_coach_service.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/daily_diary_context.dart';

// Key used to persist the free message counter across app restarts.
const _kFreeMessagesKey = 'coach_free_messages_remaining';
const _kDefaultFreeMessages = 3;

class CoachChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final List<String> quickReplies;
  final int freeMessagesRemaining;

  const CoachChatState({
    required this.messages,
    required this.isLoading,
    required this.quickReplies,
    required this.freeMessagesRemaining,
  });

  CoachChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    List<String>? quickReplies,
    int? freeMessagesRemaining,
  }) {
    return CoachChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      quickReplies: quickReplies ?? this.quickReplies,
      freeMessagesRemaining:
          freeMessagesRemaining ?? this.freeMessagesRemaining,
    );
  }
}

final _aiCoachServiceProvider = Provider<AiCoachService>((ref) {
  return AiCoachService();
});

final coachChatProvider =
    StateNotifierProvider<CoachChatNotifier, CoachChatState>((ref) {
      return CoachChatNotifier(ref);
    });

class CoachChatNotifier extends StateNotifier<CoachChatState> {
  CoachChatNotifier(this._ref)
    : super(
        const CoachChatState(
          messages: [],
          isLoading: false,
          quickReplies: [
            'Como melhorar minha alimentação hoje?',
            'Que alimentos têm mais proteína?',
          ],
          freeMessagesRemaining: _kDefaultFreeMessages,
        ),
      ) {
    _init();
  }

  final Ref _ref;

  /// Load persisted free-message count and show the welcome message.
  Future<void> _init() async {
    // Welcome message
    final welcome = ChatMessage(
      role: ChatRole.assistant,
      createdAt: DateTime.now(),
      text:
          'Oi! Eu sou seu assistente nutricional.\n\n'
          'Posso te ajudar com dúvidas sobre alimentação e hábitos saudáveis. '
          'Se você tiver alguma condição médica, confirme decisões importantes com um profissional de saúde.',
    );

    // Load persisted counter
    final prefs = await SharedPreferences.getInstance();
    final remaining = prefs.getInt(_kFreeMessagesKey) ?? _kDefaultFreeMessages;

    state = state.copyWith(
      messages: [welcome],
      freeMessagesRemaining: remaining,
    );
  }

  Future<void> sendText({
    required String text,
    required UserProfile profile,
    required bool isPro,
    DailyDiaryContext? dailyContext,
  }) async {
    if (state.isLoading) return;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final userMsg = ChatMessage(
      role: ChatRole.user,
      text: trimmed,
      createdAt: DateTime.now(),
    );

    // History BEFORE the current message (the worker appends the current one).
    final historySnapshot = List<ChatMessage>.from(state.messages);

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
    );

    try {
      final res = await _ref
          .read(_aiCoachServiceProvider)
          .sendMessage(
            message: trimmed,
            profile: profile,
            dailyContext: dailyContext,
            history: historySnapshot,
          );

      final nextFree = isPro
          ? state.freeMessagesRemaining
          : (state.freeMessagesRemaining > 0
                ? state.freeMessagesRemaining - 1
                : 0);

      // Persist updated count
      if (!isPro) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_kFreeMessagesKey, nextFree);
      }

      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(
            role: ChatRole.assistant,
            text: res.reply,
            createdAt: DateTime.now(),
          ),
        ],
        quickReplies: res.quickReplies.isNotEmpty
            ? res.quickReplies
            : state.quickReplies,
        isLoading: false,
        freeMessagesRemaining: nextFree,
      );
    } catch (e) {
      final suffix = kDebugMode ? '\n\nDetalhe: ${e.runtimeType}' : '';
      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(
            role: ChatRole.assistant,
            createdAt: DateTime.now(),
            text: 'Não consegui responder agora. Tente novamente.$suffix',
          ),
        ],
        isLoading: false,
      );
    }
  }

  void addLocalAssistantMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(
          role: ChatRole.assistant,
          text: trimmed,
          createdAt: DateTime.now(),
        ),
      ],
    );
  }

  void addLocalUserMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(
          role: ChatRole.user,
          text: trimmed,
          createdAt: DateTime.now(),
        ),
      ],
    );
  }

  /// Sets two suggested quick replies at once (avoids double rebuild).
  void setQuickDrafts(List<String> texts) {
    final current = state.quickReplies.toSet();
    final merged = [
      ...texts,
      ...state.quickReplies.where((e) => !texts.contains(e)),
    ];
    if (merged.toSet().difference(current).isEmpty) return;
    state = state.copyWith(quickReplies: merged);
  }

  /// Resets the persisted free-message counter (e.g. after pro subscription).
  Future<void> resetFreeMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kFreeMessagesKey);
    state = state.copyWith(freeMessagesRemaining: _kDefaultFreeMessages);
  }
}
