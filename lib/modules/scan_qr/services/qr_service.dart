
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tesis_app/modules/scan_qr/models/qr_response.dart';
import 'package:tesis_app/shared/helpers/global_helper.dart';
import 'package:tesis_app/shared/models/general_response.dart';
import 'package:tesis_app/shared/services/http_interceptor.dart';

class QrService {
  InterceptorHttp interceptorHttp = InterceptorHttp();

   Future<GeneralResponse<QrResponse>> validateQr(BuildContext context, {Map<String, dynamic>? queryParams, required String id}) async {
    try {
      final url = 'qrs/$id/validar';

      GeneralResponse response = await interceptorHttp.request(context, 'POST', url, null, queryParameters: queryParams, showLoading: false);
      if(!response.error){
        return GeneralResponse(message: response.message, error: response.error, data: qrResponseFromJson(jsonEncode(response.data)));
      }else{
        return GeneralResponse(message: response.message, error: response.error);
      }

    } catch (error) {
      GlobalHelper.logger.e('error en metodo de validateQr: $error');
      return GeneralResponse(message: 'Ocurrió, intentelo de nuevo.', error: true);
    }
  }
}