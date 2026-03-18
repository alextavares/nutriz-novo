# Nutriz: Checklist Final de Release

## 1. Build e estabilidade

- Abrir o app do zero
- Fechar e abrir novamente
- Confirmar que nao existe tela quebrada, texto corrompido ou loading infinito
- Confirmar que a tela de Plano abre sem piscar

## 2. Fluxo principal

- Fazer onboarding completo
- Confirmar que a tela de resultado mostra a meta e o CTA sem depender de scroll
- Tocar em `Registrar minha 1ª refeicao`
- Confirmar que o diario abre normalmente
- Confirmar que o card de primeira refeicao aparece corretamente
- Tocar em `Adicionar alimento`
- Buscar um alimento comum como `arroz`
- Registrar a refeicao
- Voltar ao diario e validar:
  - calorias atualizadas
  - macros atualizados
  - refeicao aparece na secao correta

## 3. Busca de alimentos

- Buscar `arroz`
- Buscar `frango`
- Buscar um alimento menos comum
- Confirmar que resultados locais aparecem rapido
- Confirmar que a busca nao trava por 3 a 5 segundos

## 4. Peso

- Registrar peso
- Voltar ao diario
- Confirmar que o peso atual foi salvo corretamente
- Fechar e abrir o app
- Confirmar que o peso continua correto

## 5. Monetizacao

- Abrir a tela Premium
- Confirmar que anual e mensal aparecem
- Confirmar que os precos carregam
- Confirmar que o CTA de compra aparece corretamente
- Testar compra sandbox
- Testar restore
- Confirmar que o entitlement `premium` ativa no app

## 6. Paywalls

- Tentar abrir IA por foto
- Confirmar que o hard paywall abre
- Confirmar que o paywall contextual esta coerente
- Confirmar que o usuario nao cai em paywall duro antes do primeiro valor

## 7. Conteudo da loja

- Revisar titulo
- Revisar descricao curta
- Revisar descricao longa
- Revisar screenshots finais
- Revisar icone
- Garantir que a loja promete o que o app entrega hoje

## 8. Analytics minimo

- Confirmar eventos:
  - `onboarding_complete`
  - `first_meal_cta_tap`
  - `meal_item_added`
  - `paywall_view`
  - `purchase_start`
  - `purchase_complete`

## 9. Go / No-Go

### Go

- Fluxo principal funciona
- Busca esta aceitavel
- Precos aparecem
- Compra funciona
- Restore funciona
- Premium ativa corretamente

### No-Go

- Precos nao aparecem
- Compra falha
- Restore falha
- Plano continua piscando
- Fluxo onboarding -> primeira refeicao quebra
