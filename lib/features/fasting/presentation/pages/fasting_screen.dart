import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../notifiers/fasting_notifier.dart';
import 'package:nutriz/core/analytics/analytics_providers.dart';

import '../widgets/fasting_timer_widget.dart';
import 'fasting_body_status_screen.dart';

class FastingScreen extends ConsumerStatefulWidget {
  const FastingScreen({super.key});

  @override
  ConsumerState<FastingScreen> createState() => _FastingScreenState();
}

class _FastingScreenState extends ConsumerState<FastingScreen> {
  int _selectedIndex = 0;
  bool _loggedView = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loggedView) return;
    _loggedView = true;

    final s = ref.read(fastingNotifierProvider);
    ref.read(analyticsServiceProvider).logEvent('fasting_view', {
      'screen': 'fasting',
      'fasting_plan': _fastingPlanSlug(s.goal),
      'is_fasting': s.isFasting,
    });
  }

  @override
  Widget build(BuildContext context) {
    final fastingState = ref.watch(fastingNotifierProvider);
    final progress =
        (fastingState.elapsed.inSeconds / fastingState.goal.inSeconds).clamp(
          0.0,
          1.0,
        );

    return Scaffold(
      backgroundColor: AppColors.background,
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
                    'Jejum',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  InkWell(
                    onTap: () => _showProtocolPicker(context, fastingState.goal),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _protocolLabel(fastingState.goal),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.tune_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
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
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildSegmentOption(0, 'Timer')),
                  Expanded(child: _buildSegmentOption(1, 'Etapas')),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Main Content Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: _selectedIndex == 0
                      ? FastingTimerWidget(
                          key: const ValueKey('timer'),
                          progress: progress,
                          elapsed: fastingState.elapsed,
                          goal: fastingState.goal,
                          startTime: fastingState.startTime,
                          onStart: () {
                            ref.read(analyticsServiceProvider).logEvent(
                              'fasting_start',
                              {
                                'screen': 'fasting',
                                'fasting_plan': _fastingPlanSlug(
                                  fastingState.goal,
                                ),
                                'source': 'button',
                              },
                            );
                            ref
                                .read(fastingNotifierProvider.notifier)
                                .startFasting();
                          },
                          onStop: () {
                            ref.read(analyticsServiceProvider).logEvent(
                              'fasting_end',
                              {
                                'screen': 'fasting',
                                'fasting_plan': _fastingPlanSlug(
                                  fastingState.goal,
                                ),
                                'duration_minutes':
                                    fastingState.elapsed.inMinutes,
                                'source': 'button',
                              },
                            );
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
                      : const FastingBodyStatusScreen(key: ValueKey('stages')),
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
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  String _protocolLabel(Duration goal) {
    final hours = goal.inHours;
    final fastingHours = hours < 0 ? 0 : (hours > 24 ? 24 : hours);
    final eatingHours = 24 - fastingHours;
    return '$fastingHours:$eatingHours';
  }

  String _fastingPlanSlug(Duration goal) {
    final hours = goal.inHours;
    final fastingHours = hours < 0 ? 0 : (hours > 24 ? 24 : hours);
    final eatingHours = 24 - fastingHours;
    return '${fastingHours}_$eatingHours';
  }

  void _showProtocolPicker(BuildContext context, Duration currentGoal) {
    final selectedHours = currentGoal.inHours;
    const presets = [12, 14, 16, 18, 20];

    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Protocolo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Escolha um protocolo padrão. Você pode ajustar início e fim no Timer.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: presets.map((hours) {
                  final selected = hours == selectedHours;
                  return ChoiceChip(
                    selected: selected,
                    label: Text(_protocolLabel(Duration(hours: hours))),
                    onSelected: (_) {
                      ref.read(analyticsServiceProvider).logEvent(
                        'fasting_plan_set',
                        {
                          'screen': 'fasting',
                          'from': _fastingPlanSlug(currentGoal),
                          'to': _fastingPlanSlug(Duration(hours: hours)),
                        },
                      );
                      ref
                          .read(fastingNotifierProvider.notifier)
                          .updateGoal(Duration(hours: hours));
                      Navigator.of(context).pop();
                    },
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: selected
                          ? AppColors.primaryDark
                          : AppColors.textSecondary,
                    ),
                    side: BorderSide(color: AppColors.border),
                    backgroundColor: AppColors.surfaceVariant,
                    selectedColor: AppColors.primaryLight.withValues(alpha: 0.65),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
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
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
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
                primary: AppColors.primary,
                onPrimary: Colors.white,
                onSurface: AppColors.textPrimary,
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
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
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
                primary: AppColors.primary,
                onPrimary: Colors.white,
                onSurface: AppColors.textPrimary,
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
