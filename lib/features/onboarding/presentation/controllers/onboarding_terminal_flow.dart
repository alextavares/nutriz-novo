enum OnboardingTerminalPhase {
  collecting,
  calculating,
  calculationComplete,
  completionPersisting,
  completionPersisted,
  finalNavigationTriggered,
  finalNavigationDone,
}

class OnboardingTerminalFlow {
  OnboardingTerminalFlow({
    OnboardingTerminalPhase initialPhase = OnboardingTerminalPhase.collecting,
  }) : _phase = initialPhase;

  OnboardingTerminalPhase _phase;

  OnboardingTerminalPhase get phase => _phase;

  bool get calculationCompleteReached =>
      _phase.index >= OnboardingTerminalPhase.calculationComplete.index;

  bool get completionPersistedReached =>
      _phase.index >= OnboardingTerminalPhase.completionPersisted.index;

  bool canNavigateToStepIndex({
    required int targetIndex,
    required int resultsStepIndex,
  }) {
    if (!calculationCompleteReached) return true;
    return targetIndex >= resultsStepIndex;
  }

  bool transitionTo(OnboardingTerminalPhase next) {
    if (next.index < _phase.index) return false;
    if (next == _phase) return false;
    _phase = next;
    return true;
  }

  void reset() {
    _phase = OnboardingTerminalPhase.collecting;
  }
}
