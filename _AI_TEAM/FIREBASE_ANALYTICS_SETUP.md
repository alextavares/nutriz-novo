# Runbook — Firebase Analytics (Nutriz)

Objetivo: ter **prova de tração** e **funil mensurável** (requisito prático para otimizar conversão e vender no Flippa).

## 1) Criar projeto Firebase
1) Crie um projeto no Firebase Console (ex: `nutriz-app`).
2) Ative **Google Analytics** no projeto.
3) Adicione o app **Android** com o `applicationId` do app (Package name).

## 2) Android — arquivo de configuração
1) Baixe `google-services.json`.
2) Coloque em: `nutriz/android/app/google-services.json`.

Observação: este arquivo geralmente pode ir para o repo (não é “secret” como um service account), mas se preferir, mantenha privado e documente no handoff.

## 3) Dependências Flutter (alto nível)
Adicionar:
- `firebase_core`
- `firebase_analytics`

Inicializar no `main()` com `Firebase.initializeApp()`.

## 4) Eventos mínimos (funil MVP)
Base: `nutriz/_AI_TEAM/EVENTS.md`.

Mínimo para Flippa e iteração:
- `app_open`
- `onboarding_start`
- `onboarding_complete`
- `first_meal_cta_tap` / `meal_add_tap`
- `meal_item_added` (considerar “primeiro log”)
- `paywall_view`
- `paywall_cta_tap`
- `purchase_start`
- `purchase_complete`
- `purchase_failed`

Métrica derivada:
- `time_to_first_meal_minutes`

## 5) Dashboard (o que mostrar em 8 semanas)
No mínimo, tenha 3 visões (prints exportáveis):
1) **Funil**: onboarding_complete → first_meal_logged → paywall_view → purchase_complete
2) **Retenção**: D1 e D7 (coortes)
3) **Receita**: MRR e subscribers (do RevenueCat) + correlação com paywall_view

## 6) LGPD / dados sensíveis (regras simples)
- Não envie conteúdo textual de alimentos, notas do dia, ou dados de saúde “brutos”.
- Envie apenas eventos e propriedades agregadas/limitadas (ex: `meal_type`, `calories_range`).
- Se houver identificadores, use o padrão do Firebase/RevenueCat sem inventar PII.

## 7) Checklist de validação
- [ ] Eventos aparecem em Realtime/DebugView.
- [ ] Funil consegue ser montado com os eventos escolhidos.
- [ ] Propriedades estão pequenas e consistentes (`snake_case`).
- [ ] Não há PII em payloads.

