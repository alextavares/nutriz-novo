import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class FastingHistoryChart extends StatelessWidget {
  const FastingHistoryChart({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 24,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  const style = TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  );
                  Widget text;
                  switch (value.toInt()) {
                    case 0:
                      text = const Text('M', style: style);
                      break;
                    case 1:
                      text = const Text('T', style: style);
                      break;
                    case 2:
                      text = const Text('W', style: style);
                      break;
                    case 3:
                      text = const Text('T', style: style);
                      break;
                    case 4:
                      text = const Text('F', style: style);
                      break;
                    case 5:
                      text = const Text('S', style: style);
                      break;
                    case 6:
                      text = const Text('S', style: style);
                      break;
                    default:
                      text = const Text('', style: style);
                      break;
                  }
                  return SideTitleWidget(meta: meta, child: text);
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            checkToShowHorizontalLine: (value) => value == 16,
            getDrawingHorizontalLine: (value) {
              if (value == 16) {
                return const FlLine(
                  color: Color(0xFF8E24AA),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                );
              }
              return const FlLine(strokeWidth: 0);
            },
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            _makeGroupData(0, 14),
            _makeGroupData(1, 16),
            _makeGroupData(2, 15.5),
            _makeGroupData(3, 18),
            _makeGroupData(4, 16),
            _makeGroupData(5, 12),
            _makeGroupData(6, 17),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: y >= 16 ? const Color(0xFF8E24AA) : const Color(0xFFE1BEE7),
          width: 16,
          borderRadius: BorderRadius.circular(4),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 24,
            color: Colors.grey[100],
          ),
        ),
      ],
    );
  }
}
