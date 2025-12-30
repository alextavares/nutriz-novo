import 'package:flutter/material.dart';

enum FastingStage {
  sugarRises(
    title: 'Glicose sobe',
    description: 'Após uma refeição, a glicose no sangue aumenta.',
    startDuration: Duration.zero,
    icon: Icons.trending_up,
    color: Color(0xFFFFCDD2), // Light Red
  ),
  sugarDrops(
    title: 'Glicose cai',
    description: 'A glicose começa a diminuir com o passar das horas.',
    startDuration: Duration(hours: 2),
    icon: Icons.trending_down,
    color: Color(0xFFE1BEE7), // Light Purple
  ),
  sugarNormal(
    title: 'Glicose normaliza',
    description: 'A glicose retorna a níveis mais estáveis.',
    startDuration: Duration(hours: 8),
    icon: Icons.water_drop,
    color: Color(0xFFBBDEFB), // Light Blue
  ),
  fatBurn(
    title: 'Queima de gordura',
    description: 'O corpo passa a usar mais gordura como fonte de energia.',
    startDuration: Duration(hours: 12),
    icon: Icons.local_fire_department,
    color: Color(0xFFFFCC80), // Light Orange
  ),
  ketosis(
    title: 'Cetose',
    description: 'Você entra em um modo de maior utilização de gordura.',
    startDuration: Duration(hours: 14),
    icon: Icons.bolt,
    color: Color(0xFFFFAB91), // Deep Orange
  ),
  autophagy(
    title: 'Autofagia',
    description: 'Seu corpo intensifica processos de reparo e reciclagem.',
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
