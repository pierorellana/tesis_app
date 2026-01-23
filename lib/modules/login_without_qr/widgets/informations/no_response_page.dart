import 'package:flutter/material.dart';
import 'package:tesis_app/env/theme/app_theme.dart';
import 'package:tesis_app/shared/widgets/status_icon_animated.dart';

class NoResponsePage extends StatelessWidget {
  const NoResponsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const StatusIconAnimated(
          color: Color(0xFFFFA000),
          icon: Icons.warning_amber_rounded,
          size: 140,
          iconSize: 56,
        ),
        const SizedBox(height: 24),
        const Text(
          'No hubo respuesta',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w900,
            color: AppTheme.dark,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Se procede a intentar nuevamente...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: AppTheme.hinText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
