import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/measurements_providers.dart';
import '../../data/models/measurement_schemas.dart';
import 'measurements_page.dart';

class WeightMeasurementPage extends ConsumerStatefulWidget {
  const WeightMeasurementPage({super.key});

  @override
  ConsumerState<WeightMeasurementPage> createState() =>
      _WeightMeasurementPageState();
}

class _WeightMeasurementPageState extends ConsumerState<WeightMeasurementPage> {
  double _currentWeight = 72.5;
  final double _goalWeight = 68.0;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadLatestWeight();
  }

  Future<void> _loadLatestWeight() async {
    final repository = ref.read(measurementsRepositoryProvider);
    final latest = await repository.getLatestMeasurement(
      MeasurementType.weight.key,
    );
    if (latest != null && mounted) {
      setState(() {
        _currentWeight = latest.value;
      });
    }
  }

  Future<void> _saveWeight() async {
    final repository = ref.read(measurementsRepositoryProvider);
    final useMetric = ref.read(unitPreferenceProvider);
    
    await repository.saveMeasurement(
      type: MeasurementType.weight.key,
      value: _currentWeight,
      unit: useMetric ? 'kg' : 'lb',
    );

    setState(() {
      _hasChanges = false;
    });

    // Refresh providers
    ref.invalidate(measurementsByTypeProvider);
    ref.invalidate(latestMeasurementProvider);
    ref.invalidate(measurementStatsProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Weight saved successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final useMetric = ref.watch(unitPreferenceProvider);
    final unit = useMetric ? 'kg' : 'lb';
    final last7Measurements = ref.watch(
      lastNMeasurementsProvider(
        MeasurementQuery(MeasurementType.weight.key, 7),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Measurements',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          // Unit toggle
          IconButton(
            icon: Icon(
              useMetric ? Icons.monitor_weight : Icons.fitness_center,
              color: Colors.blue,
            ),
            onPressed: () {
              ref.read(unitPreferenceProvider.notifier).state = !useMetric;
              setState(() {
                // Convert weight
                _currentWeight = useMetric
                    ? _currentWeight * 2.20462 // kg to lb
                    : _currentWeight / 2.20462; // lb to kg
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Weight Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5A6B7C),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Weight',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Goal: ${_goalWeight.toStringAsFixed(1)} $unit',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white60,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Weight Adjuster
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Minus Button
                            _CircleButton(
                              icon: Icons.remove,
                              onTap: () {
                                setState(() {
                                  _currentWeight = (_currentWeight - 0.1).clamp(0, 500);
                                  _hasChanges = true;
                                });
                              },
                            ),
                            const SizedBox(width: 32),

                            // Weight Display
                            Text(
                              '${_currentWeight.toStringAsFixed(1)} $unit',
                              style: GoogleFonts.inter(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 32),

                            // Plus Button
                            _CircleButton(
                              icon: Icons.add,
                              onTap: () {
                                setState(() {
                                  _currentWeight = (_currentWeight + 0.1).clamp(0, 500);
                                  _hasChanges = true;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Chart
                  last7Measurements.when(
                    data: (measurements) {
                      if (measurements.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return _WeightChart(measurements: measurements);
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 24),

                  // Body Icon and Message
                  const Icon(
                    Icons.accessibility_new_rounded,
                    size: 80,
                    color: Color(0xFF5A6B7C),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Track your progress\nregularly, but don\'t go too\ncrazy.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Save Button (only show if changes)
                if (_hasChanges)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveWeight,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'SAVE WEIGHT',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                if (_hasChanges) const SizedBox(height: 12),

                // Add More Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const MeasurementsPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    label: Text(
                      'ADD MORE',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

class _WeightChart extends StatelessWidget {
  final List measurements;

  const _WeightChart({required this.measurements});

  @override
  Widget build(BuildContext context) {
    if (measurements.length < 2) return const SizedBox.shrink();

    final spots = measurements.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.value,
      );
    }).toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(1),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= measurements.length) {
                    return const SizedBox.shrink();
                  }
                  final date = measurements[value.toInt()].date;
                  return Text(
                    DateFormat('MM/dd').format(date),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.blue,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
