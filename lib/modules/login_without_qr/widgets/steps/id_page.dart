import 'dart:io';
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
  XFile? _lastCapture;

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
      _lastCapture = file;
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
      _lastCapture = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_uiState == GlobalHelper.IdUiState.camera) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final r = context.responsive;
          final isShort = constraints.maxHeight < 650;
          final isTablet = r.isTablet;
          final paddingH = (constraints.maxWidth * 0.05).clamp(16.0, 64.0);

          final titleScale = isTablet ? 1.08 : 1.0;
          final hintScale = isTablet ? 1.05 : 1.0;
          final titleSize = (r.dp(2.6) * titleScale).clamp(28.0, 58.0);
          final hintSize = (r.dp(1.0) * hintScale).clamp(12.0, 18.0);

          final availableWidth = constraints.maxWidth - (paddingH * 2);
          final widthFactor = isTablet ? 0.9 : 0.86;
          final heightFactor = isTablet ? 0.7 : (isShort ? 0.5 : 0.62);
          final maxCardWidth = math.max(availableWidth * widthFactor, 320.0);
          final maxCardHeight = math.max(
            constraints.maxHeight * heightFactor,
            260.0,
          );
          const aspect = 0.62;
          final cardWidth = math.min(maxCardWidth, maxCardHeight / aspect);
          final cardHeight = cardWidth * aspect;

          final padScale = isTablet ? 1.06 : 1.0;
          final outerPad = (r.dp(1.1) * padScale).clamp(14.0, 22.0);
          final innerPad = (r.dp(1.2) * padScale).clamp(16.0, 24.0);

          final gapScale = isTablet ? 1.08 : 1.0;
          final gapTitle = (constraints.maxHeight * 0.02 * gapScale).clamp(
            8.0,
            18.0,
          );
          final gapBlock = (constraints.maxHeight * 0.03 * gapScale).clamp(
            12.0,
            28.0,
          );
          final gapAfterCamera = (constraints.maxHeight * 0.035 * gapScale)
              .clamp(16.0, 34.0);

          final previewWidth = (cardWidth * 0.58).clamp(240.0, 420.0);
          final previewHeight = previewWidth * (cardHeight / cardWidth);

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
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: gapBlock,
                      runSpacing: gapBlock,
                      children: [
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
                        _buildPreviewPanel(
                          width: previewWidth,
                          height: previewHeight,
                        ),
                      ],
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
                  padding: EdgeInsets.only(left: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: widget.onBack,
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text(
                        'Volver',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.dark,
                        side: const BorderSide(color: Color(0xFFD7DEE8)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
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
      return _buildWithPreview(const ReadingIdInfoWidget());
    }

    return _buildWithPreview(
      ConfirmIdDataWidget(
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
      ),
    );
  }

  Widget _buildWithPreview(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final previewWidth = (constraints.maxWidth * 0.28).clamp(220.0, 360.0);
        final previewHeight = previewWidth * 0.62;

        return Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 24,
            runSpacing: 24,
            children: [
              child,
              _buildPreviewPanel(
                width: previewWidth,
                height: previewHeight,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPreviewPanel({required double width, required double height}) {
    final file = _lastCapture;
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD7DEE8)),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: file != null
            ? Image.file(
                File(file.path),
                fit: BoxFit.contain,
              )
            : Container(
                alignment: Alignment.center,
                color: const Color(0xFFF2F5FA),
                child: Text(
                  'Vista previa',
                  style: TextStyle(
                    color: AppTheme.hinText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
      ),
    );
  }
}
