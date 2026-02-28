import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RulerPicker extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String unit;
  final String label;
  final Axis direction;
  final bool showValue;
  final bool showIndicator;
  final String Function(num)? labelBuilder;

  const RulerPicker({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.unit,
    required this.label,
    this.direction = Axis.horizontal,
    this.showValue = true,
    this.showIndicator = true,
    this.labelBuilder,
  });

  @override
  State<RulerPicker> createState() => _RulerPickerState();
}

class _RulerPickerState extends State<RulerPicker> {
  late ScrollController _scrollController;
  final double _rulerItemWidth = 10.0; // Espaço entre cada traço
  bool _isInternalScroll = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Inicializa a posição do scroll baseada no valor atual
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollFromValue(widget.value);
    });
  }

  @override
  void didUpdateWidget(RulerPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isInternalScroll && oldWidget.value != widget.value) {
      _updateScrollFromValue(widget.value);
    }
  }

  void _updateScrollFromValue(double value) {
    if (!_scrollController.hasClients) return;

    // Value = Min + (offset / itemWidth)
    // Offset = (Value - Min) * itemWidth
    final offset = (value - widget.min) * _rulerItemWidth;
    _scrollController.jumpTo(offset);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHorizontal = widget.direction == Axis.horizontal;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Padding calculations for centering
        final centerPadding = isHorizontal
            ? constraints.maxWidth / 2 - (_rulerItemWidth / 2)
            : constraints.maxHeight / 2 - (_rulerItemWidth / 2);

        return widget.showValue
            // Internal default layout (Label + Value + Ruler)
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildValueText(theme),
                  const SizedBox(height: 56),
                  _buildRuler(theme, centerPadding, isHorizontal),
                ],
              )
            // Just the Rule (for custom layouts like Height screen)
            : _buildRuler(theme, centerPadding, isHorizontal);
      },
    );
  }

  Widget _buildValueText(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          widget.value.round().toString(),
          style: theme.textTheme.displayLarge?.copyWith(
            fontSize: 80,
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.primary,
            height: 1.0,
            letterSpacing: -2.0,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          widget.unit,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRuler(ThemeData theme, double padding, bool isHorizontal) {
    return SizedBox(
      height: isHorizontal ? 120 : double.infinity,
      width: isHorizontal ? double.infinity : 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ticks List
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification) {
                _isInternalScroll = true;
                final offset = _scrollController.offset;
                final deltaValue = offset / _rulerItemWidth;

                final newValue = (widget.min + deltaValue).clamp(
                  widget.min,
                  widget.max,
                );

                if (newValue.round() != widget.value.round()) {
                  HapticFeedback.selectionClick();
                  widget.onChanged(newValue);
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _isInternalScroll = false;
                });
              }
              return true;
            },
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: widget.direction,
              physics: const BouncingScrollPhysics(),
              itemCount: (widget.max - widget.min).round() + 1,
              padding: isHorizontal
                  ? EdgeInsets.symmetric(horizontal: padding)
                  : EdgeInsets.symmetric(vertical: padding),
              itemBuilder: (context, index) {
                final value = widget.min + index;
                final isMajor = value % 10 == 0;
                final isMedium = value % 5 == 0 && !isMajor;

                final tickSize = isMajor ? 50.0 : (isMedium ? 30.0 : 18.0);
                final tickThickness = isMajor ? 2.5 : (isMedium ? 1.5 : 1.0);

                return Container(
                  width: isHorizontal ? _rulerItemWidth : null,
                  height: isHorizontal ? null : _rulerItemWidth,
                  alignment: isHorizontal
                      ? Alignment.topCenter
                      : Alignment.centerRight, // Vertical: ticks on right?
                  child: isHorizontal
                      ? Column(
                          children: [
                            _buildTick(
                              theme,
                              tickThickness,
                              tickSize,
                              isMajor,
                              isMedium,
                            ),
                            if (isMajor) ...[
                              const SizedBox(height: 8),
                              _buildTickLabel(theme, value),
                            ],
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment
                              .end, // Align to right for height
                          children: [
                            if (isMajor) ...[
                              _buildTickLabel(theme, value),
                              const SizedBox(width: 8),
                            ],
                            _buildTick(
                              theme,
                              tickSize,
                              tickThickness,
                              isMajor,
                              isMedium,
                            ), // Swapped W/H for vertical
                          ],
                        ),
                );
              },
            ),
          ),

          // Central Indicator (Pointer)
          if (widget.showIndicator)
            Align(
              alignment: isHorizontal
                  ? Alignment.topCenter
                  : Alignment.centerRight, // Vertical: line on right
              child: Container(
                width: isHorizontal
                    ? 4
                    : 40, // Vertical: pointer is a line cutting across? Or just a marker?
                height: isHorizontal ? 80 : 3,
                margin: isHorizontal
                    ? null
                    : const EdgeInsets.only(right: 0), // Adjust as needed
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: isHorizontal
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
              ),
            ),

          // Gradients
          _buildGradients(theme, isHorizontal),
        ],
      ),
    );
  }

  Widget _buildTick(
    ThemeData theme,
    double width,
    double height,
    bool isMajor,
    bool isMedium,
  ) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isMajor
            ? const Color(0xFF9CA3AF)
            : const Color(0xFFE5E7EB), // Grey 400 vs Grey 200
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildTickLabel(ThemeData theme, double value) {
    final text = widget.labelBuilder != null
        ? widget.labelBuilder!(value)
        : value.round().toString();

    // Use OverflowBox to allow text to be wider than the 10px column width
    return SizedBox(
      width: 40, // Fixed width sufficient for 3-4 digits
      child: Center(
        child: Text(
          text,
          softWrap: false,
          overflow: TextOverflow.visible,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildGradients(ThemeData theme, bool isHorizontal) {
    if (isHorizontal) {
      return Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 80,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.scaffoldBackgroundColor,
                      theme.scaffoldBackgroundColor.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 80,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.scaffoldBackgroundColor.withOpacity(0.0),
                      theme.scaffoldBackgroundColor,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      // Vertical Gradients (Top/Bottom)
      return Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 80,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.scaffoldBackgroundColor,
                      theme.scaffoldBackgroundColor.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 80,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      theme.scaffoldBackgroundColor,
                      theme.scaffoldBackgroundColor.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
}
