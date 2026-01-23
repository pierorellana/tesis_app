import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tesis_app/env/theme/app_theme.dart';
import 'package:tesis_app/shared/widgets/status_icon_animated.dart';

class PlateRegisteredPage extends StatefulWidget {
  const PlateRegisteredPage({
    super.key,
    required this.plate,
    required this.onFinish,
  });

  final String plate;
  final VoidCallback onFinish;

  @override
  State<PlateRegisteredPage> createState() => _PlateRegisteredPageState();
}

class _PlateRegisteredPageState extends State<PlateRegisteredPage> {
  Timer? _timer;
  int _seconds = 5;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_seconds <= 1) {
        t.cancel();
        widget.onFinish();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const StatusIconAnimated(
          color: Color(0xFF14A44D),
          icon: Icons.check_rounded,
          size: 160,
          iconSize: 56,
        ),
        const SizedBox(height: 22),
        const Text(
          'Ingreso registrado',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.bold,
            color: AppTheme.dark,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Bienvenido(a)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: AppTheme.hinText,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 22),
        Container(
          width: 220,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD7DEE8)),
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                offset: const Offset(0, 10),
                color: Colors.black.withOpacity(0.06),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Placa registrada',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.hinText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.plate,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.dark,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Volviendo al inicio en ${_seconds}s...',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.hinText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
