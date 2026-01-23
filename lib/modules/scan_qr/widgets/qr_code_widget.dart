import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:tesis_app/env/theme/app_theme.dart';
import 'package:tesis_app/shared/providers/functional_provider.dart';

class QrCodeWidget extends StatefulWidget {
  const QrCodeWidget({super.key, this.onQrDetected});

  final ValueChanged<String>? onQrDetected;

  @override
  State<QrCodeWidget> createState() => _QrCodeWidgetState();
}

class _QrCodeWidgetState extends State<QrCodeWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _y;

  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  bool _alreadyScanned = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _y = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fp = context.read<FunctionalProvider>();

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
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(22),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: MobileScanner(
                  controller: _scannerController,
                  fit: BoxFit.cover,
                  onDetect: (capture) {
                    if (_alreadyScanned) return;

                    final barcode = capture.barcodes.firstOrNull;
                    final value = barcode?.rawValue;

                    if (value != null && value.isNotEmpty) {
                      _alreadyScanned = true;
                      debugPrint('QR DETECTADO: $value');
                      widget.onQrDetected?.call(value);
                      _scannerController.stop();
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: CustomPaint(
                painter: _QrFramePainter(color: AppTheme.primaryColor),
                child: const SizedBox.expand(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const topPadding = 20.0;
                  const bottomPadding = 20.0;

                  final maxDy =
                      (constraints.maxHeight - topPadding - bottomPadding)
                          .clamp(0.0, double.infinity);
                  return AnimatedBuilder(
                    animation: _y,
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 34),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                            color: AppTheme.primaryColor.withOpacity(0.25),
                          ),
                        ],
                      ),
                    ),
                    builder: (context, child) {
                      final dy = topPadding + (maxDy * _y.value);
                      return Align(
                        alignment: Alignment.topCenter,
                        child: Transform.translate(
                          offset: Offset(0, dy),
                          child: child,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension _FirstOrNullExt<E> on List<E> {
  E? get firstOrNull => isEmpty ? null : first;
}

class _QrFramePainter extends CustomPainter {
  final Color color;
  const _QrFramePainter({required this.color});

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
  bool shouldRepaint(covariant _QrFramePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
