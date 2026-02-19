import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tesis_app/env/theme/app_theme.dart';
import 'package:tesis_app/shared/helpers/global_helper.dart';
import 'package:tesis_app/shared/helpers/responsive.dart';
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final r = context.responsive;
            final isShort = constraints.maxHeight < 650;

            final iconSize = (r.dp(3.8)).clamp(90.0, 150.0);
            final iconGlyph = (r.dp(1.8)).clamp(36.0, 58.0);

            final titleSize = (r.dp(2.6)).clamp(28.0, 52.0);
            final subtitleSize = (r.dp(1.1)).clamp(13.0, 20.0);

            final buttonHeight =
                (constraints.maxHeight * (isShort ? 0.08 : 0.09)).clamp(
                  48.0,
                  62.0,
                );
            final buttonFont = (r.dp(1.0)).clamp(12.0, 16.0);

            final gapTitle = (constraints.maxHeight * 0.03).clamp(16.0, 26.0);
            final gapSubtitle = (constraints.maxHeight * 0.012).clamp(
              8.0,
              14.0,
            );
            final gapButtons = (constraints.maxHeight * 0.03).clamp(18.0, 28.0);
            final gapFooter = (constraints.maxHeight * 0.02).clamp(12.0, 22.0);

            final wrapSpacing = (constraints.maxWidth * 0.02).clamp(12.0, 20.0);
            final wrapRunSpacing = (constraints.maxHeight * 0.015).clamp(
              10.0,
              16.0,
            );

            final textButtonSize = (r.dp(0.95)).clamp(12.0, 15.0);
            final helpSize = (r.dp(0.9)).clamp(11.0, 14.0);
            final helpIconSize = (r.dp(1.0)).clamp(14.0, 18.0);

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: SizedBox(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StatusIconAnimated(
                          color: const Color(0xFFE60023),
                          icon: Icons.close_rounded,
                          size: iconSize,
                          iconSize: iconGlyph,
                        ),
                        SizedBox(height: gapTitle),
                        Text(
                          'Código no válido',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.dark,
                            height: 1.05,
                          ),
                        ),
                        SizedBox(height: gapSubtitle),
                        Text(
                          'El código ha caducado o ya fue utilizado',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: subtitleSize,
                            color: AppTheme.hinText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: gapButtons),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: wrapSpacing,
                          runSpacing: wrapRunSpacing,
                          children: [
                            SizedBox(
                              height: buttonHeight,
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
                                child: Text(
                                  'Intentar de nuevo',
                                  style: TextStyle(
                                    fontSize: buttonFont,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: buttonHeight,
                              child: OutlinedButton(
                                onPressed: () {
                                  fp.setEntryMethodItem(EntryMethodItem.noQr);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.dark,
                                  side: const BorderSide(
                                    color: Color(0xFFD7DEE8),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Text(
                                  'Ingreso sin QR',
                                  style: TextStyle(
                                    fontSize: buttonFont,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: gapFooter),
                        TextButton(
                          onPressed: () =>
                              fp.setEntryMethodItem(EntryMethodItem.none),
                          child: Text(
                            'Volver al inicio',
                            style: TextStyle(
                              fontSize: textButtonSize,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.dark,
                            ),
                          ),
                        ),
                        SizedBox(height: (gapFooter * 1.9).clamp(8.0, 16.0)),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: helpIconSize,
                              color: AppTheme.hinText.withOpacity(0.9),
                            ),
                            Text(
                              'Si necesita ayuda, contacte al personal de seguridad',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: helpSize,
                                color: AppTheme.hinText.withOpacity(0.95),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}