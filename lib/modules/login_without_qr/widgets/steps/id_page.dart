import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tesis_app/env/theme/app_theme.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/cards/card_camera_widget.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/informations/information_id_widget.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/loadings/reading_id_widget.dart';
import 'package:tesis_app/shared/helpers/global_helper.dart';
import 'package:tesis_app/shared/helpers/global_helper.dart' as GlobalHelper;

class IdPage extends StatefulWidget {
  const IdPage({super.key, required this.onBack, required this.onConfirmed});

  final VoidCallback onBack;
  final void Function(IdParsedData data) onConfirmed;

  @override
  State<IdPage> createState() => _IdPageState();
}

class _IdPageState extends State<IdPage> {
  late final IdCardCameraController _cameraController;

  GlobalHelper.IdUiState _uiState = IdUiState.camera;
  XFile? lastPhoto;
  Timer? _timer;

  IdParsedData? _parsed;

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
    debugPrint('FOTO CEDULA: ${file.path}');
    lastPhoto = file;

    setState(() {
      _uiState = IdUiState.reading;
      _parsed = null;
    });

    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;

      setState(() {
        _parsed = const IdParsedData(
          names: 'PIERRE ALEXANDER',
          surnames: 'ORELLANA DELGADO',
          identification: '0945678767',
        );

        _uiState = IdUiState.confirm;
      });
    });
  }

  void _retryPhoto() {
    _timer?.cancel();
    setState(() {
      _uiState = IdUiState.camera;
      _parsed = null;
      lastPhoto = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_uiState == IdUiState.camera) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 160,
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: _capture,
                  icon: const Icon(Icons.description_outlined),
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
              const SizedBox(width: 15),
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

    if (_uiState == IdUiState.reading) {
      return const ReadingIdInfoWidget();
    }

    return ConfirmIdDataWidget(
      data:
          _parsed ??
          const IdParsedData(names: '-', surnames: '-', identification: '-'),
      onConfirm: () {
        widget.onConfirmed(_parsed!);
      },
      onRetry: _retryPhoto,
    );
  }
}
