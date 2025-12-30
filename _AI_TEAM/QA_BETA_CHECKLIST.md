# QA + Analytics — Beta (2 semanas) — Nutriz

## North Star (beta)
- **Ativação:** `% usuários que registram 1ª refeição em até 10 min` após `app_open`

## KPIs de suporte
- `onboarding_complete_rate` = `onboarding_complete / onboarding_start`
- `time_to_first_meal_minutes` = diff entre `app_open` e `meal_item_added` (primeiro)
- `d1_retention` = usuário com `app_open` no dia seguinte
- `meal_add_tap_rate` = `meal_add_tap / diary_view`
- `crash_free_sessions` (manual no beta: “app travou?” + logs)

## Eventos mínimos (mapeados no código)
- `app_open`
- `onboarding_start`
- `onboarding_step_view`
- `onboarding_complete`
- `goal_set`
- `diary_view`
- `date_changed`
- `meal_add_tap`
- `food_search_view`
- `food_search_tab_view`
- `food_selected`
- `meal_item_added`

## Onde ficam os logs (beta)
- Arquivo local (JSONL): `analytics_events.jsonl` no diretório de documentos do app (Android/iOS).
- Formato: 1 linha = 1 evento (`json`).
- Android (debug) via Android Studio → **Device Explorer**:
  - `/data/user/0/com.nutriz.nutriz/app_flutter/analytics_events.jsonl`

## Modo debug (opcional)
- Por padrão, o app fica **silencioso** (sem spam no console).
- Para habilitar logs (somente debug build): `flutter run --dart-define=NUTRIZ_DEBUG_LOGS=true --dart-define=NUTRIZ_DEBUG_VERBOSE=true`
- Para imprimir eventos no console (além do arquivo): `flutter run --dart-define=NUTRIZ_DEBUG_LOGS=true --dart-define=NUTRIZ_DEBUG_VERBOSE=true --dart-define=NUTRIZ_DEBUG_ANALYTICS_CONSOLE=true`

## 10 cenários críticos (MVP)
1) **Primeiro launch** → cai no onboarding (sem loops).
2) Onboarding **conclui** → (teste voltar/corrigir respostas, ex.: atividade física) → cai no Diário com CTA “Registrar 1ª refeição” → adiciona 1 alimento → “Restantes” atualiza.
3) Onboarding **pular** → cai no Diário com CTA “Registrar 1ª refeição” → adiciona 1 alimento → “Restantes” atualiza.
4) Perfil → **Editar metas** (`/onboarding/edit`) → salvar → volta Perfil sem ficar preso no onboarding.
5) Adicionar alimento via **Buscar** → sheet de porção → salvar → Diário atualiza.
6) Adicionar alimento via **Câmera IA** (se disponível) → confirmar porção → salvar.
7) **Remover** item/refeição → “Restantes” volta a subir.
8) **Trocar dia** (PageView) → dados mudam e “Semana X” atualiza.
9) Jejum → **Iniciar jejum** → timer roda → **Encerrar jejum** → botão volta para **Iniciar jejum**.
10) Fechar e abrir app → dados persistem (perfil + diário).

## Sanidade visual (rápido)
- Tela Detalhes → seção Refeições: apenas 1 CTA de “Adicionar alimento” (sem duplicação).

## Checklist pré-beta
- Strings pt-BR (sem “Cancel/Confirm/Done” visível).
- Loading/erro/vazio em Diário, Busca, Jejum e Perfil.
- Performance: sem travamentos ao abrir Diário e ao abrir sheet de alimento.
- Acessibilidade: botões tocáveis, contraste do anel, labels nos ícones principais.
- Medidas: telas de Peso/Medidas sem inglês (título, botões, validação).
