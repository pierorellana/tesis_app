import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tesis_app/env/theme/app_theme.dart';
import 'package:tesis_app/modules/login_without_qr/models/admission_request.dart';
import 'package:tesis_app/shared/helpers/responsive.dart';

class ReviewApplication extends StatelessWidget {
  const ReviewApplication({
    super.key,
    required this.model,
    required this.onCallResident,
    required this.onEditDestination,
  });

  final AdmissionRequestModel model;
  final VoidCallback onCallResident;
  final VoidCallback onEditDestination;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final r = context.responsive;
        final isTablet = r.isTablet;
        final height = constraints.maxHeight;
        final compactScale = height < 620
            ? 0.86
            : (height < 700 ? 0.92 : 1.0);

        final titleSize =
            (constraints.maxWidth * (isTablet ? 0.065 : 0.08) * compactScale)
                .clamp(28.0, 52.0);
        final gapAfterTitle =
            ((height * 0.02) * compactScale).clamp(8.0, 18.0);

        final maxCardWidth = math.min(constraints.maxWidth - 24.0, 460.0);
        final minCardWidth = math.min(280.0, maxCardWidth);
        final desiredCardWidth =
            constraints.maxWidth * (isTablet ? 0.6 : 0.88);
        final cardWidth = desiredCardWidth.clamp(minCardWidth, maxCardWidth);

        final cardPaddingH = (22.0 * compactScale).clamp(16.0, 22.0);
        final cardPaddingV = (20.0 * compactScale).clamp(14.0, 20.0);
        final dividerHeight =
            ((height * 0.035) * compactScale).clamp(20.0, 32.0);

        final gapAfterCard =
            ((height * 0.03) * compactScale).clamp(14.0, 26.0);

        final maxRowWidth = math.min(constraints.maxWidth - 24.0, 460.0);
        final minRowWidth = math.min(260.0, maxRowWidth);
        final desiredRowWidth =
            constraints.maxWidth * (isTablet ? 0.6 : 0.9);
        final rowWidth = desiredRowWidth.clamp(minRowWidth, maxRowWidth);
        final buttonGap = (rowWidth * 0.05).clamp(10.0, 16.0);
        final primaryWidth = (rowWidth - buttonGap) * 0.6;
        final secondaryWidth = (rowWidth - buttonGap) * 0.4;
        final buttonHeight =
            ((height * (isTablet ? 0.07 : 0.08)) * compactScale)
                .clamp(44.0, 58.0);

        final sectionScale = compactScale;

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Revise su solicitud',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.dark,
                    height: 1.05,
                  ),
                ),
                SizedBox(height: gapAfterTitle),
                Container(
                  width: cardWidth,
                  padding: EdgeInsets.symmetric(
                    horizontal: cardPaddingH,
                    vertical: cardPaddingV,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD7DEE8), width: 1),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                        color: Colors.black.withOpacity(0.06),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Section(
                        title: 'Visitante',
                        lines: [model.fullName, 'CI: ${model.identification}'],
                        strongFirst: true,
                        textScale: sectionScale,
                      ),
                      Divider(
                        color: const Color(0xFFD7DEE8),
                        height: dividerHeight,
                      ),
                      _Section(
                        title: 'Destino',
                        lines: [model.destinoLabel, model.residentName],
                        strongFirst: true,
                        textScale: sectionScale,
                      ),
                      Divider(
                        color: const Color(0xFFD7DEE8),
                        height: dividerHeight,
                      ),
                      _Section(
                        title: 'Motivo',
                        lines: [model.reasonLabel],
                        strongFirst: true,
                        textScale: sectionScale,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: gapAfterCard),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: primaryWidth,
                      height: buttonHeight,
                      child: ElevatedButton.icon(
                        onPressed: onCallResident,
                        icon: const Icon(Icons.call_outlined),
                        label: const Text(
                          'Llamar al residente',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: buttonGap),
                    SizedBox(
                      width: secondaryWidth,
                      height: buttonHeight,
                      child: OutlinedButton(
                        onPressed: onEditDestination,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.dark,
                          side: const BorderSide(color: Color(0xFFD7DEE8)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Editar destino',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.lines,
    required this.strongFirst,
    this.textScale = 1.0,
  });

  final String title;
  final List<String> lines;
  final bool strongFirst;
  final double textScale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12 * textScale,
            color: AppTheme.hinText,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 4 * textScale),
        ...List.generate(lines.length, (i) {
          final isStrong = strongFirst && i == 0;
          return Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              lines[i],
              style: TextStyle(
                fontSize: (isStrong ? 18 : 14) * textScale,
                fontWeight: isStrong ? FontWeight.w900 : FontWeight.w600,
                color: AppTheme.dark,
              ),
            ),
          );
        }),
      ],
    );
  }
}
