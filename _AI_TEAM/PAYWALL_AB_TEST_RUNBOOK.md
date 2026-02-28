# Paywall A/B Test Runbook

## Variantes
- `variant_a`: paywall Premium com plano anual exibido primeiro (seleção inicial anual).
- `variant_b`: paywall Premium com plano mensal exibido primeiro (seleção inicial mensal).
- Regra determinística: hash local de `profile.id` (mesmo usuário sempre cai na mesma variante).

## Telas cobertas
- `premium_screen`
- `hard_paywall_screen`
- `offer_paywall_screen`

## Eventos e parâmetros obrigatórios
Todos os eventos abaixo enviam:
- `paywall_id`
- `paywall_variant`

Eventos de funil:
- `paywall_view`
- `paywall_dismissed` (quando aplicável)
- `paywall_cta_tap`
- `purchase_start`
- `purchase_complete`
- `purchase_failed` (sempre com `reason` padronizado em snake_case)

Parâmetros adicionais por compra:
- `plan_id`
- `plan`
- `product_id` (quando disponível)

## Como ler no Firebase Analytics
1. Abra Firebase Analytics > Events.
2. Filtre por `paywall_view` e quebre por `paywall_id` + `paywall_variant`.
3. Para conversão, compare:
   - `purchase_complete / paywall_view`
4. Para diagnóstico de fricção, compare:
   - `purchase_failed / purchase_start`
   - distribuição de `reason` em `purchase_failed`.

## Critério de decisão do vencedor
- Métrica primária: taxa de compra
  - `purchase_complete / paywall_view`
- Métrica secundária: taxa de abandono
  - `paywall_dismissed / paywall_view`
- Sanidade técnica:
  - sem aumento relevante em `purchase_failed`.

## Checklist operacional
1. Instalar build com Firebase e RevenueCat configurados.
2. Abrir os 3 paywalls e validar eventos com `paywall_variant`.
3. Simular compra completa e compra cancelada.
4. Validar `purchase_failed.reason` normalizado.
5. Exportar relatório por variante (A vs B) para decisão.
