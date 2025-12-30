# Processo de trabalho (simples e repetível)

## 1) Abrir um brief
- Copie `personas/00_BRIEF_TEMPLATE.md`
- Preencha com objetivo + prints + restrições + arquivos alvo (se souber)

## 2) Chamar o expert certo (regra prática)
- **Prioridade, layout, onboarding, copy, retenção** -> `01_PRODUTO_UX_UI.md`
- **Estrutura de código, performance, estado, pastas** -> `02_FLUTTER_ARQUITETURA.md`
- **Regras de cálculo, metas, macros, jejum** -> `03_LOGICA_PERSONALIZACAO.md`
- **Testes, eventos, funil, estabilidade** -> `04_QA_ANALYTICS.md`
- **ASO, screenshots, lançamento, monetização** -> `05_GROWTH_ASO_MONETIZACAO.md`

## 3) Transformar output em tarefas
- Pegue a lista numerada que o expert devolver
- Quebre em itens pequenos no `KANBAN.md` (P0/P1/P2)
- Se for mudança de padrão/arquitetura/métrica, registre em `DECISIONS.md`

## 4) Quando registrar uma decisão
Registre em `DECISIONS.md` quando:
- muda cálculo (restantes, metas, macros, jejum)
- muda padrões de UI/UX globais (componentes, navegação, i18n)
- muda arquitetura (camadas, providers, persistência)
- muda eventos/métricas (nomes, propriedades, funis)

## 5) Script curto (cole no chat)
Substitua os campos:

“Aja como **{EXPERT}**.
Objetivo: {OBJETIVO}
Contexto: {TELA/FLUXO} • {RESTRIÇÕES}
Evidência: {PRINTS/LINKS}
Arquivos alvo: {ARQUIVOS}
Entregue: tarefas numeradas + critérios de aceite + não fazer agora.
Se necessário, atualize `KANBAN.md` e/ou `DECISIONS.md`.”

