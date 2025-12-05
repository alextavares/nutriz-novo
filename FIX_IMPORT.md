# 🔧 Fix: Import WaterTrackerConnected

## ❌ ERRO:
```
Error: The method 'WaterTrackerConnected' isn't defined for the type 'DiaryPage'.
```

## ✅ CAUSA:
Faltava importar o widget `WaterTrackerConnected` na `diary_page.dart`

## ✅ SOLUÇÃO:
Adicionado import:
```dart
import '../widgets/water_tracker_connected.dart';
```

## 📍 ARQUIVO CORRIGIDO:
`lib/features/diary/presentation/pages/diary_page.dart`

## ✅ STATUS:
Compilando novamente...

---

**Aguardando build terminar...**
