# Beta Runbook — Nutriz (pt-BR)

## Objetivo
Distribuir um **beta em 2 semanas** com o loop MVP funcionando:
onboarding → Diário → CTA “Registrar 1ª refeição” → adicionar alimento → “Restantes” atualiza.

## Caminho recomendado (rápido + seguro)
1) **Primeiro beta por APK** (10–30 pessoas) para pegar bugs rápido.
2) Em paralelo, preparar **Play Console (Teste interno)** para facilitar updates e feedback.

## Checklist antes de mandar pra testers (30–60 min)
- Rodar `nutriz/_AI_TEAM/QA_BETA_CHECKLIST.md`
- Fazer 1 ciclo completo:
  - concluir onboarding → cair no Diário → tocar CTA “Registrar 1ª refeição” → adicionar 1 item
- Verificar que o arquivo de eventos existe:
  - Android: `/data/user/0/com.nutriz.nutriz/app_flutter/analytics_events.jsonl`

## Build Android (Windows)
No PowerShell, dentro de `C:\codigos\nutritionapp\nutriz`:
- `flutter clean`
- `flutter pub get`
- APK debug (rápido): `flutter build apk --debug`
- APK release (para enviar): `flutter build apk --release`

Arquivo gerado:
- `build\app\outputs\flutter-apk\app-release.apk`

## Distribuição por APK (rápida)
- Subir o `app-release.apk` no Google Drive/Dropbox e mandar o link.
- Pedir pro tester:
  - permitir instalar “fontes desconhecidas”
  - mandar feedback com print + “o que eu fiz” + modelo do celular

## Play Console (Teste interno) — quando você tiver conta
1) Criar app (Nutriz)
2) Criar faixa “Teste interno”
3) Subir `.aab` (mais comum no Play):
   - `flutter build appbundle --release`
   - Se der erro de assinatura, configure `android/key.properties` (veja `android/key.properties.example`)
4) Adicionar testers (e-mails) e compartilhar link

## Coleta de feedback (barato)
Crie um Google Form com:
- Device/Android versão
- Conseguiu concluir onboarding? (S/N)
- Conseguiu registrar 1ª refeição? (S/N)
- Travou/bugou? (descrever + print)
- Nota 0–10 “clareza do Diário”
