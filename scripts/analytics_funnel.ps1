param(
  [string]$Path = "analytics_events.jsonl"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $Path)) {
  Write-Host "Arquivo de analytics nao encontrado: $Path" -ForegroundColor Red
  Write-Host "Dica: rode o app, gere eventos e depois execute este script apontando para o JSONL." -ForegroundColor Yellow
  exit 1
}

$events = New-Object System.Collections.Generic.List[object]
$invalidLines = 0

Get-Content -LiteralPath $Path | ForEach-Object {
  $line = $_.Trim()
  if ([string]::IsNullOrWhiteSpace($line)) {
    return
  }

  try {
    $events.Add(($line | ConvertFrom-Json))
  } catch {
    $invalidLines++
  }
}

if ($events.Count -eq 0) {
  Write-Host "Nenhum evento valido encontrado em $Path" -ForegroundColor Yellow
  if ($invalidLines -gt 0) {
    Write-Host "Linhas invalidas ignoradas: $invalidLines" -ForegroundColor Yellow
  }
  exit 0
}

function Get-EventCount {
  param([string]$Name)
  return @($events | Where-Object { $_.name -eq $Name }).Count
}

function Get-EventSubset {
  param([string]$Name)
  return @($events | Where-Object { $_.name -eq $Name })
}

function Format-Rate {
  param(
    [int]$Count,
    [int]$Base
  )

  if ($Base -le 0) {
    return "-"
  }

  return ("{0:P1}" -f ($Count / $Base))
}

function Print-Section {
  param([string]$Title)
  Write-Host ""
  Write-Host $Title -ForegroundColor Cyan
}

function Print-CountRow {
  param(
    [string]$Label,
    [int]$Count,
    [int]$Base = 0
  )

  if ($Base -gt 0) {
    $rate = Format-Rate -Count $Count -Base $Base
    Write-Host ("- {0}: {1} ({2})" -f $Label, $Count, $rate)
    return
  }

  Write-Host ("- {0}: {1}" -f $Label, $Count)
}

function Print-Breakdown {
  param(
    [string]$Title,
    [object[]]$Subset,
    [string]$Property
  )

  Print-Section $Title

  if ($Subset.Count -eq 0) {
    Write-Host "- sem eventos"
    return
  }

  $rows = $Subset |
    Group-Object -Property {
      $value = $_.$Property
      if ([string]::IsNullOrWhiteSpace([string]$value)) { "(sem $Property)" } else { [string]$value }
    } |
    Sort-Object Count -Descending

  foreach ($row in $rows) {
    Write-Host ("- {0}: {1}" -f $row.Name, $row.Count)
  }
}

$appOpen = Get-EventCount "app_open"
$onboardingStart = Get-EventCount "onboarding_start"
$onboardingComplete = Get-EventCount "onboarding_complete"
$goalSet = Get-EventCount "goal_set"
$firstMealCtaTap = Get-EventCount "first_meal_cta_tap"
$mealItemAdded = Get-EventCount "meal_item_added"
$d1Retained = Get-EventCount "d1_retained"
$paywallView = Get-EventCount "paywall_view"
$paywallCtaTap = Get-EventCount "paywall_cta_tap"
$purchaseStart = Get-EventCount "purchase_start"
$purchaseComplete = Get-EventCount "purchase_complete"
$purchaseFailed = Get-EventCount "purchase_failed"

$timeToFirstMeal = Get-EventSubset "time_to_first_meal_minutes"
$avgTimeToFirstMeal = $null
if ($timeToFirstMeal.Count -gt 0) {
  $avgTimeToFirstMeal = [Math]::Round((($timeToFirstMeal | Measure-Object -Property minutes -Average).Average), 1)
}

Write-Host "Arquivo: $Path" -ForegroundColor Green
Write-Host "Eventos validos: $($events.Count)" -ForegroundColor Green
if ($invalidLines -gt 0) {
  Write-Host "Linhas invalidas ignoradas: $invalidLines" -ForegroundColor Yellow
}

Print-Section "Funil principal"
Print-CountRow -Label "app_open" -Count $appOpen
Print-CountRow -Label "onboarding_start" -Count $onboardingStart -Base $appOpen
Print-CountRow -Label "onboarding_complete" -Count $onboardingComplete -Base $onboardingStart
Print-CountRow -Label "goal_set" -Count $goalSet -Base $onboardingComplete
Print-CountRow -Label "first_meal_cta_tap" -Count $firstMealCtaTap -Base $goalSet
Print-CountRow -Label "meal_item_added" -Count $mealItemAdded -Base $firstMealCtaTap
Print-CountRow -Label "d1_retained" -Count $d1Retained -Base $mealItemAdded

Print-Section "Monetizacao"
Print-CountRow -Label "paywall_view" -Count $paywallView -Base $mealItemAdded
Print-CountRow -Label "paywall_cta_tap" -Count $paywallCtaTap -Base $paywallView
Print-CountRow -Label "purchase_start" -Count $purchaseStart -Base $paywallCtaTap
Print-CountRow -Label "purchase_complete" -Count $purchaseComplete -Base $purchaseStart
Print-CountRow -Label "purchase_failed" -Count $purchaseFailed -Base $purchaseStart

Print-Section "Velocidade"
if ($null -ne $avgTimeToFirstMeal) {
  Write-Host "- media time_to_first_meal_minutes: $avgTimeToFirstMeal"
} else {
  Write-Host "- sem eventos de time_to_first_meal_minutes"
}

Print-Breakdown -Title "first_meal_cta_tap por source" -Subset (Get-EventSubset "first_meal_cta_tap") -Property "source"
Print-Breakdown -Title "paywall_view por source" -Subset (Get-EventSubset "paywall_view") -Property "source"
Print-Breakdown -Title "purchase_complete por source" -Subset (Get-EventSubset "purchase_complete") -Property "source"
Print-Breakdown -Title "purchase_complete por plan_id" -Subset (Get-EventSubset "purchase_complete") -Property "plan_id"

Print-Section "Top eventos"
$topEvents = $events |
  Group-Object -Property name |
  Sort-Object Count -Descending |
  Select-Object -First 12

foreach ($row in $topEvents) {
  Write-Host ("- {0}: {1}" -f $row.Name, $row.Count)
}
