import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tesis_app/env/theme/app_theme.dart';
import 'package:tesis_app/shared/helpers/global_helper.dart';
import 'package:tesis_app/shared/providers/functional_provider.dart';
import 'package:tesis_app/shared/widgets/status_icon_animated.dart';

class RejectValidation extends StatelessWidget {
  const RejectValidation({super.key});

  @override
  Widget build(BuildContext context) {
    final fp = context.read<FunctionalProvider>();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.white, AppTheme.greyBlocked],
        ),
      ),
      child: SafeArea(
        child: Column(
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
              'Código no válido',
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
              'El código ha caducado o ya fue utilizado',
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
                    onPressed: () {
                      fp.setEntryMethodItem(EntryMethodItem.scanQr);
                    },
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                SizedBox(
                  width: 190,
                  height: 58,
                  child: OutlinedButton(
                    onPressed: () {
                      fp.setEntryMethodItem(EntryMethodItem.noQr);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.dark,
                      side: const BorderSide(color: Color(0xFFD7DEE8)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Ingreso sin QR',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => fp.setEntryMethodItem(EntryMethodItem.none),
              child: const Text(
                'Volver al inicio',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.dark,
                ),
              ),
            ),
            const SizedBox(height: 14),
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
                  'Si necesita ayuda, contacte al personal de seguridad',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.hinText.withOpacity(0.95),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}