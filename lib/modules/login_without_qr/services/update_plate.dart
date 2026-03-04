import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tesis_app/modules/login_without_qr/models/update_response.dart';
import 'package:tesis_app/shared/helpers/global_helper.dart';
import 'package:tesis_app/shared/models/general_response.dart';
import 'package:tesis_app/shared/services/http_interceptor.dart';

class UpdatePlateService {
  InterceptorHttp interceptorHttp = InterceptorHttp();

  Future<GeneralResponse<UpdatePlateResponse>> updatePlate(
    BuildContext context, { required int accesoPk, required Map<String, dynamic> dataPlate}) async {
    try {
      final url = 'accesos/$accesoPk/placa';

      GeneralResponse response = await interceptorHttp.request(context, 'PATCH', url, dataPlate, showLoading: false);
      if (!response.error) {
        return GeneralResponse(message: response.message, error: response.error, data: updatePlateResponseFromJson(jsonEncode(response.data)));
      } else {
        return GeneralResponse(message: response.message, error: response.error);
      }
    } catch (error) {
      GlobalHelper.logger.e('error en metodo de updatePlate: $error');
      return GeneralResponse(message: 'Ocurrió, intentelo de nuevo.', error: true);
    }
  }
}
