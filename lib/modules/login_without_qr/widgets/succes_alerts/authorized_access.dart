import 'package:flutter/material.dart';
import 'package:tesis_app/env/theme/app_theme.dart';
import 'package:tesis_app/shared/widgets/status_icon_animated.dart';

class AuthorizedAccess extends StatelessWidget {
  const AuthorizedAccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        StatusIconAnimated(
          color: Color(0xFF14A44D),
          icon: Icons.check_rounded,
          size: 140,
          iconSize: 52,
        ),
        SizedBox(height: 24),
        Text(
          'Autorizado',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w900,
            color: AppTheme.dark,
            height: 1.05,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Ahora registre la placa del vehículo',
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
