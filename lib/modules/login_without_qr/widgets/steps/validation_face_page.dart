import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tesis_app/env/theme/app_theme.dart';
import 'package:tesis_app/modules/login_without_qr/services/face_validation_service.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/loadings/reading_validation_face.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/rejected_alerts/rejected_validation_face.dart';
import 'package:tesis_app/modules/login_without_qr/widgets/succes_alerts/success_validation_face.dart';

enum _FaceUiState { scanner, validating, success, rejected }

class ValidationFacePage extends StatefulWidget {
  const ValidationFacePage({
    super.key,
    required this.onBack,
    required this.onSuccessNext,
    required this.fotoCedulaBase64,
  });

  final VoidCallback onBack;
  final VoidCallback onSuccessNext;
  final String fotoCedulaBase64;

  @override
  State<ValidationFacePage> createState() => _ValidationFacePageState();
}

class _ValidationFacePageState extends State<ValidationFacePage>
    with SingleTickerProviderStateMixin {
  CameraController? _cam;
  bool _initialized = false;
  bool _isTaking = false;

  late final AnimationController _scanController;
  late final Animation<double> _scanY;

  late final FaceDetector _faceDetector;
  final FaceValidationService _faceValidationService = FaceValidationService();

  bool _streaming = false;
  bool _hasCenteredFace = false;
  DateTime _lastProcess = DateTime.fromMillisecondsSinceEpoch(0);

  _FaceUiState _uiState = _FaceUiState.scanner;
  Timer? _autoCaptureDebounce;
  Timer? _successTimer;

  @override
  void initState() {
    super.initState();

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _scanY = CurvedAnimation(parent: _scanController, curve: Curves.easeInOut);
    _scanController.repeat(reverse: true);

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: false,
        enableContours: false,
        enableTracking: true,
        performanceMode: FaceDetectorMode.fast,
      ),
    );

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        front,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await controller.initialize();
      await controller.setFlashMode(FlashMode.off);

      if (!mounted) return;
      setState(() {
        _cam = controller;
        _initialized = true;
      });

      await _startFaceStream();
    } catch (e) {
      debugPrint('Error init face camera: $e');
    }
  }

  Future<void> _startFaceStream() async {
    final cam = _cam;
    if (cam == null || _streaming) return;

    _streaming = true;

    await cam.startImageStream((CameraImage image) async {
      if (!mounted) return;
      if (_uiState != _FaceUiState.scanner) return;
      if (_isTaking) return;

      final now = DateTime.now();
      if (now.difference(_lastProcess).inMilliseconds < 220) return;
      _lastProcess = now;

      final inputImage = _cameraImageToInputImage(image, cam.description);
      if (inputImage == null) return;

      try {
        final faces = await _faceDetector.processImage(inputImage);

        final bool centered = _isFaceGoodToCapture(
          faces: faces,
          imageSize: Size(
            inputImage.metadata!.size.width.toDouble(),
            inputImage.metadata!.size.height.toDouble(),
          ),
        );

        if (centered != _hasCenteredFace) {
          setState(() => _hasCenteredFace = centered);
        }

        if (centered) {
          _autoCaptureDebounce ??= Timer(const Duration(milliseconds: 650), () {
            _autoCaptureDebounce = null;
            if (mounted &&
                _uiState == _FaceUiState.scanner &&
                !_isTaking &&
                _hasCenteredFace) {
              _captureAndValidate();
            }
          });
        } else {
          _autoCaptureDebounce?.cancel();
          _autoCaptureDebounce = null;
        }
      } catch (_) {}
    });
  }

  InputImage? _cameraImageToInputImage(
    CameraImage image,
    CameraDescription desc,
  ) {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final rotation = InputImageRotationValue.fromRawValue(
        desc.sensorOrientation,
      );
      final format = InputImageFormatValue.fromRawValue(image.format.raw);

      if (rotation == null || format == null) return null;

      final metadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      );

      return InputImage.fromBytes(bytes: bytes, metadata: metadata);
    } catch (e) {
      debugPrint('Error building InputImage: $e');
      return null;
    }
  }

  bool _isFaceGoodToCapture({
    required List<Face> faces,
    required Size imageSize,
  }) {
    if (faces.isEmpty) return false;

    faces.sort((a, b) => b.boundingBox.area.compareTo(a.boundingBox.area));
    final face = faces.first;
    final box = face.boundingBox;

    final cx = box.left + box.width / 2;
    final cy = box.top + box.height / 2;

    final icx = imageSize.width / 2;
    final icy = imageSize.height / 2;

    final dx = (cx - icx).abs() / imageSize.width;
    final dy = (cy - icy).abs() / imageSize.height;

    final sizeRatio = max(
      box.width / imageSize.width,
      box.height / imageSize.height,
    );

    final leftOpen = face.leftEyeOpenProbability;
    final rightOpen = face.rightEyeOpenProbability;

    final eyesOk =
        (leftOpen == null || leftOpen > 0.35) &&
        (rightOpen == null || rightOpen > 0.35);

    return dx < 0.12 && dy < 0.12 && sizeRatio > 0.22 && eyesOk;
  }

  Future<void> _captureAndValidate() async {
    final cam = _cam;
    if (cam == null || !cam.value.isInitialized) return;
    if (_isTaking) return;

    setState(() {
      _isTaking = true;
      _uiState = _FaceUiState.validating;
      _hasCenteredFace = false;
    });

    _autoCaptureDebounce?.cancel();
    _autoCaptureDebounce = null;

    try {
      if (_streaming) {
        await cam.stopImageStream();
        _streaming = false;
      }

      await Future.delayed(const Duration(milliseconds: 180));

      final XFile file = await cam.takePicture();

      final liveBase64 = await _xfileToBase64(file);

      final ok = await _getFaceCompare(
        fotoCedulaBase64: widget.fotoCedulaBase64,
        fotoRostroVivoBase64: liveBase64,
      );

      if (!mounted) return;

      if (ok) {
        setState(() => _uiState = _FaceUiState.success);

        _successTimer?.cancel();
        _successTimer = Timer(const Duration(seconds: 3), () {
          if (!mounted) return;
          widget.onSuccessNext();
        });
      } else {
        setState(() => _uiState = _FaceUiState.rejected);
      }
    } catch (e) {
      debugPrint('Error capture/validate face: $e');
      if (mounted) setState(() => _uiState = _FaceUiState.rejected);
    } finally {
      if (mounted) setState(() => _isTaking = false);
    }
  }

  Future<bool> _getFaceCompare({
    required String fotoCedulaBase64,
    required String fotoRostroVivoBase64,
  }) async {
    final response = await _faceValidationService.getFace(
      context,
      queryParameters: {
        "foto_cedula_base64": fotoCedulaBase64,
        "foto_rostro_vivo_base64": fotoRostroVivoBase64,
      },
    );

    if (!response.error && response.data != null) {
      return response.data!.match == true;
    }
    return false;
  }

  Future<String> _xfileToBase64(XFile file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> _retry() async {
    if (!mounted) return;
    setState(() => _uiState = _FaceUiState.scanner);

    try {
      await _startFaceStream();
    } catch (_) {}
  }

  @override
  void dispose() {
    _autoCaptureDebounce?.cancel();
    _successTimer?.cancel();
    _scanController.dispose();
    _faceDetector.close();
    _cam?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_uiState == _FaceUiState.validating) {
      return const ValidateFaceWidget();
    }
    if (_uiState == _FaceUiState.success) {
      return const SuccessValidationFace();
    }
    if (_uiState == _FaceUiState.rejected) {
      return RejectedValidationFace(
        onRetry: _retry,
        onBackToStart: widget.onBack,
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Validación facial',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.bold,
            color: AppTheme.dark,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          'Mire al frente y manténgase dentro del marco',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: AppTheme.hinText,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 22),
        _FaceCircleScanner(
          initialized: _initialized,
          cam: _cam,
          scanAnimation: _scanY,
          highlight: _hasCenteredFace,
          isTaking: _isTaking,
        ),
        const SizedBox(height: 16),
        Text(
          _hasCenteredFace
              ? '¡Perfecto! Manténgase quieto...'
              : 'Retire accesorios',
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
}

class _FaceCircleScanner extends StatelessWidget {
  const _FaceCircleScanner({
    required this.initialized,
    required this.cam,
    required this.scanAnimation,
    required this.highlight,
    required this.isTaking,
  });

  final bool initialized;
  final CameraController? cam;
  final Animation<double> scanAnimation;
  final bool highlight;
  final bool isTaking;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final double diameter = (min(size.width, size.height) * 0.34).clamp(
      260.0,
      360.0,
    );

    final borderColor = highlight
        ? const Color(0xFF14A44D)
        : AppTheme.primaryColor;

    return SizedBox(
      width: diameter,
      height: diameter,
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (initialized && cam != null)
              Transform.scale(scale: 1.25, child: CameraPreview(cam!))
            else
              Container(
                color: const Color(0xFFF2F5FA),
                alignment: Alignment.center,
                child: Icon(
                  Icons.photo_camera_outlined,
                  size: 46,
                  color: AppTheme.hinText.withOpacity(0.6),
                ),
              ),
            AnimatedBuilder(
              animation: scanAnimation,
              builder: (context, child) {
                final dy = (diameter - 40) * scanAnimation.value;
                return Align(
                  alignment: Alignment.topCenter,
                  child: Transform.translate(
                    offset: Offset(0, dy),
                    child: child,
                  ),
                );
              },
              child: Container(
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 22),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                      color: AppTheme.primaryColor.withOpacity(0.25),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.18)],
                  radius: 1.05,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor.withOpacity(0.75),
                  width: 4,
                ),
              ),
            ),
            if (isTaking)
              Container(
                color: Colors.black.withOpacity(0.12),
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 34,
                  height: 34,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

extension on Rect {
  double get area => width * height;
}
