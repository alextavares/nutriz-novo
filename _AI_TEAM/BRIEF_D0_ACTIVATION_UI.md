# Brief — D0 Ativação (Diário/Resumo) — Beta

## Objetivo
Maximizar **ativação no D0**: usuário entende “Restantes” e registra a **1ª refeição** rápido (sem confusão visual).

## Contexto
- Tela/fluxo: `Diário` (home) + card “Resumo/Restantes” + lista de refeições.
- Referência: Yazio (layout do header; consumidas/queimadas ao lado do anel).
- Restrições: beta em ~2 semanas, sem refazer design inteiro, sem “features gigantes”.

## Estado atual
- Header do Diário: “Hoje + Semana” às vezes parece em uma linha abaixo dos ícones.
- Card Resumo: precisa reforçar hierarquia e alinhamento de “Consumidas”/“Queimadas”.
- D0: precisa ficar óbvio “o que fazer agora” (registrar 1ª refeição) sem competir com jejum.

## Pedido
Entregue:
1) Lista de 5 tarefas numeradas (P0/P1) com microcopy pt-BR.
2) Critérios de aceite (checklist) para cada tarefa.
3) “Não fazer agora” (escopo fora do beta).

## Métrica
- North Star (beta): `% usuários que registram 1ª refeição em até 10 min`.

## Arquivos alvo (prováveis)
- `nutriz/lib/features/diary/presentation/pages/diary_page.dart`
- `nutriz/lib/features/diary/presentation/widgets/daily_summary_header_improved.dart`
- `nutriz/lib/features/diary/presentation/pages/home_page.dart` (se existir header/TopBar)
- `nutriz/lib/routing/app_router.dart` (se mexer no firstRun/CTA)

