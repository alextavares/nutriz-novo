# Screenshot Capture Runbook BR

## Objetivo

Produzir 5 screenshots de loja sem designer e sem depender de adivinhacao.

Este documento usa as rotas reais do app e sugere:
- qual tela abrir
- que estado preparar
- o que enquadrar
- o que cortar

## Regras gerais

- capturar em pt-BR
- usar dados coerentes entre telas
- preferir fundo claro
- evitar banners promocionais ou estados quebrados
- se algo poluir a tela, recapturar com crop melhor

## Dados recomendados para os prints

Use este perfil como referencia:
- calorias: `1850 kcal`
- proteina: `122 g`
- carboidratos: `185 g`
- gorduras: `62 g`

Use estas refeicoes de exemplo:
- almoco: `120 g peito de frango grelhado`
- almoco: `100 g arroz branco`
- almoco: `80 g feijao`
- lanche: `1 iogurte grego`

## Screenshot 1

### Mensagem

Headline:
`Emagreca sem complicacao`

Subheadline:
`Sua meta personalizada em poucos passos`

### Tela

Tela ideal:
- resultado do onboarding

Arquivo relacionado:
- `lib/features/onboarding/presentation/pages/onboarding_page.dart`

### Como abrir

Nao existe rota direta publica para essa etapa.

Fluxo:
1. abrir o app em estado sem onboarding concluido
2. responder onboarding com dados simples
3. chegar na tela `Sua meta de hoje esta pronta`

### O que enquadrar

- titulo da tela
- numeros de calorias e proteina
- CTA `Registrar minha 1ª refeicao`

### O que cortar

- qualquer texto que fique muito abaixo da dobra
- sistema, notch ou elementos irrelevantes

## Screenshot 2

### Mensagem

Headline:
`Veja o que falta hoje`

Subheadline:
`Acompanhe calorias, proteina e restantes`

### Tela

Rota:
`/diary?firstRun=1`

Arquivos relacionados:
- `lib/features/diary/presentation/pages/diary_page.dart`
- `lib/features/diary/presentation/widgets/daily_summary_header_improved.dart`

### Como abrir

1. concluir onboarding
2. cair em `/diary?firstRun=1`
3. manter o dia vazio

### O que enquadrar

- header verde
- card central com calorias restantes
- macros/proteina
- CTA da primeira refeicao

### O que cortar

- parte baixa do diario se estiver vazia demais
- qualquer snackbar

## Screenshot 3

### Mensagem

Headline:
`Registre refeicoes em segundos`

Subheadline:
`Busque alimentos, ajuste porcoes e salve rapido`

### Tela

Rota:
`/food-search/lunch?tab=search&focus=1`

Arquivo relacionado:
- `lib/features/diary/presentation/pages/add_food_page.dart`

### Como abrir

1. no diario, tocar em adicionar refeicao
2. abrir busca do almoco
3. digitar uma busca simples:
   - `frango`
   - `arroz`
   - `iogurte`

### O que enquadrar

Opção A:
- campo de busca
- lista de resultados

Opção B:
- tela de porcao depois de selecionar um alimento

Minha recomendacao:
- use a Opcao A se a busca estiver bonita
- use a Opcao B se a lista estiver fraca

### O que cortar

- tabs irrelevantes
- teclado, se estiver atrapalhando

## Screenshot 4

### Mensagem

Headline:
`Mais consistencia, menos neura`

Subheadline:
`Entenda melhor sua alimentacao ao longo do dia`

### Tela

Rota:
`/diary`

Arquivo relacionado:
- `lib/features/diary/presentation/pages/diary_page.dart`

### Como abrir

1. adicionar pelo menos 2 refeicoes no dia
2. voltar ao diario
3. garantir que o resumo esteja com progresso visivel

### O que enquadrar

- header do diario
- refeicoes preenchidas
- sensacao de dia em andamento

### O que cortar

- se o banner de desafio crescer demais, enquadrar abaixo dele
- blocos secundarios que roubem a atencao

### Dica

Se o banner do desafio estiver muito forte:
- capture mais baixo, priorizando resumo + lista de refeicoes

## Screenshot 5

### Mensagem

Headline:
`Desbloqueie o Premium`

Subheadline:
`IA por foto e menos friccao no dia a dia`

### Tela

Rota preferida:
`/premium`

Rotas alternativas:
- `/premium/paywall`
- `/premium/offer`

Arquivos relacionados:
- `lib/features/premium/presentation/pages/premium_screen.dart`
- `lib/features/premium/presentation/pages/hard_paywall_screen.dart`
- `lib/features/premium/presentation/pages/offer_paywall_screen.dart`

### Como abrir

1. abrir `/premium`
2. deixar o anual selecionado
3. mostrar `Ativar 7 dias gratis`

### O que enquadrar

- headline
- beneficios principais
- anual em destaque
- CTA principal

### O que cortar

- termos legais longos
- excesso de rodape

## Ordem de captura recomendada

1. onboarding resultado
2. diario vazio com restantes
3. busca de alimento
4. diario preenchido
5. premium

## Checklist final

- headline legivel em todas
- UI real do app
- sem ingles
- sem countdown
- sem dados absurdos
- sem placeholders
- cor verde consistente

## Atalho de checagem

Antes de exportar, pergunte:

1. Essa screenshot explica uma ideia em menos de 2 segundos?
2. A UI sozinha ajuda a vender o app?
3. Isso parece app pago de verdade ou prototipo?
