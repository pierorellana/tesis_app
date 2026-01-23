import 'package:flutter/material.dart';
import 'package:tesis_app/env/theme/app_theme.dart';
import 'package:tesis_app/shared/widgets/status_icon_animated.dart';

class RejectedValidationFace extends StatelessWidget {
  const RejectedValidationFace({
    super.key,
    required this.onRetry,
    required this.onBackToStart,
  });

  final VoidCallback onRetry;
  final VoidCallback onBackToStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const StatusIconAnimated(
          color: Color(0xFFE60023),
          icon: Icons.close_rounded,
          size: 140,
          iconSize: 52,
        ),
        const SizedBox(height: 24),
        const Text(
          'Identidad no verificada',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w900,
            color: AppTheme.dark,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'No se pudo validar el rostro.\nIntente nuevamente.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: AppTheme.hinText,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 58,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Intentar de nuevo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(width: 18),
            SizedBox(
              width: 190,
              height: 58,
              child: OutlinedButton(
                onPressed: onBackToStart,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.dark,
                  side: const BorderSide(color: Color(0xFFD7DEE8)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Volver al inicio',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 16,
              color: AppTheme.hinText.withOpacity(0.9),
            ),
            const SizedBox(width: 8),
            Text(
              'Asegúrese de estar en una buena iluminación',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.hinText.withOpacity(0.95),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
