import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tesis_app/modules/login_without_qr/models/call_response.dart';
import 'package:tesis_app/shared/helpers/global_helper.dart';
import 'package:tesis_app/shared/models/general_response.dart';
import 'package:tesis_app/shared/services/http_interceptor.dart';

class CallService {
  InterceptorHttp interceptorHttp = InterceptorHttp();

  Future<GeneralResponse<CallResponse>> getCall(
    BuildContext context, { required int accesoPk, required Map<String, dynamic> dataCall}) async {
    try {
      final url = 'accesos/$accesoPk/llamar';

      GeneralResponse response = await interceptorHttp.request(context, 'POST', url, dataCall, showLoading: false);
      if (!response.error) {
        return GeneralResponse(message: response.message, error: response.error, data: callResponseFromJson(jsonEncode(response.data)));
      } else {
        return GeneralResponse(message: response.message, error: response.error);
      }
    } catch (error) {
      GlobalHelper.logger.e('error en metodo de getCall: $error');
      return GeneralResponse(message: 'Ocurrió, intentelo de nuevo.', error: true);
    }
  }
}
