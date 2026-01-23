import 'package:flutter/material.dart';
import 'package:tesis_app/env/theme/app_theme.dart';
import 'package:tesis_app/shared/widgets/status_icon_animated.dart';

class SuccessValidationFace extends StatelessWidget {
  const SuccessValidationFace({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StatusIconAnimated(
          color: Color(0xFF14A44D),
          icon: Icons.check_rounded,
          size: 140,
          iconSize: 52,
        ),
        const SizedBox(height: 24),
        const Text(
          'Identidad verificada',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w900,
            color: AppTheme.dark,
            height: 1.05,
          ),
        ),
      ],
    );
  }
}
