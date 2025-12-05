import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/ai_food_service.dart';
import '../notifiers/ai_food_notifier.dart';

final aiFoodServiceProvider = Provider<AiFoodService>((ref) {
  return AiFoodService();
});

final aiFoodNotifierProvider =
    StateNotifierProvider<AiFoodNotifier, AiFoodState>((ref) {
      final service = ref.watch(aiFoodServiceProvider);
      return AiFoodNotifier(service);
    });
