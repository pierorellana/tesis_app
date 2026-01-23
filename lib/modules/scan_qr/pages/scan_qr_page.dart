import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:tesis_app/env/theme/app_theme.dart';
import 'package:tesis_app/modules/scan_qr/services/qr_service.dart';
import 'package:tesis_app/modules/scan_qr/widgets/qr_code_widget.dart';
import 'package:tesis_app/shared/helpers/global_helper.dart';
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Symbols.qr_code_2_rounded,
                    size: 45,
                    color: AppTheme.primaryColor,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Escanear QR',
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.dark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Acerque su código al recuadro',
                style: TextStyle(
                  fontSize: 20,
                  color: AppTheme.hinText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 25),
              QrCodeWidget(
                onQrDetected: (value) async {
                  final fp = context.read<FunctionalProvider>();
                  fp.setLastQrValue(value);
                  fp.setEntryMethodItem(EntryMethodItem.validatingQr);
                  await _validateQr(value);
                },
              ),
              const SizedBox(height: 30),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
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
              const SizedBox(height: 35),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      fp.setEntryMethodItem(EntryMethodItem.none);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Volver'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.dark,
                      side: const BorderSide(color: AppTheme.darkGrey),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
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
        ),
      ),
    );
  }
}
