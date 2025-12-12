import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_spacing.dart';
import '../notifiers/fasting_notifier.dart';

import '../widgets/fasting_timer_widget.dart';
import 'fasting_body_status_screen.dart';

class FastingScreen extends ConsumerStatefulWidget {
  const FastingScreen({super.key});

  @override
  ConsumerState<FastingScreen> createState() => _FastingScreenState();
}

class _FastingScreenState extends ConsumerState<FastingScreen> {
  int _selectedIndex = 0;

  // Modern Yazio-like Palette
  static const Color _primaryColor = Color(0xFF00BFA5); // Teal/Turquoise
  static const Color _backgroundColor = Color(0xFFFAFAFA); // Almost white

  @override
  Widget build(BuildContext context) {
    final fastingState = ref.watch(fastingNotifierProvider);
    final progress =
        (fastingState.elapsed.inSeconds / fastingState.goal.inSeconds).clamp(
          0.0,
          1.0,
        );

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Fasting Tracker",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "16:8", // Placeholder for dynamic protocol
                          style: TextStyle(
                            color: _primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.edit_outlined,
                          size: 14,
                          color: _primaryColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab Switcher (Segmented Control look)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildSegmentOption(0, "Timer")),
                  Expanded(child: _buildSegmentOption(1, "Body Status")),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Main Content Area
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: _selectedIndex == 0
                      ? FastingTimerWidget(
                          progress: progress,
                          elapsed: fastingState.elapsed,
                          goal: fastingState.goal,
                          startTime: fastingState.startTime,
                          onStop: () {
                            ref
                                .read(fastingNotifierProvider.notifier)
                                .stopFasting();
                          },
                          onEditStart: fastingState.startTime != null
                              ? () => _editStartTime(
                                  context,
                                  ref,
                                  fastingState.startTime!,
                                )
                              : null,
                          onEditEnd: fastingState.startTime != null
                              ? () => _editEndTime(
                                  context,
                                  ref,
                                  fastingState.startTime!,
                                  fastingState.goal,
                                )
                              : null,
                        )
                      : const FastingBodyStatusScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentOption(int index, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.black87 : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Future<void> _editStartTime(
    BuildContext context,
    WidgetRef ref,
    DateTime currentStart,
  ) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: currentStart,
      firstDate: currentStart.subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primaryColor,
              onPrimary: Colors.white,
              onSurface: Color(0xFF424242),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && context.mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(currentStart),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: _primaryColor,
                onPrimary: Colors.white,
                onSurface: Color(0xFF424242),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null && context.mounted) {
        final newStart = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        ref.read(fastingNotifierProvider.notifier).updateStartTime(newStart);
      }
    }
  }

  Future<void> _editEndTime(
    BuildContext context,
    WidgetRef ref,
    DateTime currentStart,
    Duration currentGoal,
  ) async {
    final currentEnd = currentStart.add(currentGoal);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: currentEnd,
      firstDate: currentStart,
      lastDate: currentStart.add(const Duration(days: 7)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primaryColor,
              onPrimary: Colors.white,
              onSurface: Color(0xFF424242),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && context.mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(currentEnd),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: _primaryColor,
                onPrimary: Colors.white,
                onSurface: Color(0xFF424242),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null && context.mounted) {
        final newEnd = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        ref.read(fastingNotifierProvider.notifier).updateEndTime(newEnd);
      }
    }
  }
}
