import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:tesis_app/modules/login_without_qr/models/plate_response.dart';
import 'package:tesis_app/shared/helpers/global_helper.dart';
import 'package:tesis_app/shared/models/general_response.dart';
import 'package:tesis_app/shared/services/http_interceptor.dart';

class OcrPlateService {
  InterceptorHttp interceptorHttp = InterceptorHttp();

  Future<GeneralResponse<PlateResponse>> getPlate(
    BuildContext context, {
    required XFile file,
  }) async {
    try {
      final url = 'ocr/placa';

      final multipart = await _buildPngMultipart(file);

      GeneralResponse response = await interceptorHttp.request(
        context,
        'POST',
        url,
        null,
        showLoading: false,
        requestType: "FORM",
        multipartFiles: [multipart],
      );
      if (!response.error) {
        final parsed = _parsePlateData(response.data);
        if (parsed != null) {
          return GeneralResponse(
            message: response.message,
            error: response.error,
            data: parsed,
          );
        }
        return GeneralResponse(
          message: 'Respuesta inválida del OCR.',
          error: true,
        );
      } else {
        return GeneralResponse(
          message: response.message,
          error: response.error,
        );
      }
    } catch (error) {
      GlobalHelper.logger.e('error en metodo de getPlate: $error');
      return GeneralResponse(
        message: 'Ocurrió, intentelo de nuevo.',
        error: true,
      );
    }
  }

  Future<http.MultipartFile> _buildPngMultipart(XFile file) async {
    try {
      final pngBytes = await _convertToPngBytes(file);
      if (pngBytes != null && pngBytes.isNotEmpty) {
        final filename = _toPngFilename(file);
        return http.MultipartFile.fromBytes(
          'file',
          pngBytes,
          filename: filename,
          contentType: MediaType('image', 'png'),
        );
      }
    } catch (e) {
      GlobalHelper.logger.e('Error al convertir a PNG: $e');
    }

    return http.MultipartFile.fromPath(
      'file',
      file.path,
      contentType: MediaType('image', 'jpeg'),
    );
  }

  Future<Uint8List?> _convertToPngBytes(XFile file) async {
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return byteData?.buffer.asUint8List();
  }

  String _toPngFilename(XFile file) {
    final name = file.name.isNotEmpty
        ? file.name
        : 'placa_${DateTime.now().millisecondsSinceEpoch}.png';
    if (name.toLowerCase().endsWith('.png')) return name;
    final dot = name.lastIndexOf('.');
    if (dot > 0) {
      return '${name.substring(0, dot)}.png';
    }
    return '$name.png';
  }

  PlateResponse? _parsePlateData(dynamic raw) {
    try {
      if (raw == null) return null;
      if (raw is PlateResponse) return raw;
      if (raw is Map<String, dynamic>) {
        return PlateResponse.fromJson(raw);
      }
      if (raw is String) {
        final decoded = json.decode(raw);
        if (decoded is Map<String, dynamic>) {
          return PlateResponse.fromJson(decoded);
        }
      }
      return null;
    } catch (e) {
      GlobalHelper.logger.e('Error parseando OCR: $e');
      return null;
    }
  }
}
