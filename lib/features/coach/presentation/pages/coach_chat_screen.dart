import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/monetization/promo_offer.dart';
import '../../../diary/data/services/ai_food_service.dart';
import '../../../diary/domain/entities/meal.dart';
import '../../../diary/presentation/providers/diary_providers.dart';
import '../../../premium/presentation/providers/subscription_provider.dart';
import '../../../profile/presentation/notifiers/profile_notifier.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/daily_diary_context.dart';
import '../notifiers/coach_chat_notifier.dart';

class CoachChatScreen extends ConsumerStatefulWidget {
  const CoachChatScreen({super.key});

  @override
  ConsumerState<CoachChatScreen> createState() => _CoachChatScreenState();
}

class _CoachChatScreenState extends ConsumerState<CoachChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _picker = ImagePicker();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _scrollToBottomPostFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollToBottom();
    });
  }

  Future<void> _ensureCanUseChatOrPaywall() async {
    final isPro = ref.read(subscriptionProvider).isPro;
    final freeRemaining = ref.read(coachChatProvider).freeMessagesRemaining;
    if (isPro) return;
    if (freeRemaining > 0) return;

    ref
        .read(promoOfferProvider.notifier)
        .ensureActive(
          duration: const Duration(minutes: 10),
          discountPercent: 75,
          source: 'coach_chat_paywall',
        );
    if (!mounted) return;
    await context.push('/premium');
  }

  /// Builds a DailyDiaryContext from the current diary state.
  DailyDiaryContext _buildDailyContext() {
    final diaryState = ref.read(diaryNotifierProvider);
    final profile = ref.read(profileNotifierProvider);
    final diaryDay = diaryState.diaryDay.asData?.value;

    if (diaryDay == null) {
      return DailyDiaryContext.empty(calorieGoal: profile.calculatedCalories);
    }

    final macros = diaryDay.totalMacros;
    final foodNames = diaryDay.meals
        .expand((meal) => meal.foods.map((item) => item.food.name))
        .toList();

    return DailyDiaryContext(
      totalCalories: diaryDay.totalCalories.value.round(),
      calorieGoal: profile.calculatedCalories,
      proteinGrams: macros.protein.round(),
      carbsGrams: macros.carbs.round(),
      fatGrams: macros.fat.round(),
      foodsLogged: foodNames,
      hasBreakfast: diaryDay.getMealsByType(MealType.breakfast).isNotEmpty,
      hasLunch: diaryDay.getMealsByType(MealType.lunch).isNotEmpty,
      hasDinner: diaryDay.getMealsByType(MealType.dinner).isNotEmpty,
      hasSnacks: diaryDay.getMealsByType(MealType.snack).isNotEmpty,
      waterMl: diaryDay.waterIntake.valueMl.round(),
    );
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final isPro = ref.read(subscriptionProvider).isPro;
    final freeRemaining = ref.read(coachChatProvider).freeMessagesRemaining;
    if (!isPro && freeRemaining <= 0) {
      await _ensureCanUseChatOrPaywall();
      return;
    }

    _controller.clear();
    _scrollToBottomPostFrame();

    final dailyContext = _buildDailyContext();

    await ref
        .read(coachChatProvider.notifier)
        .sendText(
          text: text,
          profile: ref.read(profileNotifierProvider),
          isPro: isPro,
          dailyContext: dailyContext,
        );

    _scrollToBottomPostFrame();
  }

  Future<void> _pickAndAnalyze(ImageSource source) async {
    final isPro = ref.read(subscriptionProvider).isPro;
    if (!isPro) {
      await _ensureCanUseChatOrPaywall();
      return;
    }

    final xfile = await _picker.pickImage(source: source, imageQuality: 85);
    if (xfile == null) return;

    final notifier = ref.read(coachChatProvider.notifier);

    try {
      notifier.addLocalUserMessage('📷 [Imagem enviada pelo usuário]');
      _scrollToBottomPostFrame();

      final food = await AiFoodService().analyzeFoodImage(xfile);

      final msg =
          'Pela foto, identifiquei **${food.name}**.\n\n'
          'Estimativa para ${food.servingSize.toStringAsFixed(0)}${food.servingUnit}:\n'
          '• **Calorias:** ${food.calories.value.toInt()} kcal\n'
          '• **Proteína:** ${food.macros.protein.toStringAsFixed(0)}g\n'
          '• **Carboidratos:** ${food.macros.carbs.toStringAsFixed(0)}g\n'
          '• **Gordura:** ${food.macros.fat.toStringAsFixed(0)}g';

      notifier.addLocalAssistantMessage(msg);

      notifier.setQuickDrafts([
        'Como posso incluir ${food.name} na minha meta de hoje?',
        'Esta é uma opção saudável para o meu objetivo?',
      ]);

      _scrollToBottomPostFrame();
    } catch (e) {
      notifier.addLocalAssistantMessage(
        'Não consegui analisar a foto. Tente novamente.',
      );
      _scrollToBottomPostFrame();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(coachChatProvider);
    final isPro = ref.watch(subscriptionProvider).isPro;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 220),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final msg =
                            state.messages[state.messages.length - 1 - index];
                        return _ChatBubble(message: msg);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _Composer(
                isLoading: state.isLoading,
                isPro: isPro,
                freeRemaining: state.freeMessagesRemaining,
                controller: _controller,
                quickReplies: state.quickReplies,
                onQuickReplyTap: (text) {
                  _controller.text = text;
                  _controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: _controller.text.length),
                  );
                },
                onSend: _send,
                onCamera: () => _pickAndAnalyze(ImageSource.camera),
                onGallery: () => _pickAndAnalyze(ImageSource.gallery),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isAssistant = message.role == ChatRole.assistant;
    final alignment = isAssistant
        ? Alignment.centerLeft
        : Alignment.centerRight;
    final bg = isAssistant ? AppColors.primary : const Color(0xFFEFF2F5);
    final fg = isAssistant ? Colors.white : AppColors.textPrimary;

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: isAssistant
            ? MarkdownBody(
                data: message.text,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    color: fg,
                    height: 1.35,
                    fontWeight: FontWeight.normal,
                  ),
                  strong: TextStyle(
                    color: fg,
                    height: 1.35,
                    fontWeight: FontWeight.bold,
                  ),
                  listBullet: TextStyle(color: fg),
                ),
              )
            : Text(
                message.text,
                style: TextStyle(
                  color: fg,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final bool isLoading;
  final bool isPro;
  final int freeRemaining;
  final TextEditingController controller;
  final List<String> quickReplies;
  final ValueChanged<String> onQuickReplyTap;
  final VoidCallback onSend;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  const _Composer({
    required this.isLoading,
    required this.isPro,
    required this.freeRemaining,
    required this.controller,
    required this.quickReplies,
    required this.onQuickReplyTap,
    required this.onSend,
    required this.onCamera,
    required this.onGallery,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(12, 10, 12, 10 + bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (quickReplies.isNotEmpty)
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: quickReplies.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final text = quickReplies[index];
                  return ActionChip(
                    onPressed: () => onQuickReplyTap(text),
                    label: Text(
                      text,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    backgroundColor: const Color(0xFFF3F6FA),
                    side: BorderSide(
                      color: Colors.black.withValues(alpha: 0.08),
                    ),
                  );
                },
              ),
            ),
          if (quickReplies.isNotEmpty) const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  decoration: InputDecoration(
                    hintText: 'Pergunte qualquer coisa',
                    filled: true,
                    fillColor: const Color(0xFFF4F6F8),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Câmera',
                          onPressed: isLoading ? null : onCamera,
                          icon: const Icon(Icons.photo_camera_outlined),
                        ),
                        IconButton(
                          tooltip: 'Galeria',
                          onPressed: isLoading ? null : onGallery,
                          icon: const Icon(Icons.image_outlined),
                        ),
                      ],
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 52,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : onSend,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded),
                ),
              ),
            ],
          ),
          if (!isPro)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                freeRemaining > 0
                    ? 'Você tem $freeRemaining mensagem grátis nesta sessão.'
                    : 'Desbloqueie o chat PRO para continuar.',
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
