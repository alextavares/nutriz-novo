import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/fasting_stage.dart';

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

  FastingStage get currentStage => FastingStage.getStageForDuration(elapsed);

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

  void updateStartTime(DateTime newStart) {
    if (!state.isFasting) return;

    final now = DateTime.now();
    // Prevent future start times
    if (newStart.isAfter(now)) {
      // In a real app, we might want to return a result or throw to notify UI
      // For now, we just clamp to now
      newStart = now;
    }

    final newElapsed = now.difference(newStart);
    state = state.copyWith(startTime: newStart, elapsed: newElapsed);
  }

  void updateEndTime(DateTime newEnd) {
    if (!state.isFasting || state.startTime == null) return;

    // Ensure end time is after start time
    if (newEnd.isBefore(state.startTime!)) {
      // In a real app, show error. For now, ignore or clamp.
      return;
    }

    final newGoal = newEnd.difference(state.startTime!);
    state = state.copyWith(goal: newGoal);
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
