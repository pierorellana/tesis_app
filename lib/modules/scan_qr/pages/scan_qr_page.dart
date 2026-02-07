import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:tesis_app/env/theme/app_theme.dart';
import 'package:tesis_app/modules/scan_qr/services/qr_service.dart';
import 'package:tesis_app/modules/scan_qr/widgets/qr_code_widget.dart';
import 'package:tesis_app/shared/helpers/global_helper.dart';
import 'package:tesis_app/shared/helpers/responsive.dart';
import 'package:tesis_app/shared/providers/functional_provider.dart';
import 'package:tesis_app/shared/widgets/text_button.dart';

class ScanQrPage extends StatefulWidget {
  const ScanQrPage({super.key});

  @override
  State<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends State<ScanQrPage> {
  final QrService _qrService = QrService();

  Future<void> _validateQr(String qrValue) async {
    final fp = context.read<FunctionalProvider>();

    try {
      final qrId = qrValue.trim();
      final params = {"marcar_usado": "false"};

      final response = await _qrService.validateQr(
        id: qrId,
        context,
        queryParams: params,
      );

      if (!response.error) {
        fp.setEntryMethodItem(EntryMethodItem.successValidation);
      } else {
        fp.setEntryMethodItem(EntryMethodItem.rejectValidation);
      }
    } catch (e) {
      fp.setEntryMethodItem(EntryMethodItem.rejectValidation);
      debugPrint('Excepción validando QR: $e');
    }
  }

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
            final isWide = constraints.maxWidth >= 1000;

            final paddingH = (constraints.maxWidth * 0.05).clamp(18.0, 64.0);
            final paddingV = (constraints.maxHeight * 0.05).clamp(14.0, 52.0);

            final titleSize = (r.dp(2.6)).clamp(28.0, 48.0);
            final subtitleSize = (r.dp(1.2)).clamp(14.0, 22.0);
            final iconSize = (r.dp(2.2)).clamp(28.0, 40.0);

            final availableWidth = constraints.maxWidth - (paddingH * 2);
            final targetWidth = availableWidth * (isWide ? 0.7 : 0.95);
            final clampedTarget = targetWidth.clamp(260.0, 720.0);
            final maxWidth = clampedTarget > availableWidth
                ? availableWidth
                : clampedTarget;
            final maxHeight = (constraints.maxHeight * (isShort ? 0.55 : 0.62))
                .clamp(260.0, 520.0);
            final cardSide = math.min(maxWidth, maxHeight);

            final outerPad = (r.dp(1.1)).clamp(14.0, 20.0);
            final innerPad = (r.dp(1.2)).clamp(16.0, 24.0);

            final gapTitle = (constraints.maxHeight * 0.018).clamp(8.0, 14.0);
            final gapBlock = (constraints.maxHeight * 0.02).clamp(10.0, 18.0);

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: paddingV),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Symbols.qr_code_2_rounded,
                                size: iconSize,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Escanear QR',
                                style: TextStyle(
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.dark,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: gapTitle),
                          Text(
                            'Acerque su código al recuadro',
                            style: TextStyle(
                              fontSize: subtitleSize,
                              color: AppTheme.hinText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: gapBlock),
                          QrCodeWidget(
                            width: cardSide,
                            height: cardSide,
                            padding: EdgeInsets.all(outerPad),
                            framePadding: EdgeInsets.all(innerPad),
                            onQrDetected: (value) async {
                              final fp = context.read<FunctionalProvider>();
                              fp.setLastQrValue(value);
                              fp.setEntryMethodItem(
                                EntryMethodItem.validatingQr,
                              );
                              await _validateQr(value);
                            },
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: (r.dp(1.0)).clamp(12.0, 16.0),
                                color: Colors.black54,
                              ),
                              children: [
                                const TextSpan(
                                  text: "Recomendación: ",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.dark,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      "Ajuste el brillo de su pantalla al máximo para facilitar la lectura del código",
                                  style: const TextStyle(
                                    color: AppTheme.hinText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 20,
                            runSpacing: 10,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {
                                  fp.setEntryMethodItem(EntryMethodItem.none);
                                },
                                icon: const Icon(Icons.arrow_back),
                                label: const Text('Volver'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.dark,
                                  side: const BorderSide(
                                    color: AppTheme.darkGrey,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              TextButtonWidget(
                                nameButton: "No tengo QR",
                                textButtonColor: AppTheme.dark,
                                fontSize: 15,
                                onPressed: () {
                                  fp.setEntryMethodItem(EntryMethodItem.noQr);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
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
