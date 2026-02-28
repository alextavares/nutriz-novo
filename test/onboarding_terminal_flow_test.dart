import 'package:flutter_test/flutter_test.dart';
import 'package:nutriz/features/onboarding/presentation/controllers/onboarding_terminal_flow.dart';

void main() {
  bool runTerminalCycle({
    required bool withDetails,
    required int cycle,
  }) {
    final flow = OnboardingTerminalFlow();
    const resultsIndex = 25;

    // Before calculation completes, moving around pre-results is allowed.
    if (!flow.canNavigateToStepIndex(targetIndex: 10, resultsStepIndex: resultsIndex)) {
      return false;
    }

    final transitions = <OnboardingTerminalPhase>[
      OnboardingTerminalPhase.calculating,
      OnboardingTerminalPhase.calculationComplete,
      if (withDetails) OnboardingTerminalPhase.completionPersisting,
      if (withDetails) OnboardingTerminalPhase.completionPersisted,
      if (!withDetails) OnboardingTerminalPhase.completionPersisting,
      if (!withDetails) OnboardingTerminalPhase.completionPersisted,
      OnboardingTerminalPhase.finalNavigationTriggered,
      OnboardingTerminalPhase.finalNavigationDone,
    ];

    for (final transition in transitions) {
      flow.transitionTo(transition);
    }

    final blockedRegression = !flow.canNavigateToStepIndex(
      targetIndex: 8,
      resultsStepIndex: resultsIndex,
    );
    final canStayPostCalculation = flow.canNavigateToStepIndex(
      targetIndex: 27,
      resultsStepIndex: resultsIndex,
    );

    final passed =
        blockedRegression &&
        canStayPostCalculation &&
        flow.phase == OnboardingTerminalPhase.finalNavigationDone;

    // ignore: avoid_print
    print(
      'ONBOARDING_CYCLE cycle=$cycle mode=${withDetails ? 'with_details' : 'no_details'} result=${passed ? 'PASS' : 'FAIL'}',
    );
    return passed;
  }

  test('10 ciclos do fluxo terminal sem regressão (5 sem detalhes + 5 com detalhes)', () {
    final cycleResults = <bool>[];

    for (var i = 1; i <= 5; i++) {
      cycleResults.add(runTerminalCycle(withDetails: false, cycle: i));
    }
    for (var i = 6; i <= 10; i++) {
      cycleResults.add(runTerminalCycle(withDetails: true, cycle: i));
    }

    expect(cycleResults.where((result) => result).length, 10);
  });
}
