import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nutriz/main.dart' as app;
import 'package:nutriz/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:nutriz/features/diary/presentation/pages/diary_page.dart';

import 'package:google_fonts/google_fonts.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('Onboarding flow and persistence test', (
    WidgetTester tester,
  ) async {
    await app.main();
    await tester.pumpAndSettle();

    // Verify we are on Onboarding Page
    expect(find.byType(OnboardingPage), findsOneWidget);
    expect(find.text('Bem-vindo ao Nutriz'), findsOneWidget);

    // Step 1: Welcome - tap "Começar"
    await tester.tap(find.text('Começar'));
    await tester.pumpAndSettle();
    expect(find.text('Qual é seu objetivo?'), findsOneWidget);

    // Step 2: Main Goal - "Perder Peso" is default, tap Next
    await tester.tap(find.text('Próximo'));
    await tester.pumpAndSettle();
    expect(find.text('Qual é seu sexo?'), findsOneWidget);

    // Step 3: Gender - tap Male (default), tap Next
    await tester.tap(find.text('Próximo'));
    await tester.pumpAndSettle();
    expect(find.text('Qual é sua idade?'), findsOneWidget);

    // Step 4: Birth Date - age 34 by default, tap Next
    await tester.tap(find.text('Próximo'));
    await tester.pumpAndSettle();
    expect(find.text('Qual é sua altura?'), findsOneWidget);

    // Step 5: Height - 170cm by default, tap Next
    await tester.tap(find.text('Próximo'));
    await tester.pumpAndSettle();
    expect(find.text('Qual é seu peso atual?'), findsOneWidget);

    // Step 6: Current Weight - 70kg by default, tap Next
    await tester.tap(find.text('Próximo'));
    await tester.pumpAndSettle();
    expect(find.text('Qual é seu peso meta?'), findsOneWidget);

    // Step 7: Target Weight - 65kg by default, tap Next
    await tester.tap(find.text('Próximo'));
    await tester.pumpAndSettle();
    expect(find.text('Nível de atividade física'), findsOneWidget);

    // Step 8: Activity Level - sedentary by default, tap Next
    await tester.tap(find.text('Próximo'));
    await tester.pumpAndSettle();
    expect(find.text('Ritmo de progresso'), findsOneWidget);

    // Step 9: Weekly Goal - -0.5kg by default, tap Next
    await tester.tap(find.text('Próximo'));
    await tester.pumpAndSettle();
    expect(find.text('Preferência alimentar'), findsOneWidget);

    // Step 10: Dietary Preference - classic by default, tap Next (triggers calculation)
    await tester.tap(find.text('Próximo'));
// print('Tapped Next to start calculation');

    // Step 11: Calculating - wait for calculation animation
    // Use pump() with specific duration because of looping animations
    await tester.pump(const Duration(seconds: 5));
// print('Waiting for calculation...');
    await tester.pump(const Duration(seconds: 2));

    // Step 12: Results - should show calculated calories
    expect(find.text('Seu plano está pronto!'), findsOneWidget);
// print('Found results page');

    // Tap continue to go to PRO upsell
    await tester.tap(find.text('Continuar'));
    await tester.pump(const Duration(seconds: 1));

    // Step 13: PRO Upsell - tap "Continuar com versão gratuita"
    await tester.tap(find.text('Continuar com versão gratuita'));
// print('Tapped continue free');

    // Wait for navigation with pump() due to looping animations on DiaryPage
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 2));

    // Verify we navigated to Diary
    expect(find.byType(DiaryPage), findsOneWidget);
// print('Found DiaryPage');

    // Verify calculated calories are shown
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Remaining'), findsOneWidget);
// print('Found Remaining text');
  });
}
