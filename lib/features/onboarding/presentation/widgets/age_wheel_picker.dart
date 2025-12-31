import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AgeWheelPicker extends StatefulWidget {
  final int initialAge;
  final int minAge;
  final int maxAge;
  final ValueChanged<int> onChanged;

  const AgeWheelPicker({
    super.key,
    required this.initialAge,
    required this.minAge,
    required this.maxAge,
    required this.onChanged,
  });

  @override
  State<AgeWheelPicker> createState() => _AgeWheelPickerState();
}

class _AgeWheelPickerState extends State<AgeWheelPicker> {
  late final FixedExtentScrollController _controller;
  late int _selectedAge;

  @override
  void initState() {
    super.initState();
    _selectedAge = _clampAge(widget.initialAge);
    _controller = FixedExtentScrollController(
      initialItem: (_selectedAge - widget.minAge).clamp(
        0,
        widget.maxAge - widget.minAge,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant AgeWheelPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextAge = _clampAge(widget.initialAge);
    if (nextAge != _selectedAge && _controller.hasClients) {
      _selectedAge = nextAge;
      _controller.jumpToItem(
        (_selectedAge - widget.minAge).clamp(0, widget.maxAge - widget.minAge),
      );
    }
  }

  int _clampAge(int age) => age.clamp(widget.minAge, widget.maxAge);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = (widget.maxAge - widget.minAge) + 1;

    return Center(
      child: SizedBox(
        width: 180,
        height: 260,
        child: ListWheelScrollView.useDelegate(
          controller: _controller,
          physics: const FixedExtentScrollPhysics(),
          itemExtent: 44,
          diameterRatio: 1.8,
          perspective: 0.002,
          onSelectedItemChanged: (index) {
            final age = widget.minAge + index;
            if (age == _selectedAge) return;
            setState(() => _selectedAge = age);
            HapticFeedback.selectionClick();
            widget.onChanged(age);
          },
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: itemCount,
            builder: (context, index) {
              final age = widget.minAge + index;
              final isSelected = age == _selectedAge;

              return Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  width: 120,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected
                        ? Border.all(color: const Color(0xFF3B82F6), width: 2)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    age.toString(),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? const Color(0xFF111827)
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
