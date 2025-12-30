import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/measurements_providers.dart';
import '../../data/models/measurement_schemas.dart';

class MeasurementInputPage extends ConsumerStatefulWidget {
  final String title;
  final String icon;
  final String unit;
  final MeasurementType type;

  const MeasurementInputPage({
    super.key,
    required this.title,
    required this.icon,
    required this.unit,
    required this.type,
  });

  @override
  ConsumerState<MeasurementInputPage> createState() =>
      _MeasurementInputPageState();
}

class _MeasurementInputPageState extends ConsumerState<MeasurementInputPage> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validateInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'Digite um valor';
    }

    final numValue = double.tryParse(value);
    if (numValue == null) {
      return 'Digite um número válido';
    }

    // Type-specific validation
    switch (widget.type) {
      case MeasurementType.weight:
        if (numValue < 20 || numValue > 300) {
          return 'O peso deve estar entre 20–300 ${widget.unit}';
        }
        break;
      case MeasurementType.bodyFat:
      case MeasurementType.muscleMass:
        if (numValue < 0 || numValue > 100) {
          return 'A porcentagem deve estar entre 0–100%';
        }
        break;
      case MeasurementType.bloodGlucose:
        if (numValue < 40 || numValue > 600) {
          return 'A glicose deve estar entre 40–600 mg/dL';
        }
        break;
      case MeasurementType.waist:
      case MeasurementType.hips:
      case MeasurementType.chest:
      case MeasurementType.thighs:
      case MeasurementType.upperArms:
        if (numValue < 10 || numValue > 200) {
          return 'A medida deve estar entre 10–200 cm';
        }
        break;
      default:
        if (numValue < 0) {
          return 'O valor deve ser positivo';
        }
    }

    return null;
  }

  Future<void> _saveMeasurement() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final value = double.parse(_controller.text);
    final repository = ref.read(measurementsRepositoryProvider);

    try {
      await repository.saveMeasurement(
        type: widget.type.key,
        value: value,
        unit: widget.unit,
      );

      // Invalidate providers to refresh
      ref.invalidate(measurementsByTypeProvider);
      ref.invalidate(latestMeasurementProvider);
      ref.invalidate(lastNMeasurementsProvider);
      ref.invalidate(measurementStatsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.title} saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving measurement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lastMeasurements = ref.watch(
      lastNMeasurementsProvider(MeasurementQuery(widget.type.key, 7)),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Center(
                      child: Text(
                        widget.icon,
                        style: const TextStyle(fontSize: 64),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Input Field
                    TextFormField(
                      controller: _controller,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      autofocus: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        labelText: '${widget.title} (${widget.unit})',
                        labelStyle: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                        helperText: _getHelperText(),
                        helperStyle: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: _validateInput,
                    ),
                    const SizedBox(height: 32),

                    // History Section
                    lastMeasurements.when(
                      data: (measurements) {
                        if (measurements.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Histórico recente',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: measurements.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final measurement = measurements[index];
                                  return ListTile(
                                    leading: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withValues(
                                          alpha: 0.1,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          widget.icon,
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      '${measurement.value.toStringAsFixed(1)} ${measurement.unit}',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(measurement.date),
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        await ref
                                            .read(
                                              measurementsRepositoryProvider,
                                            )
                                            .deleteMeasurement(measurement.id);
                                        ref.invalidate(
                                          lastNMeasurementsProvider,
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Save Button
          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveMeasurement,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'SALVAR',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getHelperText() {
    switch (widget.type) {
      case MeasurementType.weight:
        return 'Digite seu peso atual (20–300 ${widget.unit})';
      case MeasurementType.bodyFat:
      case MeasurementType.muscleMass:
        return 'Digite a porcentagem (0–100%)';
      case MeasurementType.bloodGlucose:
        return 'Faixa normal: 70–100 mg/dL (em jejum)';
      case MeasurementType.bloodPressure:
        return 'Referência: 120/80 mmHg';
      default:
        return 'Digite sua medida';
    }
  }
}
