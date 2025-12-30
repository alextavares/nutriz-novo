# Eventos (Analytics) — Nutriz

Objetivo: medir ativação, engajamento e retenção sem complicar.

## Convenção
- `snake_case`
- Quando fizer sentido, enviar `screen` (ex: `diary`, `food_search`, `fasting`)
- Quando fizer sentido: `date` (YYYY-MM-DD local), `locale`, `timezone`

## Propriedades por domínio
- **Diário/refeições:** `meal_type` (breakfast/lunch/dinner/snack), `calories`, `source` (manual/search/barcode/ai), `food_id` (se houver)
- **Metas:** `goal_type` (lose/maintain/gain), `calorie_target`, `macros` (percent/grams), `activity_level`
- **Jejum:** `fasting_plan` (ex: 16_8), `fasting_state` (started/paused/resumed/ended), `duration_minutes`
- **Premium:** `paywall_id`, `product_id`, `price`, `currency`, `trial` (bool)

## Funil MVP (instalou → meta → 1ª refeição → D1)
### Ativação
- `app_open`
- `onboarding_start`
- `onboarding_step_view`
- `onboarding_complete`
- `goal_set`

### Engajamento (Diário)
- `diary_view`
- `date_changed`
- `meal_add_tap`
- `first_meal_cta_tap`
- `first_meal_cta_dismiss`
- `food_search_view`
- `food_search_done_tap`
- `food_search_query`
- `food_selected`
- `portion_edit_view`
- `meal_item_added`
- `meal_item_removed`

### Engajamento (Jejum)
- `fasting_view`
- `fasting_start`
- `fasting_end`
- `fasting_plan_set`

### Retenção / Saúde do app
- `notification_permission_prompted`
- `notification_permission_result`
- `time_to_first_meal_minutes`
- `app_backgrounded`
- `error_shown` (com `error_code`/`error_context`)

### Monetização (opcional no MVP)
- `paywall_view`
- `paywall_cta_tap`
- `purchase_start`
- `purchase_complete`
- `purchase_failed`
