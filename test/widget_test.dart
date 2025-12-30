import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutriz/features/diary/domain/entities/diary_day.dart';
import 'package:nutriz/features/diary/presentation/widgets/daily_summary_header_improved.dart';

void main() {
  testWidgets('Daily summary renders key info', (WidgetTester tester) async {
    final day = DiaryDay(date: DateTime(2025, 1, 1));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: DailySummaryHeaderImproved(
                diaryDay: day,
                calorieGoal: 2000,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Restantes'), findsOneWidget);
    expect(find.text('2000'), findsOneWidget);
    expect(find.text('Carbo'), findsOneWidget);
  });
}

