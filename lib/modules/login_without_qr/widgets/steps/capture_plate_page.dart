import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tesis_app/env/theme/app_theme.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/cards/card_camera_widget.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/succes_alerts/plate_registered_page.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/loadings/reading_plate_widget.dart';

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

  _PlateUiState _uiState = _PlateUiState.camera;
  Timer? _timer;

  String _plate = 'ABC-1234';

  @override
  void initState() {
    super.initState();
    _cameraController = IdCardCameraController();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    await _cameraController.takePhoto();
  }

  void _onCaptured(XFile file) {
    setState(() => _uiState = _PlateUiState.reading);

    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      setState(() => _uiState = _PlateUiState.success);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_uiState == _PlateUiState.reading) {
      return ReadingPlateWidget();
    }

    if (_uiState == _PlateUiState.success) {
      return PlateRegisteredPage(
        plate: _plate,
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
          onCaptured: _onCaptured,
        ),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 160,
              height: 58,
              child: ElevatedButton.icon(
                onPressed: _capture,
                icon: const Icon(Icons.link),
                label: const Text(
                  'Capturar',
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
            const SizedBox(width: 14),
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
        ),
      ],
    );
  }
}
