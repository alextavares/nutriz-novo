import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/fasting_stage.dart';
import '../../data/repositories/fasting_repository.dart';
import '../../../gamification/presentation/providers/gamification_providers.dart'; // For isarProvider

class FastingState {
  final bool isFasting;
  final DateTime? startTime;
  final Duration elapsed;
  final Duration goal;

  static const Object _unset = Object();

  const FastingState({
    this.isFasting = false,
    this.startTime,
    this.elapsed = Duration.zero,
    this.goal = const Duration(hours: 16),
  });

  FastingStage get currentStage => FastingStage.getStageForDuration(elapsed);

  FastingState copyWith({
    bool? isFasting,
    Object? startTime = _unset,
    Duration? elapsed,
    Duration? goal,
  }) {
    return FastingState(
      isFasting: isFasting ?? this.isFasting,
      startTime: startTime == _unset ? this.startTime : startTime as DateTime?,
      elapsed: elapsed ?? this.elapsed,
      goal: goal ?? this.goal,
    );
  }
}

class FastingNotifier extends StateNotifier<FastingState> {
  final FastingRepository _repository;
  Timer? _timer;

  FastingNotifier(this._repository) : super(const FastingState()) {
    _loadPersistedState();
  }

  Future<void> _loadPersistedState() async {
    final entity = await _repository.getState();
    if (entity != null && entity.isFasting && entity.startTime != null) {
      final now = DateTime.now();
      final elapsed = now.difference(entity.startTime!);
      state = FastingState(
        isFasting: true,
        startTime: entity.startTime,
        elapsed: elapsed,
        goal: Duration(milliseconds: entity.goalMilliseconds),
      );
      _startTimer();
    } else {
      // Clear inconsistent state just in case
      await _repository.clearState();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.startTime == null) return;
      final currentElapsed = DateTime.now().difference(state.startTime!);
      state = state.copyWith(elapsed: currentElapsed);
    });
  }

  Future<void> _persistState() async {
    await _repository.saveState(
      isFasting: state.isFasting,
      startTime: state.startTime,
      elapsed: state.elapsed,
      goal: state.goal,
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
    _persistState();
    _startTimer();
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
    _persistState();
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
    _persistState();
  }

  void updateGoal(Duration newGoal) {
    if (newGoal <= Duration.zero) return;
    state = state.copyWith(goal: newGoal);
    _persistState();
  }

  void stopFasting() {
    _timer?.cancel();
    state = state.copyWith(
      isFasting: false,
      elapsed: Duration.zero,
      startTime: null,
    );
    _repository.clearState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final fastingNotifierProvider =
    StateNotifierProvider<FastingNotifier, FastingState>((ref) {
      final isar = ref.watch(isarProvider);
      return FastingNotifier(FastingRepository(isar));
    });
