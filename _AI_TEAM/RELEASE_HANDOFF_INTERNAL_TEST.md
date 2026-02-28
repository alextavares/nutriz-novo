# Release Handoff - Internal Testing (Android)

## Escopo executado localmente
Preparação técnica para teste real de compra no Android (Play Internal Testing), mantendo monetização/analytics existentes.

## Comandos executados
```bash
flutter pub get
flutter analyze
flutter test
flutter clean
flutter pub get
flutter build appbundle --release --dart-define=REVENUECAT_PUBLIC_SDK_KEY_ANDROID=YOUR_ANDROID_PUBLIC_SDK_KEY
```

## Resultados

### 1) Pré-checagens
- `flutter pub get`: OK.
- `flutter analyze`: baseline atual com **138 issues preexistentes** (sem erro novo crítico de build).
- `flutter test`: OK, **10 testes passaram**.
- Validação de chave RevenueCat Android por `--dart-define`:
  - leitura em `lib/features/premium/presentation/providers/subscription_provider.dart` via `String.fromEnvironment('REVENUECAT_PUBLIC_SDK_KEY_ANDROID')`.
- Validação de eventos com `paywall_variant` nos 3 paywalls:
  - `premium_screen.dart`
  - `hard_paywall_screen.dart`
  - `offer_paywall_screen.dart`
  - eventos confirmados via tracker: `paywall_view`, `paywall_cta_tap`, `purchase_start`, `purchase_complete`, `purchase_failed`, `paywall_dismissed` (quando aplicável).

### 2) Build release (AAB)
- Pipeline executado: `clean -> pub get -> build appbundle`.
- Gradle finalizou com `BUILD SUCCESSFUL` e bundle gerado.
- O comando Flutter retornou erro no pós-check automático por ausência de `cmdline-tools/apkanalyzer` no SDK:
  - `Release app bundle failed to strip debug symbols from native libraries.`
  - Apesar disso, o AAB foi gerado e contém `BUNDLE-METADATA/.../libflutter.so.sym`.

## Artefato gerado
- Caminho:
  - `build/app/outputs/bundle/release/app-release.aab`
- Tamanho:
  - `62944184 bytes` (`60.03 MiB`)
- Timestamp:
  - `2026-02-06 18:13:50.760886100 -0300`
- SHA-256:
  - `9d6f8731d51bf52e8c502433da5041b84a56ed7732daf720b2ebd16ff919045a`

## Riscos técnicos remanescentes
- Falta `cmdline-tools` no Android SDK local (afeta validação pós-build do Flutter).
- Há warnings/infos de `flutter analyze` no baseline do projeto (138) que não foram tratados neste handoff.
- Workspace contém alterações fora de escopo já existentes (modificados/untracked) e não foram alteradas/removidas aqui.

## Passos humanos obrigatórios
1. No ambiente de release oficial, instalar Android SDK Command-line Tools (`cmdline-tools/latest`) e rodar `flutter doctor`.
2. Substituir `YOUR_ANDROID_PUBLIC_SDK_KEY` pela chave pública real do app Android (RevenueCat).
3. Upload do `app-release.aab` em Play Console > Internal Testing.
4. Confirmar offers/produtos e entitlement no RevenueCat + Play Console (mensal/anual/trial).
5. Validar eventos de funil e `paywall_variant` no Firebase/RevenueCat com testers reais.
