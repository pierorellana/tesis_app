import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tesis_app/env/theme/app_theme.dart';
import 'package:tesis_app/modules/login_without_qr/models/cedula_response.dart';
import 'package:tesis_app/modules/login_without_qr/models/id_result_model.dart';
import 'package:tesis_app/modules/login_without_qr/services/ocr_cedula_service.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/cards/card_camera_widget.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/informations/information_id_widget.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/loadings/reading_id_widget.dart';
import 'package:tesis_app/shared/helpers/global_helper.dart' as GlobalHelper;

class IdPage extends StatefulWidget {
  const IdPage({super.key, required this.onBack, required this.onConfirmed});

  final VoidCallback onBack;
  final void Function(IdStepResult result) onConfirmed;

  @override
  State<IdPage> createState() => _IdPageState();
}

class _IdPageState extends State<IdPage> {
  late final IdCardCameraController _cameraController;

  GlobalHelper.IdUiState _uiState = GlobalHelper.IdUiState.camera;

  final OcrCedulaService _cedulaService = OcrCedulaService();
  CedulaResponse? _cedula;
  IdParsedData? _parsed;

  @override
  void initState() {
    super.initState();
    _cameraController = IdCardCameraController();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _onCaptured(XFile file) async {
    setState(() {
      _uiState = GlobalHelper.IdUiState.reading;
      _parsed = null;
      _cedula = null;
    });

    final CedulaResponse? ced = await _getInfoCedula(file);

    if (!mounted) return;

    if (ced != null) {
      final parsed = IdParsedData(
        names: '-',
        surnames: ced.nombres,
        identification: ced.cedula,
      );

      setState(() {
        _cedula = ced;
        _parsed = parsed;
        _uiState = GlobalHelper.IdUiState.confirm;
      });
    } else {
      setState(() => _uiState = GlobalHelper.IdUiState.camera);
    }
  }

  Future<CedulaResponse?> _getInfoCedula(XFile file) async {
    final response = await _cedulaService.getCedula(context, file: file);

    if (!response.error && response.data != null) {
      return response.data;
    }

    return null;
  }

  void _retry() {
    setState(() {
      _uiState = GlobalHelper.IdUiState.camera;
      _parsed = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_uiState == GlobalHelper.IdUiState.camera) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Escanee su cédula',
            style: TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
              color: AppTheme.dark,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 18),
          IdCardCameraWidget(
            controller: _cameraController,
            autoCapture: true,
            onCaptured: _onCaptured,
          ),
          const SizedBox(height: 18),
          Text(
            'Evite reflejos',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.hinText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Mantenga estable la identificación',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.hinText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: 140,
            height: 58,
            child: OutlinedButton(
              onPressed: widget.onBack,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.dark,
                side: const BorderSide(color: Color(0xFFD7DEE8)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Volver',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      );
    }

    if (_uiState == GlobalHelper.IdUiState.reading) {
      return const ReadingIdInfoWidget();
    }

    return ConfirmIdDataWidget(
      data:
          _parsed ??
          const IdParsedData(names: '-', surnames: '-', identification: '-'),
      onConfirm: () {
        final ced = _cedula;
        final parsed = _parsed;

        if (ced == null || parsed == null) return;

        widget.onConfirmed(
          IdStepResult(data: parsed, fotoCedulaBase64: ced.fotoBase64),
        );
      },
      onRetry: _retry,
    );
  }
}
