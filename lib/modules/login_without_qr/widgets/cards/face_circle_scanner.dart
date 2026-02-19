import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:tesis_app/env/theme/app_theme.dart';

class FaceCircleScanner extends StatelessWidget {
  const FaceCircleScanner({
    super.key,
    required this.size,
    required this.controller,
    this.errorMessage,
  });

  final double size;
  final VideoController? controller;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          ClipOval(
            child: controller == null
                ? _buildPlaceholder()
                : Video(controller: controller!, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _CircleFramePainter(color: AppTheme.primaryColor),
            ),
          ),
          if (errorMessage != null)
            Positioned.fill(
              child: Center(
                child: Text(
                  kDebugMode
                      ? 'No se pudo conectar a la camara\n$errorMessage'
                      : 'No se pudo conectar a la camara',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      alignment: Alignment.center,
      color: const Color(0xFFF2F5FA),
      child: Icon(
        Icons.person_outline,
        size: 46,
        color: AppTheme.hinText.withOpacity(0.6),
      ),
    );
  }
}

class _CircleFramePainter extends CustomPainter {
  final Color color;
  const _CircleFramePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final softPaint = Paint()
      ..color = color.withOpacity(0.25)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawOval(rect, softPaint);
    canvas.drawOval(rect.deflate(2), paint);
  }

  @override
  bool shouldRepaint(covariant _CircleFramePainter oldDelegate) =>
      oldDelegate.color != color;
}
