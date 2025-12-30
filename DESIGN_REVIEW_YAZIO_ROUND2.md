# Review de UI (Rounds 2–3) — Referência: Yazio (sem copiar pixel a pixel)

## Objetivo
Usar o Yazio como benchmark de padrões que funcionam (hierarquia, legibilidade, densidade de informação), mantendo identidade própria do Nutriz.

## O que já foi aplicado (Round 2)
- Tokens básicos de UI: `AppColors.border` e `AppColors.shadow`.
- Bottom nav mais “silencioso” e com destaque no verde (marca Nutriz), mantendo dourado apenas para Premium.
- `SectionHeader` para unificar títulos de seção + ação (“Detalhes/Ver mais”).
- Copy PT-BR no topo do Diário (Hoje/Ontem/Amanhã + “Semana X”).
- Ajustes visuais no Water/Weight para um look mais “flat premium”.
- Notas (“Diário do dia”) com ação **Salvar no header** quando expandido (sem precisar rolar até o fim).

## Observações (Round 3) — Tela inicial (Nutriz vs. Yazio)
1) **Hierarquia do topo**
   - Yazio dá foco primeiro no contexto (dia/semana) e depois no card principal.
   - No Nutriz, o topo ainda pode ficar mais “limpo” (menos ruído nos ícones) e com alinhamento mais consistente (título, subtítulo e ações).

2) **Resumo (card principal)**
   - O Yazio reduz o ruído visual e evidencia 1 métrica principal (calorias restantes) com secundárias discretas.
   - No Nutriz, o Resumo ainda pode ganhar: (a) maior contraste do número principal, (b) mais respiro, (c) componentes secundários mais compactos.

3) **Densidade dos cards (Nutrição/Água/Medidas)**
   - O Yazio é mais “denso” sem ficar apertado: menos altura por item e ações pequenas (+, “Ver mais”).
   - No Nutriz, alguns blocos ainda ocupam muita altura (especialmente quando há botões grandes).

4) **Ação principal sempre visível**
   - A ação mais provável deve estar sempre acessível (ex.: adicionar refeição, salvar nota).
   - Ajuste feito para Notas; vale aplicar o mesmo pensamento em outras áreas (ex.: ação “+” por refeição com boa previsibilidade).

## Próximo plano de melhoria (Round 3)
1) **Refinar o topo do Diário**
   - Padronizar tamanho/espessura do título e subtítulo.
   - Consolidar ações em 1–2 ícones (ex.: perfil + notificações) com espaçamento fixo.
   - Arquivo-alvo: `lib/features/diary/presentation/pages/diary_page.dart`.

2) **Resumo mais profissional (sem copiar o Yazio)**
   - Dar mais destaque ao número principal e reduzir peso visual de anéis/ornamentos.
   - Trocar indicadores secundários para uma versão mais “leve” (barras finas ou chips), mantendo identidade do Nutriz.
   - Arquivo-alvo: `lib/features/diary/presentation/widgets/daily_summary_header_improved.dart`.

3) **Nutrição com menos altura por item**
   - List-style: linhas mais compactas por refeição, com “+” circular e meta/consumo como secundário.
   - Arquivo-alvo: `lib/features/diary/presentation/widgets/meal_section_improved.dart`.

4) **Unificar estilo de card**
   - Criar um wrapper simples (ex.: `AppCard`) para raio/sombra/borda consistentes.
   - Aplicar primeiro em Água/Medidas/Notas para reduzir variação visual.

5) **Microcopy e consistência PT-BR**
   - Garantir “Ver mais/Detalhes” coerente por seção.
   - Revisar strings restantes em inglês/abreviações e padronizar capitalização.

## Atualização (Round 4) — Tela de Receitas (Nutriz vs. Yazio)
### O que foi aplicado
- Tab `DESCOBRIR/FAVORITAS` com AppBar limpo + ações de busca/filtro (SnackBar “em breve”).
- Busca “fake” (card clicável) para manter padrão e já preparar integração futura.
- Categorias em “chips” (mais compacto e moderno, menos sombra).
- Cards com sombra mais leve + blobs de fundo (subtileza sem imitar o Yazio).
- “Coleções” com cards de foto (grid) e pill de contagem no topo da imagem.

### Próximos passos (se fizer sentido)
1) Substituir imagens temporárias (Unsplash) por imagens da API/DB (ou assets próprios).
2) Implementar busca real + filtros (diet, calorias, tempo de preparo).
3) Adicionar seção “Em destaque” com receitas reais (cards com foto + kcal + macros).

### Sugestões de API de receitas
- **Spoonacular**: muito completa (busca, filtros, info nutricional). Boa para produção, mas geralmente paga/limitada.
- **Edamam Recipe Search**: forte em nutrição/labels (diet/health), também tende a ser paga.
- **TheMealDB**: simples e barata para protótipo (menos focada em nutrição).
- **Open Food Facts** (complemento): ótimo para base de alimentos e rótulos; não é “receita” por si só.

## Atualização (Round 5) — Perfil (Nutriz vs. Yazio)
### O que foi aplicado
- AppBar mais “pro” (Perfil + ações Ajuda/Configurações) e copy PT-BR.
- Card de usuário com chips (Objetivo/Preferência/Atividade) e mini-stats (calorias/macros/altura/meta).
- Card “Meu progresso” com distância até a meta + estimativa (semanas/data) + barra.
- “Minhas metas” em lista limpa (sem ruído de botões grandes).
- Configurações agrupadas em um card (Conta/Lembretes/Unidades/Ajuda).

### Próximos passos (opcional)
1) Trocar placeholders de nome/foto por dados reais do perfil quando existirem.
2) Implementar telas reais de “Conta”, “Unidades”, “Lembretes”, “Configurações”.
3) Integrar “Rastreamento automático” (Google Fit/Health Connect) quando fizer sentido.

## Atualização (Round 6) — Adicionar alimentos (Nutriz vs. Yazio)
### O que foi aplicado
- `AddFoodPage` com background neutro + AppBar “pro” e tabs inferiores (CÂMERA IA / BUSCAR).
- Aba **Buscar**: campo de busca em card, categorias em tiles (Alimentos/Refeições/Receitas), sub-tabs em container, lista com cards + pills de macros, CTA “Concluído” fixo.
- Aba **Câmera com IA**: card de feature + privacidade, CTA “Tirar foto”/“Galeria”, sheet de origem com visual consistente.
- `FoodDetailSheet` com kcal em destaque, stepper +/- e CTA “Adicionar ao diário” (caller decide fechar).
- Busca vazia agora mostra itens locais “populares” na aba **Frequentes** (melhor primeira experiência).

### Próximos passos (opcional)
1) Debounce na busca para reduzir chamadas de rede.
2) Implementar Recentes/Favoritos reais (persistência local).
3) Integrar “Código de barras” na UI (método já existe no `FoodService`).
4) Se quiser monetizar: gatear IA / barcode em `/premium` com CTA claro.
