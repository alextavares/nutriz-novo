# P0 Onboarding Loop - Validação Objetiva (3 ciclos)

## Objetivo
Validar em instalação limpa que o fluxo final do onboarding não entra mais em loop entre
"calculando taxa metabólica" e "concluindo plano".

## Pré-requisitos
- Emulador Android ligado e `adb devices` com status `device`.
- Build instalada (`com.nutriz.app`).
- Rodar com logs verbosos ativos para capturar sinais temporários:
  - `DebugFlags.canVerbose = true` no build de validação.

## Sinais esperados no logcat
- `onboarding_step_enter`
- `calculation_start`
- `calculation_complete`
- `persist_completion_start`
- `persist_completion_end`
- `final_navigation`

## Comandos exatos (filtro de sinais)
Use estes comandos em cada ciclo.

1. Limpar logs:
```bash
adb logcat -c
```

2. Limpar dados do app (instalação limpa lógica):
```bash
adb shell pm clear com.nutriz.app
```

3. Abrir app:
```bash
adb shell am start -n com.nutriz.app/.MainActivity
```

4. Após concluir o onboarding manualmente, exportar logs filtrados:
```bash
adb logcat -d | rg "onboarding_step_enter|calculation_start|calculation_complete|persist_completion_start|persist_completion_end|final_navigation"
```

5. Contagem objetiva por evento:
```bash
adb logcat -d | rg -c "calculation_start"
adb logcat -d | rg -c "calculation_complete"
adb logcat -d | rg -c "persist_completion_start"
adb logcat -d | rg -c "persist_completion_end"
adb logcat -d | rg -c "final_navigation"
```

6. Verificar tela final (deve terminar no app principal/diário, sem voltar a cálculo):
```bash
adb shell dumpsys window | rg -m1 "mCurrentFocus"
```

## Roteiro manual por ciclo (C1, C2, C3)
1. Executar comandos 1, 2 e 3.
2. Percorrer onboarding completo até o fim.
3. Observar visualmente que após conclusão não há retorno para tela de cálculo.
4. Confirmar que a navegação final chega no diário.
5. Executar comandos 4, 5 e 6.
6. Preencher o template do ciclo.

## Critério PASS/FAIL
PASS no ciclo quando TODOS os itens forem verdadeiros:
- `calculation_start` = 1
- `calculation_complete` = 1
- `persist_completion_start` = 1
- `persist_completion_end` = 1
- `final_navigation` = 1
- Não voltou para tela de cálculo após conclusão
- Terminou em `/diary` (ou tela equivalente do diário no app)

FAIL no ciclo se qualquer item acima falhar.

PASS geral P0:
- C1, C2 e C3 com PASS.

## Template de relatório (copiar e preencher)

### C1
- Resultado: PASS | FAIL
- Counts:
  - calculation_start: 
  - calculation_complete: 
  - persist_completion_start: 
  - persist_completion_end: 
  - final_navigation: 
- Voltou para tela de cálculo após conclusão? SIM | NÃO
- Tela final (`mCurrentFocus`):
- Evidência (trecho log filtrado):

### C2
- Resultado: PASS | FAIL
- Counts:
  - calculation_start: 
  - calculation_complete: 
  - persist_completion_start: 
  - persist_completion_end: 
  - final_navigation: 
- Voltou para tela de cálculo após conclusão? SIM | NÃO
- Tela final (`mCurrentFocus`):
- Evidência (trecho log filtrado):

### C3
- Resultado: PASS | FAIL
- Counts:
  - calculation_start: 
  - calculation_complete: 
  - persist_completion_start: 
  - persist_completion_end: 
  - final_navigation: 
- Voltou para tela de cálculo após conclusão? SIM | NÃO
- Tela final (`mCurrentFocus`):
- Evidência (trecho log filtrado):

## Resultado consolidado
- C1:
- C2:
- C3:
- Status P0 final: PASS | FAIL
