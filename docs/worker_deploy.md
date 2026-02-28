# Deploy do Worker (IA)

O app usa um Cloudflare Worker para:
- buscar alimentos: `GET /search-food?q=...`
- analisar foto: `POST /analyze-food` (multipart com campo `image`)
- chat do Coach: `POST /coach-chat` (JSON com `message` e `profile`)

## 1) Instalar o Wrangler
No Windows (PowerShell):
1) Instale Node.js (LTS): https://nodejs.org
2) `npm i -g wrangler`

## 2) Login
No PowerShell:
- `wrangler login`

## 3) Configurar a key do Gemini (secret)
No PowerShell, dentro de `nutriz/`:
- Se estiver em terminal interativo: `wrangler secret put GEMINI_API_KEY`
- Se der erro de “non-interactive context”, passe via stdin:
  - `Read-Host "GEMINI_API_KEY" | wrangler secret put GEMINI_API_KEY`

## 4) Deploy
No PowerShell:
- `cd C:\codigos\nutritionapp\nutriz`
- `wrangler deploy`

## 5) Apontar o app para o seu Worker
O app lê a URL base do Worker via `--dart-define`:
- `NUTRIZ_WORKER_URL=https://SEU-WORKER.workers.dev`

Exemplo:
- `flutter run --dart-define=NUTRIZ_WORKER_URL=https://seu-worker.workers.dev`

Se você não passar `NUTRIZ_WORKER_URL`, o app usa o default do código.
