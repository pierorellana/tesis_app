import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tesis_app/env/theme/app_theme.dart';
import 'package:tesis_app/modules/login_without_qr/models/cedula_response.dart';
import 'package:tesis_app/modules/login_without_qr/models/id_result_model.dart';
import 'package:tesis_app/modules/login_without_qr/services/ocr_cedula_service.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/cards/hikvision_camera_widget.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/informations/information_id_widget.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/loadings/reading_id_widget.dart';
import 'package:tesis_app/shared/helpers/global_helper.dart' as GlobalHelper;
import 'package:tesis_app/shared/helpers/responsive.dart';

class IdPage extends StatefulWidget {
  const IdPage({super.key, required this.onBack, required this.onConfirmed});

  final VoidCallback onBack;
  final void Function(IdStepResult result) onConfirmed;

  @override
  State<IdPage> createState() => _IdPageState();
}

class _IdPageState extends State<IdPage> {
  late final HikvisionCameraController _hikController;
  late final HikvisionCameraConfig _hikConfig;

  GlobalHelper.IdUiState _uiState = GlobalHelper.IdUiState.camera;

  final OcrCedulaService _cedulaService = OcrCedulaService();
  CedulaResponse? _cedula;
  IdParsedData? _parsed;

  @override
  void initState() {
    super.initState();
    _hikController = HikvisionCameraController();
    _hikConfig = HikvisionCameraConfig(
      rtspUrl: dotenv.env['HIKVISION_RTSP_URL'] ?? '',
      snapshotUrl: dotenv.env['HIKVISION_SNAPSHOT_URL'],
      username: dotenv.env['HIKVISION_USER'],
      password: dotenv.env['HIKVISION_PASS'],
    );
  }

  @override
  void dispose() {
    _hikController.dispose();
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
      return LayoutBuilder(
        builder: (context, constraints) {
          final r = context.responsive;
          final isShort = constraints.maxHeight < 650;
          final paddingH = (constraints.maxWidth * 0.05).clamp(16.0, 64.0);

          final titleSize = (r.dp(2.6)).clamp(28.0, 52.0);
          final hintSize = (r.dp(1.0)).clamp(12.0, 16.0);

          final availableWidth = constraints.maxWidth - (paddingH * 2);
          final maxCardWidth = (availableWidth * 0.86).clamp(320.0, 860.0);
          final maxCardHeight = (constraints.maxHeight * (isShort ? 0.5 : 0.62))
              .clamp(260.0, 520.0);
          const aspect = 0.62;
          final cardWidth = math.min(maxCardWidth, maxCardHeight / aspect);
          final cardHeight = cardWidth * aspect;

          final outerPad = (r.dp(1.1)).clamp(14.0, 20.0);
          final innerPad = (r.dp(1.2)).clamp(16.0, 22.0);

          final gapTitle = (constraints.maxHeight * 0.02).clamp(8.0, 16.0);
          final gapBlock = (constraints.maxHeight * 0.03).clamp(12.0, 26.0);
          final gapAfterCamera = (constraints.maxHeight * 0.035).clamp(
            16.0,
            30.0,
          );

          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    SizedBox(height: gapTitle),
                    Text(
                      'Escanee su cédula',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.dark,
                        height: 1.05,
                      ),
                    ),
                    SizedBox(height: gapBlock),
                    HikvisionCameraWidget(
                      controller: _hikController,
                      config: _hikConfig,
                      autoCapture: true,
                      onCaptured: _onCaptured,
                      width: cardWidth,
                      height: cardHeight,
                      padding: EdgeInsets.all(outerPad),
                      framePadding: EdgeInsets.all(innerPad),
                    ),
                    SizedBox(height: gapAfterCamera),
                    Text(
                      'Evite reflejos',
                      style: TextStyle(
                        fontSize: hintSize,
                        color: AppTheme.hinText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Mantenga estable la identificación',
                      style: TextStyle(
                        fontSize: hintSize,
                        color: AppTheme.hinText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: (constraints.maxHeight * 0.03).clamp(12.0, 22.0),
                  ),
                  child: SizedBox(
                    width: (constraints.maxWidth * 0.22).clamp(120.0, 160.0),
                    height: (constraints.maxHeight * 0.08).clamp(48.0, 58.0),
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
                ),
              ],
            ),
          );
        },
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
