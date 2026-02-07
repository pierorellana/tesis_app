import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tesis_app/modules/login_without_qr/models/cedula_response.dart';
import 'package:tesis_app/shared/helpers/global_helper.dart';
import 'package:tesis_app/shared/models/general_response.dart';
import 'package:tesis_app/shared/services/http_interceptor.dart';

class OcrCedulaService {
  InterceptorHttp interceptorHttp = InterceptorHttp();

   Future<GeneralResponse<CedulaResponse>> getCedula(BuildContext context, {required XFile file}) async {
    try {
      final url = 'ocr/cedula';

      final multipart = await http.MultipartFile.fromPath('file', file.path);

      GeneralResponse response = await interceptorHttp.request(context, 'POST', url, null, showLoading: false, requestType: "FORM", multipartFiles: [multipart]);
      if(!response.error){
        return GeneralResponse(message: response.message, error: response.error, data: cedulaResponseFromJson(jsonEncode(response.data)));
      }else{
        return GeneralResponse(message: response.message, error: response.error);
      }

    } catch (error) {
      GlobalHelper.logger.e('error en metodo de getCedula: $error');
      return GeneralResponse(message: 'Ocurrió, intentelo de nuevo.', error: true);
    }
  }
}
