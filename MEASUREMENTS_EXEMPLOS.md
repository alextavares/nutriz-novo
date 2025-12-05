# 📘 Exemplos de Uso - Measurements API

## 🎯 Casos de Uso Comuns

### 1. Salvar Uma Nova Medida

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        final repo = ref.read(measurementsRepositoryProvider);
        
        await repo.saveMeasurement(
          type: MeasurementType.weight.key,
          value: 72.5,
          unit: 'kg',
        );
        
        // Atualizar providers
        ref.invalidate(measurementsByTypeProvider);
      },
      child: Text('Save Weight'),
    );
  }
}
```

---

### 2. Buscar Última Medida

```dart
// Usando provider
final latestWeight = ref.watch(
  latestMeasurementProvider(MeasurementType.weight.key),
);

latestWeight.when(
  data: (measurement) {
    if (measurement != null) {
      return Text('${measurement.value} ${measurement.unit}');
    }
    return Text('No data');
  },
  loading: () => CircularProgressIndicator(),
  error: (e, s) => Text('Error: $e'),
);

// OU diretamente do repository
final repo = ref.read(measurementsRepositoryProvider);
final measurement = await repo.getLatestMeasurement(
  MeasurementType.weight.key,
);
```

---

### 3. Mostrar Histórico (Últimas 7)

```dart
final history = ref.watch(
  lastNMeasurementsProvider(
    MeasurementQuery(MeasurementType.weight.key, 7),
  ),
);

return history.when(
  data: (measurements) => ListView.builder(
    itemCount: measurements.length,
    itemBuilder: (context, index) {
      final m = measurements[index];
      return ListTile(
        title: Text('${m.value} ${m.unit}'),
        subtitle: Text(DateFormat('MMM dd, yyyy').format(m.date)),
      );
    },
  ),
  loading: () => CircularProgressIndicator(),
  error: (_, __) => Text('Error loading history'),
);
```

---

### 4. Deletar Medida

```dart
IconButton(
  icon: Icon(Icons.delete),
  onPressed: () async {
    final repo = ref.read(measurementsRepositoryProvider);
    await repo.deleteMeasurement(measurementId);
    
    // Refresh
    ref.invalidate(lastNMeasurementsProvider);
    ref.invalidate(measurementsByTypeProvider);
  },
)
```

---

### 5. Buscar Medidas em Range de Datas

```dart
final startDate = DateTime(2025, 1, 1);
final endDate = DateTime(2025, 1, 31);

final measurements = await repo.getMeasurementsInRange(
  type: MeasurementType.weight.key,
  startDate: startDate,
  endDate: endDate,
);

print('Total measurements in January: ${measurements.length}');
```

---

### 6. Obter Estatísticas

```dart
final stats = ref.watch(
  measurementStatsProvider(MeasurementType.weight.key),
);

stats.when(
  data: (stats) => Column(
    children: [
      Text('Count: ${stats.count}'),
      Text('Average: ${stats.average.toStringAsFixed(1)}'),
      Text('Min: ${stats.min}'),
      Text('Max: ${stats.max}'),
      if (stats.trend != 0)
        Text(
          'Trend: ${stats.trend > 0 ? '↑' : '↓'} '
          '${stats.trend.abs().toStringAsFixed(1)} last 7 days',
        ),
    ],
  ),
  loading: () => CircularProgressIndicator(),
  error: (_, __) => Text('No stats available'),
);
```

---

### 7. Atualizar Medida Existente

```dart
await repo.updateMeasurement(
  measurementId,
  value: 73.0,  // Novo valor
  notes: 'After workout',  // Adicionar nota
);

// Refresh providers
ref.invalidate(measurementsByTypeProvider);
```

---

### 8. Converter Unidades (kg ↔ lb)

```dart
// Toggle de unidade
final useMetric = ref.watch(unitPreferenceProvider);

IconButton(
  icon: Icon(
    useMetric ? Icons.monitor_weight : Icons.fitness_center,
  ),
  onPressed: () {
    // Toggle preferência
    ref.read(unitPreferenceProvider.notifier).state = !useMetric;
  },
)

// Converter valor
double convertWeight(double value, bool toMetric) {
  if (toMetric) {
    return value / 2.20462;  // lb → kg
  } else {
    return value * 2.20462;  // kg → lb
  }
}

// Uso
setState(() {
  _currentWeight = convertWeight(_currentWeight, !useMetric);
});
```

---

### 9. Criar Widget de Progress

```dart
class WeightProgressWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(
      measurementStatsProvider(MeasurementType.weight.key),
    );

    return stats.when(
      data: (stats) {
        if (stats.latest == null) {
          return Text('No weight recorded');
        }

        final current = stats.latest!.value;
        final goal = 68.0; // Pegar de settings
        final progress = ((stats.max - current) / (stats.max - goal)) * 100;

        return Column(
          children: [
            LinearProgressIndicator(value: progress / 100),
            Text('${progress.toStringAsFixed(0)}% to goal'),
            Text('Current: ${current.toStringAsFixed(1)} kg'),
            Text('Goal: ${goal.toStringAsFixed(1)} kg'),
            if (stats.trend < 0)
              Text(
                'Great! You lost ${stats.trend.abs().toStringAsFixed(1)} kg',
                style: TextStyle(color: Colors.green),
              ),
          ],
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (_, __) => Text('Error loading progress'),
    );
  }
}
```

---

### 10. Validação Customizada

```dart
String? validateMeasurement(
  String? value,
  MeasurementType type,
) {
  if (value == null || value.isEmpty) {
    return 'Please enter a value';
  }

  final numValue = double.tryParse(value);
  if (numValue == null) {
    return 'Invalid number';
  }

  switch (type) {
    case MeasurementType.weight:
      if (numValue < 20 || numValue > 300) {
        return 'Weight must be between 20-300';
      }
      break;
    
    case MeasurementType.bodyFat:
    case MeasurementType.muscleMass:
      if (numValue < 0 || numValue > 100) {
        return 'Percentage must be between 0-100';
      }
      break;
    
    case MeasurementType.bloodGlucose:
      if (numValue < 40 || numValue > 600) {
        return 'Invalid blood glucose level';
      }
      break;
    
    default:
      if (numValue < 0) {
        return 'Value must be positive';
      }
  }

  return null; // Valid
}
```

---

### 11. Criar Gráfico Personalizado

```dart
import 'package:fl_chart/fl_chart.dart';

class CustomMeasurementChart extends StatelessWidget {
  final List<Measurement> measurements;
  final Color color;

  const CustomMeasurementChart({
    required this.measurements,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    if (measurements.length < 2) {
      return Text('Need at least 2 measurements');
    }

    final spots = measurements.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.value,
      );
    }).toList();

    return Container(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= measurements.length) {
                    return SizedBox.shrink();
                  }
                  final date = measurements[value.toInt()].date;
                  return Text(
                    DateFormat('MM/dd').format(date),
                    style: TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: color,
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: color.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 12. Stream de Mudanças (Real-time)

```dart
// Para ouvir mudanças em tempo real
class MeasurementListener extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Refresh a cada 5 segundos
    ref.listen(
      measurementsByTypeProvider(MeasurementType.weight.key),
      (previous, next) {
        next.whenData((measurements) {
          if (measurements.isNotEmpty) {
            final latest = measurements.first;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('New weight: ${latest.value} ${latest.unit}'),
              ),
            );
          }
        });
      },
    );

    return Container();
  }
}
```

---

### 13. Export para CSV

```dart
Future<String> exportMeasurementsToCSV(
  List<Measurement> measurements,
) async {
  final buffer = StringBuffer();
  
  // Header
  buffer.writeln('Date,Type,Value,Unit,Notes');
  
  // Rows
  for (final m in measurements) {
    buffer.writeln(
      '${DateFormat('yyyy-MM-dd').format(m.date)},'
      '${m.type},'
      '${m.value},'
      '${m.unit},'
      '${m.notes ?? ''}'
    );
  }
  
  return buffer.toString();
}

// Uso
final measurements = await repo.getMeasurementsByType(
  MeasurementType.weight.key,
);
final csv = await exportMeasurementsToCSV(measurements);

// Salvar arquivo
final file = File('${directory.path}/measurements.csv');
await file.writeAsString(csv);
```

---

### 14. Notificação de Milestone

```dart
Future<void> checkMilestone(Measurement newMeasurement) async {
  final repo = ref.read(measurementsRepositoryProvider);
  final all = await repo.getMeasurementsByType(
    MeasurementType.weight.key,
  );

  if (all.length == 10) {
    // 10ª medida!
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🎉 Milestone!'),
        content: Text('You\'ve logged 10 weight measurements!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  // Check goal
  final goal = 68.0;
  if (newMeasurement.value <= goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🎯 Goal Achieved!'),
        content: Text('You reached your weight goal!'),
      ),
    );
  }
}
```

---

### 15. Comparação de Períodos

```dart
Future<Map<String, double>> comparePeriods() async {
  final repo = ref.read(measurementsRepositoryProvider);
  
  // Última semana
  final lastWeek = await repo.getMeasurementsInRange(
    type: MeasurementType.weight.key,
    startDate: DateTime.now().subtract(Duration(days: 7)),
    endDate: DateTime.now(),
  );
  
  // Semana anterior
  final previousWeek = await repo.getMeasurementsInRange(
    type: MeasurementType.weight.key,
    startDate: DateTime.now().subtract(Duration(days: 14)),
    endDate: DateTime.now().subtract(Duration(days: 7)),
  );
  
  final lastWeekAvg = lastWeek.isEmpty 
    ? 0.0 
    : lastWeek.map((m) => m.value).reduce((a, b) => a + b) / lastWeek.length;
  
  final previousWeekAvg = previousWeek.isEmpty 
    ? 0.0 
    : previousWeek.map((m) => m.value).reduce((a, b) => a + b) / previousWeek.length;
  
  final change = lastWeekAvg - previousWeekAvg;
  
  return {
    'lastWeekAvg': lastWeekAvg,
    'previousWeekAvg': previousWeekAvg,
    'change': change,
  };
}
```

---

## 🎓 Conceitos Importantes

### Provider vs Repository

**Use Repository quando:**
- Operações síncronas (dentro de callbacks)
- Múltiplas operações em sequência
- Dentro de métodos assíncronos

**Use Provider quando:**
- Build de widgets
- Reatividade automática
- Cache de dados

### Invalidação de Providers

Sempre invalidar após mudanças:
```dart
ref.invalidate(measurementsByTypeProvider);
ref.invalidate(latestMeasurementProvider);
ref.invalidate(lastNMeasurementsProvider);
ref.invalidate(measurementStatsProvider);
```

### Tratamento de Erros

```dart
try {
  await repo.saveMeasurement(...);
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Error: $e'),
      backgroundColor: Colors.red,
    ),
  );
}
```

---

## 🚀 Integração com Outras Features

### Com Gamification

```dart
// Ganhar XP ao salvar medida
await repo.saveMeasurement(...);
await ref.read(gamificationProvider).addXP(5);
```

### Com Diary

```dart
// Mostrar peso do dia no diary
final todayWeight = await repo.getMeasurementsInRange(
  type: MeasurementType.weight.key,
  startDate: DateTime.now().startOfDay,
  endDate: DateTime.now().endOfDay,
);
```

### Com Profile

```dart
// Sincronizar goal
final profileGoal = ref.watch(profileProvider).goalWeight;
// Usar no cálculo de progresso
```

---

## 📚 Recursos Adicionais

- [fl_chart Documentation](https://pub.dev/packages/fl_chart)
- [Isar Documentation](https://isar.dev/)
- [Riverpod Best Practices](https://riverpod.dev/)

---

## ✅ Checklist de Integração

Ao usar Measurements em sua feature:

- [ ] Import correto dos providers
- [ ] Invalidação após save/delete
- [ ] Tratamento de loading states
- [ ] Tratamento de erros
- [ ] Validação de inputs
- [ ] Conversão de unidades (se necessário)
- [ ] Formatação de datas
- [ ] UI responsiva

---

**🎉 Agora você está pronto para usar o sistema de Measurements!**
