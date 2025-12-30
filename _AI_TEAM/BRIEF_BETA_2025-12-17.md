# Brief — Beta em 2 semanas (Nutriz)

## Objetivo
Lançar um **beta** em até 2 semanas para público brasileiro (pt-BR), validando o loop principal do app: meta → 1ª refeição → voltar no D1.

## Foco do beta (MVP)
- Loop: **onboarding/meta → adicionar 1ª refeição rápido → ver “Restantes” → voltar no D1**
- Implementação prática: após o onboarding, ir para o **Diário (home)** e mostrar um CTA destacado “Registrar 1ª refeição” (1 toque abre adicionar alimento).
- “Queimadas” pode ser 0 no beta (sem integrações)

## Contexto
- App Flutter estilo diário alimentar + jejum (inspirado no Yazio)
- Telas já existentes (pelo estado atual): Diário (Resumo + refeições), Jejum (timer + histórico), Receitas, Perfil, Premium/Paywall, entrada de alimento (busca/câmera IA)
- Referências/prints (comparativo Yazio vs Nutriz): `C:\codigos\nutritionapp\imgscodex\Screenshot_695.jpg` … `Screenshot_714.jpg`
- Restrições:
  - Primeira vez criando app
  - Desenvolvimento guiado por IA
  - Evitar “feature creep”
  - Beta pode ter features “desligadas/placeholder”, desde que o core funcione

## Estado atual (observações rápidas)
- UI já está “bem próxima” do Yazio em vários pontos (resumo, cards, navegação inferior).
- Risco: gastar tempo copiando telas e não fechar o ciclo de ativação (onboarding + 1ª refeição) com qualidade.
- Existem telas/copies ainda em inglês em alguns fluxos e elementos que podem ser “cópia direta” demais.

## Pedido
Entregue:
1) 5 melhorias priorizadas (P0/P1/P2) para lançar o beta com qualidade
2) 1 fluxo crítico redesenhado (em passos) para reduzir fricção
3) Checklist de UI (vazios/loading/erro/a11y/microcopy pt-BR)
4) Métrica principal para decidir “lançar / adiar”

## Dados (assumidos se não houver)
- “Queimadas” pode ser 0 no beta
- Banco local (offline-first) é aceitável
- Sem integrações externas obrigatórias no beta
