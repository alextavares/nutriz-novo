# 🚀 Guia Rápido - Testar Melhorias do Nutriz

## Passo 1: Verificar que está tudo OK

```bash
cd C:\codigos\nutritionapp\nutriz
flutter doctor
```

## Passo 2: Limpar build anterior

```bash
flutter clean
flutter pub get
```

## Passo 3: Rodar o app

### Opção A - Emulador Android
```bash
flutter run
```

### Opção B - Device físico conectado
```bash
flutter devices
flutter run -d <device-id>
```

### Opção C - Hot Reload durante desenvolvimento
```bash
# Após rodar o app, use:
# r - para hot reload
# R - para hot restart
# q - para sair
```

## 📱 Checklist de Testes

### ✅ Daily Summary Header
- [ ] Anel de calorias está GRANDE (200x200px)?
- [ ] Valor "Remaining" está em destaque?
- [ ] Stats "Eaten" e "Burned" aparecem lado a lado?
- [ ] Banner de "Now: Fasting" tem gradiente laranja?

### ✅ Meal Sections
- [ ] Cards mostram progresso (205/600)?
- [ ] Barra de progresso aparece com cor adequada?
- [ ] Badge "X items" aparece quando há alimentos?
- [ ] Ícones de alimentos são contextuais?
- [ ] Botão + está destacado (azul com sombra)?

### ✅ Water Tracker
- [ ] 8 copos aparecem na horizontal?
- [ ] Copos preenchem com animação ao clicar?
- [ ] Display mostra "2.00 L" ou atual?
- [ ] Botões +250ml e +500ml funcionam?
- [ ] "Goal: 2.00 Liters" está visível?

### ✅ Quick Weight Log
- [ ] Botões +/- ajustam o peso de 0.1 em 0.1?
- [ ] Indicador ↑↓ aparece ao mudar peso?
- [ ] Cor muda (verde=perda, vermelho=ganho)?
- [ ] Barra de progresso mostra start → goal?
- [ ] Botão "Save Weight" aparece quando há mudança?

## 🐛 Debug Comum

### Problema: Widget não aparece
```bash
# Hot restart
flutter run --hot

# Ou aperte "R" no terminal
```

### Problema: Erro de import
```dart
// Verificar se todos os imports estão corretos
import '../widgets/meal_section_improved.dart';
import '../widgets/water_tracker_card_improved.dart';
import '../widgets/daily_summary_header_improved.dart';
import '../widgets/quick_weight_log_card.dart';
```

### Problema: Performance lenta
```bash
# Rodar em modo release
flutter run --release
```

## 📸 Tirar Screenshots

### Android
```bash
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png
```

### iOS Simulator
```bash
# Cmd + S no simulator
# Ou
xcrun simctl io booted screenshot screenshot.png
```

## 🎨 Ajustar Cores/Espaçamentos

Arquivos principais:
- `lib/core/constants/app_colors.dart` - Cores
- `lib/core/constants/app_spacing.dart` - Espaçamentos

## 🔥 Hot Reload vs Hot Restart

**Hot Reload (r):** Atualiza UI sem perder estado
**Hot Restart (R):** Reinicia app, reseta estado
**Full Restart:** Fecha e abre app novamente

Use R se:
- Mudou constantes
- Mudou enums
- Mudou initState
- Widget não atualizou com r

## 📊 Ver Logs

```bash
# Todos os logs
flutter logs

# Filtrar por tag
flutter logs | grep "NUTRIZ"

# Limpar console
cls  # Windows
clear  # Mac/Linux
```

## 🎯 Testar Funcionalidades Específicas

### Adicionar Alimento
1. Navegar para Diary
2. Clicar no botão + em uma refeição
3. Buscar e adicionar alimento
4. Verificar se aparece no card
5. Conferir se barra de progresso atualiza

### Adicionar Água
1. Clicar nos copos vazios (devem preencher)
2. Usar botão +250ml
3. Verificar animação
4. Confirmar que litros atualizam

### Ajustar Peso
1. Usar botões +/-
2. Ver indicador de mudança
3. Clicar em "Save Weight"
4. (TODO: Implementar save real)

## 🚨 Se algo der errado

```bash
# 1. Limpar tudo
flutter clean
rm -rf build/  # ou del /s /q build\ no Windows

# 2. Atualizar dependências
flutter pub get
flutter pub upgrade

# 3. Verificar erros
flutter analyze

# 4. Rodar novamente
flutter run
```

## 💻 Desenvolvimento Contínuo

### Fluxo de trabalho ideal:
1. Fazer mudança no código
2. Salvar arquivo (Ctrl+S)
3. Verificar se hot reload automático funcionou
4. Se não, apertar "r" no terminal
5. Testar mudança no app
6. Repetir

### Dicas:
- Use `debugPrint()` para logs
- Use Flutter DevTools para debug visual
- Use breakpoints no VS Code
- Teste em múltiplos dispositivos

## 📝 Próximos Testes

Após confirmar que tudo funciona:
1. Testar com dados reais (adicionar vários alimentos)
2. Testar scroll performance
3. Testar em device físico
4. Testar em diferentes resoluções
5. Tirar screenshots para comparação

## ✅ Resultado Esperado

Você deve ver:
- ✅ Cards de refeição com progresso visual
- ✅ Water tracker com 8 copos
- ✅ Anel de calorias grande e destacado
- ✅ Quick weight log funcional
- ✅ Animações suaves
- ✅ Interface limpa e moderna

Se tudo funcionar, partimos para o Sprint 2! 🎉
