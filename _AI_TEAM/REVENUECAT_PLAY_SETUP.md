# Runbook — RevenueCat + Google Play (Nutriz)

Objetivo: colocar **assinatura mensal e anual com trial** funcionando de ponta a ponta e destravar receita + validação para Flippa.

## Pré‑requisitos
- Acesso ao **Google Play Console** do app.
- Conta RevenueCat já criada.
- Um APK/AAB instalável (ideal: **Internal testing** no Play).

## 1) Google Play Console — criar as assinaturas
No Play Console: **Monetizar → Produtos → Assinaturas**.

Crie 2 produtos (IDs sugeridos):
- `nutriz_premium_monthly`
- `nutriz_premium_annual`

Para cada produto:
1) Crie **Base plan** (ex: `monthly_base`, `annual_base`).
2) Defina **preço** e regiões.
3) Configure **free trial** via **offers** no base plan (ex: 7 dias).
4) Salve e **ative** (algumas telas ficam como “rascunho” até publicar).

Checklist rápido:
- [ ] Produtos estão **Active** (não apenas Draft).
- [ ] Trial aparece como Offer no base plan.
- [ ] Conta de teste configurada (license tester) para testar sem cobrança real.

## 2) Google Play Console — testers
Para testar compra/restore:
- Use **Internal testing** com uma lista de testers.
- Configure **License Testing** (Play Console → Configurações → License testing).

## 3) RevenueCat — criar App, Entitlement e Offering
No RevenueCat:

1) **Apps → + New**: crie/adicione o app Android.
2) Copie a **Public SDK Key (Android)**.
3) **Entitlements**:
   - Crie entitlement id: `premium` (este id é usado no app para liberar recursos).
4) **Products**:
   - Importe/adicione os produtos do Google Play (`nutriz_premium_monthly`, `nutriz_premium_annual`).
5) **Offerings**:
   - Crie um offering (ex: `default`).
   - Adicione packages padrões:
     - `$rc_monthly` → vincule ao `nutriz_premium_monthly`
     - `$rc_annual` → vincule ao `nutriz_premium_annual`

Observações:
- Se você mantiver “3 meses” no UI, crie também `nutriz_premium_quarterly` + `$rc_three_month` (opcional).
- Configure o trial no Play; o RevenueCat apenas reflete o que a store fornece.

## 4) App (Flutter) — como o código deve ler a configuração
Recomendação: passar a Public SDK Key por `--dart-define` (evita hardcode no repo).

Exemplo (Android):
- `--dart-define=REVENUECAT_PUBLIC_SDK_KEY_ANDROID=pk_xxx`

Quando iOS estiver pronto:
- `--dart-define=REVENUECAT_PUBLIC_SDK_KEY_IOS=appl_xxx`

## 5) Teste ponta a ponta (script mental)
Em um device com conta tester:
1) Abrir app → ir no Premium → escolher plano → comprar.
2) Confirmar que:
   - RevenueCat mostra o usuário em **Customers**.
   - Entitlement `premium` fica **Active**.
   - O app muda para estado Premium (sem reiniciar).
3) Desinstalar e reinstalar → **Restaurar** → Premium volta.

## 6) Erros comuns (e como diagnosticar rápido)
- “Pagamento não configurado” no app: o fluxo de compra ainda está mockado/sem integração ou a key/config não está sendo carregada.
- Produto não aparece / offering vazio: produto não está active no Play, IDs errados, offering sem packages, ou device não está na track de teste.
- Trial não aparece: offer não configurado no base plan ou região do tester não tem o offer.
- “Item already owned”: usuário já tem assinatura ativa (teste com outra conta).

## 7) O que registrar para Flippa (mínimo)
- Print do RevenueCat: MRR, subscribers, churn (mesmo que pequeno).
- Print do funil (Firebase): paywall_view → purchase_complete.
- Documento simples: preços, trial, e “como está configurado”.

