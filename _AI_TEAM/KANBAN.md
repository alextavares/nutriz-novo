# KANBAN — Nutriz

## Agora (P0)
- [ ] (Monetização) Configurar RevenueCat + Google Play (mensal/anual + trial) e validar compra/restore
  - Aceite: compra funciona em track de teste; entitlement `premium` ativa no RevenueCat; restore funciona após reinstalar.
  - Referência: `nutriz/_AI_TEAM/REVENUECAT_PLAY_SETUP.md`
- [ ] (Analytics) Integrar Firebase Analytics e enviar eventos do funil MVP
  - Aceite: eventos mínimos em DebugView/Realtime; funil montável; sem PII.
  - Referências: `nutriz/_AI_TEAM/FIREBASE_ANALYTICS_SETUP.md`, `nutriz/_AI_TEAM/EVENTS.md`
- [ ] (QA/Produto) Preparar beta interno (12 testadores) — checklist + distribuição
  - Aceite: `app-release.apk` distribuído + instruções enviadas + `QA_BETA_CHECKLIST.md` rodado sem P0 aberto.
  - Referências: `nutriz/_AI_TEAM/BETA_RUNBOOK.md`, `nutriz/_AI_TEAM/QA_BETA_CHECKLIST.md`
- [ ] (QA/Produto) Padronizar coleta de feedback dos testadores
  - Aceite: template único (WhatsApp/Google Form) com device + passos + prints + severidade.
  - Referência: `nutriz/_AI_TEAM/TESTER_FEEDBACK_TEMPLATE.md`
- [ ] (Tech/QA) Checklist de regressão “smoke” (5–10 min) antes de cada APK
  - Aceite: 1 ciclo completo (onboarding → diário → 1ª refeição) + jejum + favoritos/Recentes sem crash/overflow.
- [ ] (Produto/UX) Diário: alinhar header (Hoje + Semana) na mesma linha dos ícones (diamante/streak/perfil)
  - Aceite: título e ícones no mesmo baseline; “Semana XX” abaixo do título sem “quebra” extra.
- [ ] (Produto/UX) Resumo: posicionar “Consumidas” e “Queimadas” como no Yazio (com hierarquia e alinhamento estáveis)
  - Aceite: números/labels alinhados; não quebra em telas pequenas; consistência com macros.
- [ ] (Produto/UX) D0: revisar CTA “Registrar 1ª refeição” (apenas 1 ação dominante) + estado vazio por refeição
  - Aceite: usuário entende em 3s “o que fazer agora”; sem CTAs duplicados competindo.
- [ ] (Produto/UX) Jejum no Diário: reduzir competição visual com o logging (CTA secundário quando dia vazio)
  - Aceite: logging de refeição segue como ação principal no beta; jejum permanece acessível.
- [ ] (Produto/UX) Onboarding: microcopy do começo/fim (evitar “Leva 1 minuto” quando já concluiu)
  - Aceite: nenhuma tela “promete” algo que já ocorreu; 100% pt-BR.
- [ ] (Flutter) Consolidar widgets do “Resumo” (ring + macros) e reduzir rebuilds
- [ ] (Lógica) Definir fórmula oficial de “Restantes” (com/sem queimadas) e fonte de dados
- [ ] (QA/Analytics) Definir funil MVP + eventos mínimos (`EVENTS.md`) e critérios de aceite
- [ ] (QA/Analytics) Checklist de beta + 10 cenários críticos (`QA_BETA_CHECKLIST.md`)
- [ ] (Produto/UX) Onboarding: revisar microcopy pt-BR e tempo (Essencial) (`BRIEF_ONBOARDING_YAZIO_LIKE.md`)
- [ ] (Flutter) Onboarding: retomar progresso (opcional)

## Próximo (P1)
- [ ] (Produto/UX) Melhorar fluxo “Adicionar alimento” (busca -> selecionar -> porção -> salvar)
- [ ] (Lógica) Regras MVP de jejum (estados + timer + virada do dia)
- [ ] (Flutter) Padronizar formatação numérica/medidas + i18n pt-BR
- [ ] (QA) Cobertura mínima de testes (unit/widget/integration) para Diário/Jejum
- [ ] (Growth) Copy das 5 screenshots + título/descrição (ASO pt-BR)
- [ ] (Produto/UX) Onboarding “Mais preciso” (opcional) + permissões/notificações
- [ ] (Flutter) Persistência do onboarding (retomar passo) + edição posterior em Perfil

## Backlog (P2+)
- [ ] (Produto/UX) Estados vazios e educação progressiva (microcopy) no Diário
- [ ] (Flutter) Sincronização opcional (backup/login) sem travar MVP
- [ ] (Lógica) “Queimadas” via passos/treinos (opcional, sem promessas)
- [ ] (Growth) Paywall e limites do free (sem irritar)

## Em andamento
- [ ]

## Em revisão
- [ ]

## Feito
- [x] (Produto/UX) Revisar “Resumo” (anel + consumidas/queimadas) e consistência de espaçamentos
- [x] (Produto/UX) Ajustar topo do Diário (título + semana no AppBar) e checar que não colide com ícones
- [x] (Flutter) Onboarding: botão “Pular” + rota de edição (`/onboarding/edit`) a partir do Perfil
- [x] (Flutter) Onboarding: CTA “Registrar 1ª refeição” leva ao Diário com quick-add
- [x] (Flutter) Onboarding: caminho Essencial mais curto (padrão), completo só em `/onboarding/edit`
- [x] (Flutter) Adicionar alimento: botão “Concluir (N itens)” + evento `food_search_done_tap`
- [x] (Analytics) Busca/porção: eventos `food_search_query` (debounce) + `portion_edit_view`
- [x] (Analytics) Eventos: `meal_item_removed` + `error_shown`
- [x] (Flutter) Diário: hint em refeições vazias + estado de erro com “Tentar novamente”
- [x] (Flutter) Jejum: botão alterna “Iniciar/Encerrar” + eventos `fasting_*`
- [x] (Android) Nome no launcher: `Nutriz`
