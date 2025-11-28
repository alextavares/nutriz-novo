import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  Widget build(BuildContext context) {
    final fastingState = ref.watch(fastingNotifierProvider);
    final progress =
        (fastingState.elapsed.inSeconds / fastingState.goal.inSeconds).clamp(
          0.0,
          1.0,
        );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFDF4FF), // Light Purple Start
              Color(0xFFF8E8FF), // Light Purple End (slightly darker)
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "You're fasting!",
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4A148C),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Icon(
                        Icons.rocket_launch,
                        color: Colors.orange,
                        size: 24,
                      ),
                    ],
                  ),
                ),

                // Main Content (Timer or Body Status)
                // Using SizedBox to give it a fixed height or AspectRatio could work,
                // but FastingTimerWidget is responsive. Let's give it a reasonable height constraint
                // or let it take what it needs. Since it's in a Column in a ScrollView,
                // we shouldn't use Expanded.
                SizedBox(
                  height: 550, // Adjust as needed for design
                  child: _selectedIndex == 0
                      ? FastingTimerWidget(
                          progress: progress,
                          elapsed: fastingState.elapsed,
                          goal: fastingState.goal,
                          startTime: fastingState.startTime,
                          onStop: () {
                            // TODO: Confirm dialog
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

                // Tab Card
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(0, Icons.timer_outlined),
                        _buildNavItem(
                          1,
                          Icons.accessibility_new_rounded,
                        ), // Body/Person
                        _buildNavItem(2, Icons.bar_chart_rounded),
                        _buildNavItem(3, Icons.calendar_today_rounded),
                      ],
                    ),
                  ),
                ),

                // Suggestions Section (Moved from Body Status)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Suggestions for Your Next Meal",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4A148C),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        height: 180,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildMealCard(
                              "Midday Meal",
                              "Prep",
                              "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=500&q=80",
                            ),
                            const SizedBox(width: AppSpacing.md),
                            _buildMealCard(
                              "Delicious,",
                              "Filling Meals",
                              "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=500&q=80",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Padding for scrolling
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4A148C) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey[400],
          size: 24,
        ),
      ),
    );
  }

  Widget _buildMealCard(String title, String subtitle, String imageUrl) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              imageUrl,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4A148C),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
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
              primary: Color(0xFF8E24AA), // Purple
              onPrimary: Colors.white,
              onSurface: Color(0xFF4A148C),
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
                primary: Color(0xFF8E24AA), // Purple
                onPrimary: Colors.white,
                onSurface: Color(0xFF4A148C),
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
      firstDate: currentStart, // Cannot end before start
      lastDate: currentStart.add(const Duration(days: 7)), // Reasonable limit
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8E24AA), // Purple
              onPrimary: Colors.white,
              onSurface: Color(0xFF4A148C),
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
                primary: Color(0xFF8E24AA), // Purple
                onPrimary: Colors.white,
                onSurface: Color(0xFF4A148C),
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
