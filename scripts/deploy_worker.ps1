Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

param(
  [Parameter(Mandatory = $false)]
  [string]$GeminiApiKey
)

Write-Host "== Nutriz Worker Deploy ==" -ForegroundColor Cyan

$projectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$nutrizDir = Resolve-Path (Join-Path $projectDir "..")
Set-Location $nutrizDir

Write-Host ("Dir: " + $nutrizDir) -ForegroundColor DarkGray

if (-not (Get-Command wrangler -ErrorAction SilentlyContinue)) {
  Write-Host "Wrangler não encontrado. Instale com: npm i -g wrangler" -ForegroundColor Yellow
  exit 1
}

wrangler --version

Write-Host "`n1) Login (vai abrir o navegador):" -ForegroundColor Cyan
wrangler login

Write-Host "`n2) Configurar segredo GEMINI_API_KEY:" -ForegroundColor Cyan
if ([string]::IsNullOrWhiteSpace($GeminiApiKey)) {
  $GeminiApiKey = $env:GEMINI_API_KEY
}
if ([string]::IsNullOrWhiteSpace($GeminiApiKey)) {
  Write-Host "Cole sua GEMINI_API_KEY (não será salva no repo):" -ForegroundColor DarkGray
  $GeminiApiKey = Read-Host -Prompt "GEMINI_API_KEY"
}
if ([string]::IsNullOrWhiteSpace($GeminiApiKey)) {
  throw "GEMINI_API_KEY vazia. Abortei."
}

# Wrangler pode rodar sem TTY em alguns ambientes; por isso passamos via stdin.
$GeminiApiKey | wrangler secret put GEMINI_API_KEY
$GeminiApiKey = $null

Write-Host "`n3) Deploy:" -ForegroundColor Cyan
wrangler deploy

Write-Host "`nOK. Agora use a URL retornada em:" -ForegroundColor Green
Write-Host "flutter run --dart-define=NUTRIZ_WORKER_URL=https://SEU-WORKER.workers.dev"
