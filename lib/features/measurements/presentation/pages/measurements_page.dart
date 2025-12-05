import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/measurement_schemas.dart';
import 'measurement_input_page.dart';

class MeasurementsPage extends StatelessWidget {
  const MeasurementsPage({super.key});

  @override
  Widget build(BuildContext context) {
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
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _MeasurementItem(
            type: MeasurementType.bodyFat,
            onTap: () => _navigateToMeasurement(context, MeasurementType.bodyFat),
          ),
          _MeasurementItem(
            type: MeasurementType.bloodPressure,
            onTap: () => _navigateToMeasurement(context, MeasurementType.bloodPressure),
          ),
          _MeasurementItem(
            type: MeasurementType.bloodGlucose,
            onTap: () => _navigateToMeasurement(context, MeasurementType.bloodGlucose),
          ),
          _MeasurementItem(
            type: MeasurementType.muscleMass,
            onTap: () => _navigateToMeasurement(context, MeasurementType.muscleMass),
          ),
          _MeasurementItem(
            type: MeasurementType.waist,
            onTap: () => _navigateToMeasurement(context, MeasurementType.waist),
          ),
          _MeasurementItem(
            type: MeasurementType.hips,
            onTap: () => _navigateToMeasurement(context, MeasurementType.hips),
          ),
          _MeasurementItem(
            type: MeasurementType.chest,
            onTap: () => _navigateToMeasurement(context, MeasurementType.chest),
          ),
          _MeasurementItem(
            type: MeasurementType.thighs,
            onTap: () => _navigateToMeasurement(context, MeasurementType.thighs),
          ),
          _MeasurementItem(
            type: MeasurementType.upperArms,
            onTap: () => _navigateToMeasurement(context, MeasurementType.upperArms),
          ),
        ],
      ),
    );
  }

  void _navigateToMeasurement(
    BuildContext context,
    MeasurementType type,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MeasurementInputPage(
          title: type.displayName,
          icon: type.icon,
          unit: type.defaultUnit,
          type: type,
        ),
      ),
    );
  }
}

class _MeasurementItem extends StatelessWidget {
  final MeasurementType type;
  final VoidCallback onTap;

  const _MeasurementItem({
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Text(
              type.icon,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 16),
            Text(
              type.displayName,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
