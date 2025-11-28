import 'package:flutter/material.dart';

enum FastingStage {
  sugarRises(
    title: 'Blood sugar rises',
    description: 'Your blood sugar levels increase after a meal.',
    startDuration: Duration.zero,
    icon: Icons.trending_up,
    color: Color(0xFFFFCDD2), // Light Red
  ),
  sugarDrops(
    title: 'Blood sugar level dropping',
    description: 'Your blood sugar starts to go down.',
    startDuration: Duration(hours: 2),
    icon: Icons.trending_down,
    color: Color(0xFFE1BEE7), // Light Purple
  ),
  sugarNormal(
    title: 'Blood sugar normalizes',
    description: 'Your blood sugar returns to normal levels.',
    startDuration: Duration(hours: 8),
    icon: Icons.water_drop,
    color: Color(0xFFBBDEFB), // Light Blue
  ),
  fatBurn(
    title: 'Fat burning',
    description: 'Your body starts burning fat for energy.',
    startDuration: Duration(hours: 12),
    icon: Icons.local_fire_department,
    color: Color(0xFFFFCC80), // Light Orange
  ),
  ketosis(
    title: 'Ketosis',
    description: 'You are in full fat-burning mode.',
    startDuration: Duration(hours: 14),
    icon: Icons.bolt,
    color: Color(0xFFFFAB91), // Deep Orange
  ),
  autophagy(
    title: 'Autophagy',
    description: 'Your cells start cleaning themselves.',
    startDuration: Duration(hours: 16),
    icon: Icons.cleaning_services,
    color: Color(0xFFC8E6C9), // Light Green
  );

  final String title;
  final String description;
  final Duration startDuration;
  final IconData icon;
  final Color color;

  const FastingStage({
    required this.title,
    required this.description,
    required this.startDuration,
    required this.icon,
    required this.color,
  });

  static FastingStage getStageForDuration(Duration elapsed) {
    // Iterate in reverse to find the last stage that has started
    for (final stage in FastingStage.values.reversed) {
      if (elapsed >= stage.startDuration) {
        return stage;
      }
    }
    return FastingStage.sugarRises;
  }
}
