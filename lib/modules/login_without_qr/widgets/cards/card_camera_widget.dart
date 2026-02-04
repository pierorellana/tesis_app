import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:tesis_app/env/theme/app_theme.dart';

class IdCardCameraController {
  Future<void> Function()? _takePhoto;
  bool _disposed = false;

  void _bind({required Future<void> Function() takePhoto}) {
    _takePhoto = takePhoto;
  }

  Future<void> takePhoto() async {
    if (_disposed) return;
    final fn = _takePhoto;
    if (fn == null) return;
    await fn();
  }

  void dispose() {
    _disposed = true;
    _takePhoto = null;
  }
}

class IdCardCameraWidget extends StatefulWidget {
  const IdCardCameraWidget({
    super.key,
    required this.controller,
    required this.onCaptured,
    this.autoCapture = false,
  });

  final IdCardCameraController controller;
  final ValueChanged<XFile> onCaptured;
  final bool autoCapture;

  @override
  State<IdCardCameraWidget> createState() => _IdCardCameraWidgetState();
}

class _IdCardCameraWidgetState extends State<IdCardCameraWidget> {
  CameraController? _cam;
  bool _isTaking = false;
  bool _initialized = false;

  late final TextRecognizer _textRecognizer;
  bool _streaming = false;
  bool _autoCaptured = false;
  DateTime _lastProcess = DateTime.fromMillisecondsSinceEpoch(0);
  int _stableHits = 0;

  @override
  void initState() {
    super.initState();
    widget.controller._bind(takePhoto: takePhoto);
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    _initCamera();
  }

  @override
  void didUpdateWidget(covariant IdCardCameraWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      widget.controller._bind(takePhoto: takePhoto);
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        back,
        ResolutionPreset.max,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await controller.initialize();

      if (!mounted) return;
      setState(() {
        _cam = controller;
        _initialized = true;
      });

      if (widget.autoCapture) {
        await _startAutoCaptureStream();
      }
    } catch (e) {
      debugPrint('Error init camera: $e');
    }
  }

  Future<void> _startAutoCaptureStream() async {
    final cam = _cam;
    if (cam == null || _streaming || _autoCaptured) return;

    _streaming = true;

    await cam.startImageStream((CameraImage image) async {
      if (!mounted || _autoCaptured) return;

      final now = DateTime.now();
      if (now.difference(_lastProcess).inMilliseconds < 300) return;
      _lastProcess = now;

      final inputImage = _cameraImageToInputImage(image, cam.description);
      if (inputImage == null) return;

      try {
        final recognized = await _textRecognizer.processImage(inputImage);
        final ok = _looksLikeCedula(recognized.text);

        if (ok) {
          _stableHits++;
        } else {
          _stableHits = 0;
        }

        if (_stableHits >= 4) {
          _autoCaptured = true;
          await _stopStreamSafe();
          await takePhoto();
        }
      } catch (_) {
        // ignorar frame malo
      }
    });
  }

  Future<void> _stopStreamSafe() async {
    final cam = _cam;
    if (cam == null) return;
    if (!_streaming) return;

    try {
      await cam.stopImageStream();
    } catch (_) {}
    _streaming = false;
  }

  bool _looksLikeCedula(String text) {
    final t = text.toUpperCase();

    final hasCedulaDigits = RegExp(r'\b\d{10}\b').hasMatch(t);

    final hasKeywords =
        t.contains('REPUBLICA') ||
        t.contains('IDENTIDAD') ||
        t.contains('CEDULA');

    return hasCedulaDigits || hasKeywords;
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
    } catch (_) {
      return null;
    }
  }

  Future<void> takePhoto() async {
    if (_cam == null || !_cam!.value.isInitialized) return;
    if (_isTaking) return;

    setState(() => _isTaking = true);
    try {
      await _stopStreamSafe();

      final file = await _cam!.takePicture();
      widget.onCaptured(file);
    } catch (e) {
      debugPrint('Error takePicture: $e');
    } finally {
      if (mounted) setState(() => _isTaking = false);
    }
  }

  @override
  void dispose() {
    _stopStreamSafe();
    _textRecognizer.close();
    _cam?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final double cardWidth = (size.width * 0.36).clamp(520.0, 720.0);
    final double cardHeight = (size.height * 0.52).clamp(330.0, 460.0);

    return Container(
      width: cardWidth,
      height: cardHeight,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD7DEE8), width: 1),
        boxShadow: [
          BoxShadow(
            blurRadius: 26,
            offset: const Offset(0, 14),
            color: Colors.black.withOpacity(0.10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: _initialized && _cam != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: CameraPreview(_cam!),
                      )
                    : Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F5FA),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          Icons.photo_camera_outlined,
                          size: 46,
                          color: AppTheme.hinText.withOpacity(0.6),
                        ),
                      ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: CustomPaint(
                  painter: _FramePainter(color: AppTheme.primaryColor),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            if (_isTaking)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.12),
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 34,
                    height: 34,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FramePainter extends CustomPainter {
  final Color color;
  const _FramePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const double stroke = 5;
    const double cornerLength = 48;

    final paint = Paint()
      ..color = color
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final softPaint = Paint()
      ..color = color.withOpacity(0.25)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(18),
    );
    canvas.drawRRect(r, softPaint);

    canvas.drawArc(
      Rect.fromLTWH(0, 0, cornerLength, cornerLength),
      3.14,
      1.57,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromLTWH(size.width - cornerLength, 0, cornerLength, cornerLength),
      -1.57,
      1.57,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromLTWH(0, size.height - cornerLength, cornerLength, cornerLength),
      1.57,
      1.57,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromLTWH(
        size.width - cornerLength,
        size.height - cornerLength,
        cornerLength,
        cornerLength,
      ),
      0,
      1.57,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _FramePainter oldDelegate) =>
      oldDelegate.color != color;
}
