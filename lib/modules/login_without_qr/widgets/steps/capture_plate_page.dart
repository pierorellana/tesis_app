import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tesis_app/env/theme/app_theme.dart';
import 'package:tesis_app/modules/login_without_qr/models/plate_response.dart';
import 'package:tesis_app/modules/login_without_qr/services/ocr_plate_service.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/cards/card_camera_widget.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/loadings/reading_plate_widget.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/succes_alerts/plate_registered_page.dart';

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
  late final IdCardCameraController _cameraController;

  final OcrPlateService _plateService = OcrPlateService();

  _PlateUiState _uiState = _PlateUiState.camera;

  String? _plate;

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

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Capture la placa',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 52,
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
}
