import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class CalculatingStep extends StatefulWidget {
  final VoidCallback onComplete;

  const CalculatingStep({super.key, required this.onComplete});

  @override
  State<CalculatingStep> createState() => _CalculatingStepState();
}

class _CalculatingStepState extends State<CalculatingStep> {
  int _currentStep = 0;
  bool _completed = false;
  bool _showContinue = false;
  Timer? _safetyTimer;
  final List<String> _steps = [
    'Analisando seu perfil...',
    'Calculando taxa metabólica...',
    'Construindo seu plano...',
  ];

  @override
  void initState() {
    super.initState();
    _startSequence();
    _safetyTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted || _completed) return;
      setState(() => _showContinue = true);
    });
  }

  void _completeOnce() {
    if (_completed) return;
    _completed = true;
    _safetyTimer?.cancel();
    widget.onComplete();
  }

  void _startSequence() async {
    for (int i = 0; i < _steps.length; i++) {
      if (!mounted) return;
      setState(() {
        _currentStep = i;
      });
      await Future.delayed(const Duration(seconds: 2));
    }
    if (mounted) {
      _completeOnce();
    }
  }

  @override
  void dispose() {
    _safetyTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular Indicator or Custom Animation
            SizedBox(
              height: 100,
              width: 100,
              child: Stack(
                children: [
                  const Center(
                    child: SizedBox(
                      height: 100,
                      width: 100,
                      child: CircularProgressIndicator(
                        strokeWidth: 6,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF4CAF50),
                        ), // Green
                        backgroundColor: Color(0xFFE8F5E9),
                      ),
                    ),
                  ),
                  Center(
                    child:
                        Icon(
                              Icons.check_circle_outline_rounded,
                              color: Colors.green[700],
                              size: 40,
                            )
                            .animate(
                              onPlay: (controller) =>
                                  controller.repeat(reverse: true),
                            )
                            .fade(duration: 1000.ms, begin: 0.5, end: 1.0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Text with Animation
            SizedBox(
              height: 50,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.5),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  _steps[_currentStep],
                  key: ValueKey<int>(_currentStep),
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Isso leva poucos segundos',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
            ),
            if (_showContinue) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: _completeOnce,
                child: const Text('Continuar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
