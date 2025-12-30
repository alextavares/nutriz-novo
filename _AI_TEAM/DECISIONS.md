# DECISIONS — Nutriz

Use este log para decisões que afetam arquitetura, UX padrão, regras de cálculo ou métricas.

Template (copie e preencha):

## YYYY-MM-DD — Título curto da decisão
- **Contexto:** (1–3 frases)
- **Opções consideradas:** (A/B/C)
- **Decisão:** (o que foi decidido)
- **Critérios de aceite:** (como saber que deu certo)
- **Impacto/Riscos:** (trade-offs)
- **Owner:** (expert responsável)
- **Links:** (PR, issue, arquivo, screenshots)

## 2025-12-17 — Onboarding progressivo (essencial + opcional)
- **Contexto:** Beta em 2 semanas; precisamos reduzir fricção e aumentar percepção de personalização sem travar o core.
- **Opções consideradas:** (A) Onboarding longo obrigatório (B) Onboarding mínimo + opcional progressivo (C) Sem onboarding (defaults).
- **Decisão:** Implementar onboarding **progressivo**: caminho essencial (60–90s) + caminho “mais preciso” opcional; mostrar “plano do dia” no fim e permitir pular/editar depois.
- **Critérios de aceite:** Usuário chega ao Diário com meta calculada em <2 min; tudo em pt-BR; pode editar metas depois; pular onboarding mantém defaults claros.
- **Impacto/Riscos:** Menos abandono; evita sensação de “armadilha” de esforço; risco de menor conversão imediata (mitigado com valor real antes do paywall).
- **Owner:** Produto + UX/UI
- **Links:** `nutriz/_AI_TEAM/BRIEF_ONBOARDING_YAZIO_LIKE.md`

## 2025-12-17 — Permitir editar metas sem “resetar” onboarding
- **Contexto:** Precisamos permitir que o usuário ajuste metas depois (Perfil → Editar) sem cair em loops de redirect do GoRouter.
- **Opções consideradas:** (A) Reabrir `/onboarding` e marcar incompleto (B) Criar rota dedicada de edição (C) Tela nova separada de metas.
- **Decisão:** Criar rota `/onboarding/edit` reaproveitando o fluxo, permitida apenas quando `isOnboardingCompleted=true`.
- **Critérios de aceite:** Usuário abre edição a partir do Perfil; salva e volta ao Perfil; não fica preso no onboarding.
- **Impacto/Riscos:** Reuso rápido do fluxo; risco de UX “welcome” em modo edição (mitigar com copy específica).
- **Owner:** Flutter + Produto/UX
- **Links:** `nutriz/lib/routing/app_router.dart`, `nutriz/lib/features/onboarding/presentation/pages/onboarding_page.dart`

## 2025-12-17 — Não redirecionar automaticamente do onboarding ao concluir
- **Contexto:** O perfil é persistido durante o cálculo (para evitar perder dados). Se o router redirecionar automaticamente quando `isOnboardingCompleted=true`, pode interromper a sequência (resultado/upsell).
- **Opções consideradas:** (A) Redirecionar sempre que concluído (B) Redirecionar só a partir do Splash (C) Não persistir até o final.
- **Decisão:** Manter redirect apenas no `/splash`; permitir permanecer em `/onboarding` mesmo com perfil “concluído”. Saída do onboarding é controlada por CTA.
- **Critérios de aceite:** Usuário vê resultado do onboarding e só sai quando tocar em “Registrar 1ª refeição”/“Continuar grátis”.
- **Impacto/Riscos:** Evita “bounces” inesperados; risco de usuário voltar ao onboarding (baixo no beta).
- **Owner:** Flutter + Produto/UX
- **Links:** `nutriz/lib/routing/app_router.dart`

## 2025-12-18 — Fórmula oficial de “Restantes” (MVP)
- **Contexto:** O app mostra “Restantes” no Resumo e em Detalhes; precisava bater sempre para evitar desconfiança e bugs visuais.
- **Opções consideradas:** (A) `meta - consumidas` (B) `meta - consumidas + queimadas` (C) “Restantes” baseado em macros/porcentagens.
- **Decisão:** Usar `restantes = meta_kcal - consumidas_kcal + queimadas_kcal`. No beta, `queimadas_kcal = 0` (placeholder) até existir fonte real.
- **Critérios de aceite:** “Restantes” do card Resumo e da tela Detalhes batem para o mesmo dia e mudam corretamente ao adicionar/remover alimento.
- **Impacto/Riscos:** Mantém consistência e abre espaço para integrar passos/treinos depois; risco de confusão se “queimadas” for exibido sem fonte (mitigar mantendo 0 e label claro).
- **Owner:** Lógica & Personalização + Flutter
- **Links:** `nutriz/lib/features/diary/presentation/widgets/daily_summary_header_improved.dart`, `nutriz/lib/features/diary/presentation/pages/nutrition_detail_screen.dart`

## 2025-12-18 — Beta Android local-first (sem login)
- **Contexto:** Lançar beta em 2 semanas com estabilidade e baixa fricção, sem depender de backend.
- **Opções consideradas:** (A) Login obrigatório (B) Login opcional (C) Sem login no beta.
- **Decisão:** Beta Android será **local-first** (sem conta). Persistência local via Isar; export de logs via `analytics_events.jsonl`.
- **Critérios de aceite:** Usuário completa onboarding, registra refeições e volta no D1 sem precisar de conta; dados persistem ao reabrir.
- **Impacto/Riscos:** Velocidade e simplicidade; risco de perda em troca de aparelho (aceitável no beta) e limites para métricas agregadas (mitigar coletando feedback manual + logs locais).
- **Owner:** Produto/UX + QA/Analytics + Flutter
- **Links:** `nutriz/lib/main.dart`, `nutriz/lib/core/analytics/analytics_service.dart`, `nutriz/_AI_TEAM/QA_BETA_CHECKLIST.md`
