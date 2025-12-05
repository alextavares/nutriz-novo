# 🧪 Guia Completo de Testes - Measurements Feature

## 📋 Pré-requisitos

### 1. Gerar código (OBRIGATÓRIO)
```bash
cd C:\codigos\nutritionapp\nutriz
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

**⚠️ IMPORTANTE:** Se aparecer erro de `measurement_schemas.g.dart not found`, é porque precisa gerar!

### 2. Verificar erros de compilação
```bash
flutter analyze
```

---

## 🎯 Cenários de Teste

## TESTE 1: Persistência Básica ✅

### Objetivo
Verificar se os dados são salvos e carregados corretamente

### Passos
1. Abrir app
2. Navegar: Diary → Quick Weight Log (clicar no header) → Weight Measurement Page
3. Ajustar peso para **75.0 kg**
4. Clicar **SAVE WEIGHT**
5. Ver toast verde "Weight saved successfully"
6. Fechar app COMPLETAMENTE (matar processo)
7. Reabrir app
8. Navegar novamente para Weight Measurement Page
9. **✅ ESPERADO:** Peso deve estar em **75.0 kg**

### Possíveis Problemas
- ❌ Peso volta para valor padrão → Isar não está salvando
- ❌ App crasha ao abrir → Schema não foi gerado
- ❌ Toast não aparece → Listener não está funcionando

---

## TESTE 2: Gráfico de Progresso 📊

### Objetivo
Verificar se o gráfico aparece e mostra dados corretamente

### Passos
1. Abrir Weight Measurement Page
2. Adicionar 5 medidas diferentes (com intervalos de tempo):
   - Dia 1: 75.0 kg → SAVE
   - Dia 2: 74.5 kg → SAVE
   - Dia 3: 74.0 kg → SAVE
   - Dia 4: 73.8 kg → SAVE
   - Dia 5: 73.5 kg → SAVE

**💡 DICA:** Para simular dias diferentes, você pode modificar temporariamente:
```dart
// Em measurements_repository.dart, linha ~21
..date = DateTime.now().subtract(Duration(days: index))  // Adicionar index
```

3. Após adicionar 2+ medidas, o gráfico deve aparecer
4. **✅ ESPERADO:**
   - Linha azul conectando pontos
   - Pontos brancos com borda
   - Área azul transparente abaixo
   - Datas no eixo X (formato MM/dd)
   - Valores no eixo Y

### Possíveis Problemas
- ❌ Gráfico não aparece → Verificar se `last7Measurements` tem dados
- ❌ Erro ao renderizar → Verificar se `fl_chart` está instalado
- ❌ Pontos não aparecem → Verificar `FlSpot` data

---

## TESTE 3: Histórico de Medidas 📜

### Objetivo
Verificar lista de últimas medidas e função de deletar

### Passos
1. Clicar **ADD MORE** na Weight Page
2. Escolher qualquer medida (ex: Body Fat)
3. Adicionar várias medidas:
   - 25.5% → SAVE
   - 24.8% → SAVE
   - 24.2% → SAVE
4. Reabrir a página de Body Fat
5. **✅ ESPERADO:**
   - Seção "Recent History" aparece
   - Lista mostra as 3 medidas
   - Cada item tem: ícone, valor, data
   - Botão de lixeira em cada item

6. Clicar no ícone de lixeira da primeira medida
7. **✅ ESPERADO:**
   - Item desaparece da lista
   - Lista atualiza automaticamente

### Possíveis Problemas
- ❌ Lista não aparece → Provider não está carregando
- ❌ Deletar não funciona → Repository.deleteMeasurement() com erro
- ❌ Lista não atualiza → Falta `ref.invalidate()`

---

## TESTE 4: Validação de Inputs ✔️

### Objetivo
Verificar se validações impedem dados inválidos

### Cenário 4.1: Campo Vazio
1. Abrir qualquer measurement input
2. Deixar campo vazio
3. Clicar **SAVE**
4. **✅ ESPERADO:** Erro "Please enter a value"

### Cenário 4.2: Não é Número
1. Digitar "abc" ou "xyz"
2. Clicar **SAVE**
3. **✅ ESPERADO:** Erro "Please enter a valid number"

### Cenário 4.3: Peso Muito Baixo
1. Abrir Weight Input
2. Digitar "5"
3. Clicar **SAVE**
4. **✅ ESPERADO:** Erro "Weight must be between 20-300 kg"

### Cenário 4.4: Peso Muito Alto
1. Digitar "999"
2. Clicar **SAVE**
3. **✅ ESPERADO:** Erro "Weight must be between 20-300 kg"

### Cenário 4.5: Porcentagem Inválida
1. Abrir Body Fat
2. Digitar "150"
3. Clicar **SAVE**
4. **✅ ESPERADO:** Erro "Percentage must be between 0-100%"

### Cenário 4.6: Valor Válido
1. Digitar "70.5"
2. Clicar **SAVE**
3. **✅ ESPERADO:** Toast verde, volta para tela anterior

### Possíveis Problemas
- ❌ Validação não funciona → Verificar `_formKey.currentState!.validate()`
- ❌ Aceita valores inválidos → Verificar ranges no `_validateInput()`

---

## TESTE 5: Conversão kg ↔ lb 🔄

### Objetivo
Verificar se conversão de unidades funciona corretamente

### Passos
1. Abrir Weight Measurement Page
2. **Estado inicial:** 70.0 kg
3. Clicar no ícone de unidade (⚖️ ou 🏋️) no AppBar
4. **✅ ESPERADO:** 
   - Valor muda para **154.3 lb** (70 * 2.20462)
   - Ícone muda
   - Label muda para "lb"

5. Ajustar para 160.0 lb
6. Clicar ícone novamente
7. **✅ ESPERADO:**
   - Valor muda para **72.6 kg** (160 / 2.20462)
   - Volta para kg

8. Clicar **SAVE WEIGHT** em lb
9. Ir para histórico
10. **✅ ESPERADO:** Medida salva em lb

### Fórmulas de Verificação
```
kg → lb: valor * 2.20462
lb → kg: valor / 2.20462

Exemplos:
70.0 kg = 154.3 lb
80.0 kg = 176.4 lb
90.0 kg = 198.4 lb

150.0 lb = 68.0 kg
200.0 lb = 90.7 kg
250.0 lb = 113.4 kg
```

### Possíveis Problemas
- ❌ Conversão errada → Verificar fórmula (2.20462)
- ❌ Não salva em lb → Verificar `unit` no `saveMeasurement()`
- ❌ Perde precisão → Usar `toStringAsFixed(1)`

---

## TESTE 6: Tipos de Medidas 📏

### Objetivo
Testar todos os 9 tipos de medidas

### Lista de Testes

| # | Medida | Ícone | Unidade | Range | Helper Text |
|---|--------|-------|---------|-------|-------------|
| 1 | Body Fat | 🧈 | % | 0-100 | "Enter percentage (0-100%)" |
| 2 | Blood Pressure | 🩺 | mmHg | - | "Normal range: 120/80 mmHg" |
| 3 | Blood Glucose | 💉 | mg/dL | 40-600 | "Normal range: 70-100 mg/dL" |
| 4 | Muscle Mass | 💪 | % | 0-100 | "Enter percentage (0-100%)" |
| 5 | Waist | 📏 | cm | 10-200 | "Enter your measurement" |
| 6 | Hips | 📏 | cm | 10-200 | "Enter your measurement" |
| 7 | Chest | 📏 | cm | 10-200 | "Enter your measurement" |
| 8 | Thighs | 📏 | cm | 10-200 | "Enter your measurement" |
| 9 | Upper Arms | 📏 | cm | 10-200 | "Enter your measurement" |

### Para cada medida, testar:
1. ✅ Abre input page
2. ✅ Ícone correto aparece
3. ✅ Label mostra tipo e unidade
4. ✅ Helper text aparece
5. ✅ Validação funciona
6. ✅ Salva corretamente
7. ✅ Aparece no histórico

---

## TESTE 7: Botão SAVE Condicional 🟢

### Objetivo
Verificar que botão SAVE só aparece quando há mudanças

### Passos
1. Abrir Weight Measurement Page
2. **✅ ESPERADO:** Botão "SAVE WEIGHT" NÃO aparece
3. Clicar "+" uma vez
4. **✅ ESPERADO:** Botão "SAVE WEIGHT" APARECE (verde)
5. Clicar "SAVE WEIGHT"
6. **✅ ESPERADO:** Botão DESAPARECE novamente
7. Clicar "-" uma vez
8. **✅ ESPERADO:** Botão APARECE novamente

### Possíveis Problemas
- ❌ Botão sempre visível → `_hasChanges` não está funcionando
- ❌ Botão nunca aparece → Verificar `setState()`

---

## TESTE 8: Feedback Visual 🎨

### Objetivo
Verificar toasts e mensagens

### Cenário 8.1: Salvar com Sucesso
1. Adicionar medida válida
2. Clicar SAVE
3. **✅ ESPERADO:** 
   - Toast verde
   - Mensagem "{Type} saved successfully"
   - Duração 2 segundos

### Cenário 8.2: Erro ao Salvar
1. Simular erro (desconectar DB temporariamente)
2. Tentar salvar
3. **✅ ESPERADO:**
   - Toast vermelho
   - Mensagem "Error saving measurement: ..."

---

## TESTE 9: Navegação Completa 🗺️

### Objetivo
Verificar fluxo completo de navegação

### Fluxo
```
Diary Page
  ↓ (clicar header Quick Weight Log)
Weight Measurement Page
  ↓ (clicar ADD MORE)
Measurements List Page
  ↓ (clicar Body Fat)
Body Fat Input Page
  ↓ (clicar SAVE)
← Volta para Measurements List
  ↓ (back)
← Volta para Weight Measurement
  ↓ (back)
← Volta para Diary
```

### Testar
1. ✅ Todas transições funcionam
2. ✅ Back button funciona em todas telas
3. ✅ Dados persistem ao navegar

---

## TESTE 10: Estados de Carregamento ⏳

### Objetivo
Verificar loading states

### Cenário 10.1: Primeiro Load
1. Limpar dados do app
2. Abrir Weight Page
3. **✅ ESPERADO:** Sem gráfico (pois não há dados)

### Cenário 10.2: Loading Histórico
1. Abrir Input Page com muitos dados
2. **✅ ESPERADO:** 
   - CircularProgressIndicator aparece
   - Depois mostra lista

---

## 🐛 Troubleshooting

### Problema: App não compila
```
ERROR: measurement_schemas.g.dart not found
```
**Solução:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Problema: Isar não salva dados
```
Error: Isar instance is not open
```
**Solução:** Verificar se `MeasurementSchemaSchema` está em `main.dart`:
```dart
final isar = await Isar.open([
  // ...
  MeasurementSchemaSchema,  // ← Adicionar
], directory: dir.path);
```

### Problema: Gráfico não aparece
**Possíveis causas:**
1. Menos de 2 medidas → Adicionar mais
2. `fl_chart` não instalado → `flutter pub get`
3. Dados não carregam → Verificar provider

### Problema: Conversão errada
**Verificar fórmula:**
```dart
// CORRETO
kg → lb: value * 2.20462
lb → kg: value / 2.20462

// ERRADO
kg → lb: value * 2.2  // ❌ Impreciso
lb → kg: value * 0.453592  // ❌ Fórmula inversa
```

### Problema: Validação não funciona
**Verificar:**
1. `_formKey.currentState!.validate()` sendo chamado
2. `validator` configurado no `TextFormField`
3. Ranges corretos no switch/case

---

## ✅ Checklist Final de Testes

### Persistência
- [ ] Salvar medida
- [ ] Fechar e reabrir app
- [ ] Medida ainda está lá
- [ ] Múltiplas medidas persistem

### Gráfico
- [ ] Aparece com 2+ medidas
- [ ] Linha conecta pontos
- [ ] Pontos visíveis
- [ ] Datas no eixo X
- [ ] Valores no eixo Y

### Histórico
- [ ] Lista aparece
- [ ] Mostra últimas 7 medidas
- [ ] Deletar funciona
- [ ] Lista atualiza

### Validação
- [ ] Campo vazio → Erro
- [ ] Texto → Erro
- [ ] Valor muito baixo → Erro
- [ ] Valor muito alto → Erro
- [ ] Valor válido → Sucesso

### Conversão
- [ ] kg → lb funciona
- [ ] lb → kg funciona
- [ ] Salva na unidade correta
- [ ] Histórico mostra unidade

### UI/UX
- [ ] Botão SAVE condicional
- [ ] Toast de sucesso
- [ ] Toast de erro
- [ ] Navegação completa
- [ ] Loading states

---

## 📊 Métricas de Sucesso

### ✅ Feature 100% Funcional Se:
1. Todos 10 testes passam
2. Sem crashes
3. Dados persistem entre sessões
4. Validações impedem dados ruins
5. Conversão precisa (2.20462)
6. UI responsiva e fluida

### ⚠️ Problemas Menores Aceitáveis:
- Animações pouco suaves em devices lentos
- Loading states muito rápidos (bom sinal!)
- Pequenas imprecisões de arredondamento (0.01)

### ❌ Problemas CRÍTICOS:
- Crashes ao abrir
- Perda de dados
- Validações não funcionam
- Conversão errada (fórmula incorreta)

---

## 🚀 Próximo Passo

Após todos testes passarem:

1. Commit código:
```bash
git add .
git commit -m "feat: implement measurements feature with persistence, charts, validation and unit conversion"
```

2. Criar build de teste:
```bash
flutter build apk --debug
```

3. Testar em device físico

4. Coletar feedback de beta testers

5. Iterar melhorias! 🎉
