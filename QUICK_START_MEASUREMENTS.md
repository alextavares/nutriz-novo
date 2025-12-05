# ⚡ Quick Start - Measurements Feature

## 🚀 Setup Rápido (5 minutos)

```bash
# 1. Limpar e pegar dependências
cd C:\codigos\nutritionapp\nutriz
flutter clean
flutter pub get

# 2. Gerar código (OBRIGATÓRIO!)
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Verificar erros
flutter analyze

# 4. Rodar app
flutter run
```

---

## 🧪 Teste Rápido (2 minutos)

```bash
# 1. Abrir app
# 2. Diary → Quick Weight Log (clicar header)
# 3. Ajustar peso → SAVE
# 4. Ver toast verde ✅
# 5. Adicionar mais 2 medidas
# 6. Ver gráfico aparecer 📊
```

---

## 📝 Comandos Úteis

### Build Runner
```bash
# Gerar arquivos
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerar)
flutter pub run build_runner watch --delete-conflicting-outputs

# Limpar gerados
flutter pub run build_runner clean
```

### Flutter
```bash
# Hot reload
r

# Hot restart
R

# Limpar tudo
flutter clean && flutter pub get

# Ver logs
flutter logs

# Build debug
flutter build apk --debug

# Build release
flutter build apk --release
```

### Análise
```bash
# Verificar issues
flutter analyze

# Formatar código
dart format .

# Métricas
flutter pub run dart_code_metrics:metrics analyze lib
```

---

## 🐛 Fixes Rápidos

### Erro: "measurement_schemas.g.dart not found"
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Erro: "Isar schema not found"
```dart
// Adicionar em main.dart
MeasurementSchemaSchema,
```

### Erro: "Provider not found"
```dart
// Adicionar override
overrides: [
  isarProvider.overrideWithValue(isar),
]
```

### Gráfico não aparece
```bash
# Verificar fl_chart
flutter pub get
# Adicionar mais medidas (mínimo 2)
```

---

## 📂 Arquivos Principais

```
measurements/
├── data/
│   ├── models/measurement_schemas.dart     ← Schema Isar
│   └── repositories/measurements_repository.dart  ← CRUD
├── domain/entities/measurement.dart         ← Entity
└── presentation/
    ├── pages/
    │   ├── weight_measurement_page.dart    ← Main page
    │   ├── measurements_page.dart          ← Lista
    │   └── measurement_input_page.dart     ← Input
    └── providers/measurements_providers.dart  ← Riverpod
```

---

## 🎯 Features Checklist

### Testar
- [ ] Salvar peso
- [ ] Ver gráfico
- [ ] Ver histórico
- [ ] Deletar medida
- [ ] Toggle kg/lb
- [ ] Validação
- [ ] Fechar/reabrir app

### Implementado
- [x] Persistência Isar
- [x] Gráfico fl_chart
- [x] Histórico
- [x] Validação
- [x] Conversão kg/lb
- [x] 9 tipos de medidas
- [x] Delete
- [x] Stats

---

## 📊 Tipos de Medidas

| Tipo | Ícone | Unidade | Range |
|------|-------|---------|-------|
| Weight | ⚖️ | kg/lb | 20-300 |
| Body Fat | 🧈 | % | 0-100 |
| Blood Pressure | 🩺 | mmHg | - |
| Blood Glucose | 💉 | mg/dL | 40-600 |
| Muscle Mass | 💪 | % | 0-100 |
| Waist | 📏 | cm | 10-200 |
| Hips | 📏 | cm | 10-200 |
| Chest | 📏 | cm | 10-200 |
| Thighs | 📏 | cm | 10-200 |
| Upper Arms | 📏 | cm | 10-200 |

---

## 🔧 Código Útil

### Salvar Medida
```dart
await ref.read(measurementsRepositoryProvider).saveMeasurement(
  type: MeasurementType.weight.key,
  value: 72.5,
  unit: 'kg',
);
ref.invalidate(measurementsByTypeProvider);
```

### Buscar Última
```dart
final latest = ref.watch(
  latestMeasurementProvider(MeasurementType.weight.key),
);
```

### Ver Histórico
```dart
final history = ref.watch(
  lastNMeasurementsProvider(
    MeasurementQuery(MeasurementType.weight.key, 7),
  ),
);
```

### Deletar
```dart
await repo.deleteMeasurement(id);
ref.invalidate(lastNMeasurementsProvider);
```

### Toggle Unidade
```dart
ref.read(unitPreferenceProvider.notifier).state = !useMetric;
```

---

## 📖 Documentação

| Arquivo | Para Quem | Conteúdo |
|---------|-----------|----------|
| RESUMO_EXECUTIVO_MEASUREMENTS.md | Product/PM | Visão geral executiva |
| MEASUREMENTS_COMPLETO.md | Devs/QA | Detalhes técnicos |
| GUIA_TESTES_MEASUREMENTS.md | QA | Cenários de teste |
| MEASUREMENTS_EXEMPLOS.md | Devs | Exemplos de código |
| QUICK_START.md | Todos | Este arquivo |

---

## ⏱️ Tempos Estimados

| Atividade | Tempo |
|-----------|-------|
| Setup inicial | 5 min |
| Teste rápido | 2 min |
| Teste completo | 30 min |
| Ler docs completas | 1 hora |
| Implementar nova feature | 2-4 horas |

---

## 🎓 Recursos

### Interno
- `MEASUREMENTS_EXEMPLOS.md` - 15 exemplos
- `GUIA_TESTES_MEASUREMENTS.md` - 10 cenários
- `MEASUREMENTS_COMPLETO.md` - Arquitetura

### Externo
- [fl_chart](https://pub.dev/packages/fl_chart)
- [Isar](https://isar.dev/)
- [Riverpod](https://riverpod.dev/)
- [Freezed](https://pub.dev/packages/freezed)

---

## ✅ Checklist de Deploy

### Pré-Deploy
- [ ] Testes manuais passam
- [ ] Build sem erros
- [ ] Analyze sem warnings
- [ ] Documentação atualizada
- [ ] Performance OK

### Deploy
- [ ] Merge PR
- [ ] Tag versão
- [ ] Build release
- [ ] Upload store
- [ ] Monitor crashes

### Pós-Deploy
- [ ] Validar produção
- [ ] Coletar feedback
- [ ] Monitorar métricas
- [ ] Planejar v2

---

## 🚨 SOS

### App não compila
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Dados não salvam
```dart
// Verificar main.dart
MeasurementSchemaSchema,  // ← Está aqui?
```

### Gráfico quebra
```bash
# Verificar dependência
flutter pub get
# Adicionar mais dados (min 2)
```

### Performance ruim
```bash
# Profile mode
flutter run --profile
# Identificar bottlenecks
```

---

## 🎉 Pronto!

Agora você pode:
- ✅ Rodar o app
- ✅ Testar features
- ✅ Ver documentação
- ✅ Desenvolver novas features

**Next:** Ver `MEASUREMENTS_EXEMPLOS.md` para mais exemplos!

---

**Última atualização:** 03/12/2025  
**Versão:** 1.0.0
