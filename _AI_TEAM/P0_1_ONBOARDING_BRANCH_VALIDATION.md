# P0.1 Onboarding Loop (Branch A/B) - Validation

## Scope
- Branch A: "Obrigado, estou pronto" (sem detalhes extras)
- Branch B: "Adicionar mais detalhes"

## Goal
- Nunca loopar após cálculo
- Finalizar sempre em `/diary`
- Sem regressão de monetização/paywall

## Release-like validation protocol
1. Build/install release-like (`flutter run --release` ou APK/AAB interno).
2. Para cada ciclo, iniciar instalação limpa lógica:
   - `adb -s emulator-5554 shell pm clear com.nutriz.app`
   - `adb -s emulator-5554 shell am start -n com.nutriz.app/.MainActivity`
3. Executar onboarding completo escolhendo o ramo correto.
4. Marcar PASS/FAIL.

## PASS criteria per cycle
- Não entra em loop no bloco final (calculating/results/proUpsell/allDone)
- Não volta para "calculating" após ter saído dela
- Chega ao diário (`/diary`)

## Matrix
### Branch A (sem detalhes)
- A1: PASS | FAIL
- A2: PASS | FAIL
- A3: PASS | FAIL

### Branch B (com detalhes)
- B1: PASS | FAIL
- B2: PASS | FAIL
- B3: PASS | FAIL

## Consolidated result
- Branch A: 3/3 PASS | FAIL
- Branch B: 3/3 PASS | FAIL
- Final P0.1 status: PASS | FAIL
