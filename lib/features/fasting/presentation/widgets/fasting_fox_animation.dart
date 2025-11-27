import 'dart:math' as math;
import 'package:flutter/material.dart';

class FastingFoxAnimation extends StatefulWidget {
  const FastingFoxAnimation({super.key});

  @override
  State<FastingFoxAnimation> createState() => _FastingFoxAnimationState();
}

class _FastingFoxAnimationState extends State<FastingFoxAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _rotationAnimation = Tween<double>(
      begin: -3 * math.pi / 180,
      end: 3 * math.pi / 180,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: child,
          ),
        );
      },
      child: Icon(
        Icons.cruelty_free, // Fox-like icon
        size: 120,
        color: Colors.deepPurple[300],
      ),
    );
  }
}
