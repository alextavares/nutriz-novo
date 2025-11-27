import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FastingState {
  final bool isFasting;
  final DateTime? startTime;
  final Duration elapsed;
  final Duration goal;

  const FastingState({
    this.isFasting = false,
    this.startTime,
    this.elapsed = Duration.zero,
    this.goal = const Duration(hours: 16),
  });

  FastingState copyWith({
    bool? isFasting,
    DateTime? startTime,
    Duration? elapsed,
    Duration? goal,
  }) {
    return FastingState(
      isFasting: isFasting ?? this.isFasting,
      startTime: startTime ?? this.startTime,
      elapsed: elapsed ?? this.elapsed,
      goal: goal ?? this.goal,
    );
  }
}

class FastingNotifier extends StateNotifier<FastingState> {
  Timer? _timer;

  FastingNotifier() : super(const FastingState()) {
    // Auto-start for demo purposes if needed, or check local storage
    // For now, we start with a mock active fast
    startFasting(
      initialElapsed: const Duration(hours: 14, minutes: 25, seconds: 18),
    );
  }

  void startFasting({Duration? initialElapsed}) {
    if (state.isFasting) return;

    final now = DateTime.now();
    final start = now.subtract(initialElapsed ?? Duration.zero);

    state = state.copyWith(
      isFasting: true,
      startTime: start,
      elapsed: initialElapsed ?? Duration.zero,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final currentElapsed = DateTime.now().difference(state.startTime!);
      state = state.copyWith(elapsed: currentElapsed);
    });
  }

  void stopFasting() {
    _timer?.cancel();
    state = state.copyWith(
      isFasting: false,
      elapsed: Duration.zero,
      startTime: null,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final fastingNotifierProvider =
    StateNotifierProvider<FastingNotifier, FastingState>((ref) {
      return FastingNotifier();
    });
