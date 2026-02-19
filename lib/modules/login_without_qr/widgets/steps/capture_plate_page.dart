import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tesis_app/env/theme/app_theme.dart';
import 'package:tesis_app/modules/login_without_qr/models/plate_response.dart';
import 'package:tesis_app/modules/login_without_qr/services/ocr_plate_service.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/cards/hikvision_camera_widget.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/cards/hikvision_plate_camera_widget.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/loadings/reading_plate_widget.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/succes_alerts/plate_registered_page.dart';
import 'package:tesis_app/shared/helpers/responsive.dart';

enum _PlateUiState { camera, reading, success }

class CapturePlate extends StatefulWidget {
  const CapturePlate({
    super.key,
    required this.onBack,
    required this.onFinishGoHome,
  });

  final VoidCallback onBack;
  final VoidCallback onFinishGoHome;

  @override
  State<CapturePlate> createState() => _CapturePlateState();
}

class _CapturePlateState extends State<CapturePlate> {
  late final HikvisionCameraController _cameraController;
  late final HikvisionCameraConfig _hikConfig;

  final OcrPlateService _plateService = OcrPlateService();

  _PlateUiState _uiState = _PlateUiState.camera;

  String? _plate;

  @override
  void initState() {
    super.initState();
    _cameraController = HikvisionCameraController();
    _hikConfig = HikvisionCameraConfig(
      rtspUrl: dotenv.env['HIKVISION_RTSP_URL'] ?? '',
      snapshotUrl: dotenv.env['HIKVISION_SNAPSHOT_URL'],
      username: dotenv.env['HIKVISION_USER'],
      password: dotenv.env['HIKVISION_PASS'],
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _onCaptured(XFile file) async {
    setState(() {
      _uiState = _PlateUiState.reading;
      _plate = null;
    });

    final PlateResponse? plateResp = await _getPlate(file);

    if (!mounted) return;

    if (plateResp != null && plateResp.placa.trim().isNotEmpty) {
      setState(() {
        _plate = plateResp.placa.trim();
        _uiState = _PlateUiState.success;
      });
    } else {
      setState(() => _uiState = _PlateUiState.camera);
    }
  }

  Future<PlateResponse?> _getPlate(XFile file) async {
    final response = await _plateService.getPlate(context, file: file);

    if (!response.error && response.data != null) {
      return response.data;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_uiState == _PlateUiState.reading) {
      return const ReadingPlateWidget();
    }

    if (_uiState == _PlateUiState.success) {
      return PlateRegisteredPage(
        plate: _plate ?? '-',
        onFinish: widget.onFinishGoHome,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final r = context.responsive;
        final isShort = constraints.maxHeight < 650;
        final isTablet = r.isTablet;
        final paddingH = (constraints.maxWidth * 0.05).clamp(16.0, 64.0);

        final titleScale = isTablet ? 1.08 : 1.0;
        final titleSize = (r.dp(2.6) * titleScale).clamp(28.0, 58.0);

        final availableWidth = constraints.maxWidth - (paddingH * 2);
        const aspect = 1.85;
        final widthFactor = isTablet ? 0.7 : 0.88;
        final heightFactor = isTablet ? 0.58 : (isShort ? 0.48 : 0.6);
        final maxCardWidth = math.max(availableWidth * widthFactor, 360.0);
        final maxCardHeight = math.max(
          constraints.maxHeight * heightFactor,
          260.0,
        );
        final cardWidth = math.min(maxCardWidth, maxCardHeight * aspect);
        final cardHeight = cardWidth / aspect;

        final padScale = isTablet ? 1.05 : 1.0;
        final outerPad = (r.dp(1.0) * padScale).clamp(14.0, 22.0);
        final innerPad = (r.dp(1.2) * padScale).clamp(16.0, 24.0);

        final gapTitle = (constraints.maxHeight * 0.02).clamp(8.0, 16.0);
        final gapBlock = (constraints.maxHeight * 0.03).clamp(12.0, 24.0);
        final gapAfter = (constraints.maxHeight * 0.03).clamp(12.0, 22.0);

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: gapTitle),
                Text(
                  'Capture la placa',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.dark,
                    height: 1.05,
                  ),
                ),
                SizedBox(height: gapBlock),
                HikvisionPlateCameraWidget(
                  controller: _cameraController,
                  config: _hikConfig,
                  autoCapture: true,
                  onCaptured: _onCaptured,
                  width: cardWidth,
                  height: cardHeight,
                  padding: EdgeInsets.all(outerPad),
                  framePadding: EdgeInsets.all(innerPad),
                ),
                SizedBox(height: gapAfter),
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Align(
                    alignment: Alignment.bottomLeft,
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
          ),
        );
      },
    );
  }
}
