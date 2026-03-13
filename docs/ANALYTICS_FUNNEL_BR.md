# Analytics Funnel BR

## Arquivo local

Os eventos locais do app sao gravados em:

`analytics_events.jsonl`

Cada linha e um JSON com `name` e propriedades do evento.

## Script de resumo

Para ver o funil principal no terminal:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\analytics_funnel.ps1
```

Se o arquivo estiver em outro caminho:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\analytics_funnel.ps1 -Path "C:\caminho\analytics_events.jsonl"
```

## O que olhar primeiro

1. `onboarding_complete / onboarding_start`
2. `first_meal_cta_tap / goal_set`
3. `meal_item_added / first_meal_cta_tap`
4. `d1_retained / meal_item_added`
5. `purchase_complete / purchase_start`
6. `purchase_complete por source`
7. `purchase_complete por plan_id`

## Meta inicial do MVP

- onboarding_complete: `50%+`
- first_meal_cta_tap apos goal_set: `60%+`
- meal_item_added apos first_meal_cta_tap: `70%+`
- d1_retained apos meal_item_added: `30%+`
- purchase_complete apos purchase_start: `40%+`
- share anual dentro do pago: `60%+`

## Leitura rapida

- Se `goal_set` esta alto e `first_meal_cta_tap` baixo, o problema e copy ou CTA do resultado.
- Se `first_meal_cta_tap` esta alto e `meal_item_added` baixo, o problema esta em busca, porcao ou confirmacao.
- Se `meal_item_added` esta alto e `d1_retained` baixo, o app nao esta criando motivo claro para voltar.
- Se `paywall_view` esta alto e `purchase_start` baixo, o problema e proposta/copy do paywall.
- Se `purchase_start` esta alto e `purchase_complete` baixo, o problema pode ser oferta, checkout ou confianca.
