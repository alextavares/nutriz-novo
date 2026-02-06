# RC + Google Play QA Checklist (Sprint 3)

## 1) Build com SDK key (teste interno)

Use uma chave pública válida do projeto RevenueCat:

```bash
flutter run \
  --dart-define=REVENUECAT_PUBLIC_SDK_KEY_ANDROID=YOUR_ANDROID_PUBLIC_SDK_KEY
```

Fallback opcional (multi-plataforma):

```bash
flutter run \
  --dart-define=REVENUECAT_PUBLIC_SDK_KEY=YOUR_PUBLIC_SDK_KEY
```

## 2) Validar carregamento de Offerings

1. Abrir app e navegar para cada paywall:
1. `premium_screen`
1. `hard_paywall_screen`
1. `offer_paywall_screen`
1. Confirmar preço carregado (não `—`) para plano esperado:
1. Premium: mensal e anual
1. Hard: mensal
1. Offer: anual
1. Se plano faltar, validar erro claro na UI e evento `purchase_failed` com `reason=package_not_found`.

## 3) Compra mensal

1. Entrar no paywall mensal (`premium_screen` ou `hard_paywall_screen`).
1. Realizar compra com conta tester da Play Console.
1. Confirmar:
1. `purchase_start` e `purchase_complete`
1. estado Premium ativo sem restart
1. redirecionamento/feedback de sucesso.

## 4) Compra anual com trial

1. Entrar no paywall anual (`premium_screen` ou `offer_paywall_screen`).
1. Selecionar anual e concluir compra.
1. Confirmar:
1. trial aplicado quando elegível
1. `purchase_start` e `purchase_complete`
1. estado Premium ativo sem restart.

## 5) Restore após reinstalação

1. Reinstalar app no mesmo tester.
1. Acionar `Restaurar` em paywall.
1. Confirmar:
1. feedback claro para sucesso, sem assinatura ativa e erro
1. `refresh` pós-restore aplicado
1. estado final Premium/Free coerente.

## 6) Auditoria de analytics de compra

Validar em arquivo local/Firebase os eventos com propriedades mínimas:

1. `paywall_view` com `paywall_id`
1. `paywall_cta_tap` com `paywall_id`, `plan_id`, `plan`
1. `purchase_start` com `paywall_id`, `plan_id`, `plan`, `product_id`
1. `purchase_complete` com `paywall_id`, `plan_id`, `plan`, `product_id`
1. `purchase_failed` com `paywall_id`, `plan_id`, `plan`, `product_id`, `reason`

## 7) Casos de erro obrigatórios

1. Rodar sem SDK key e validar erro de configuração claro.
1. Configurar offering sem pacote esperado (mensal/anual) e validar erro + `package_not_found`.
1. Cancelar compra na loja e validar `purchase_failed` com `reason=cancelled`.
