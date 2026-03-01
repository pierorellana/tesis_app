import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tesis_app/modules/login_without_qr/models/resident_response.dart';
import 'package:tesis_app/shared/helpers/global_helper.dart';
import 'package:tesis_app/shared/models/general_response.dart';
import 'package:tesis_app/shared/services/http_interceptor.dart';

class ResidentService {
  InterceptorHttp interceptorHttp = InterceptorHttp();

  Future<GeneralResponse<ResidentResponse>> getResident(BuildContext context, {required String manzana, required String villa}) async {
    try {
      const url = 'catalogo/residente';
      GeneralResponse response = await interceptorHttp.request(context, 'GET', url, null, showLoading: false, queryParameters: {'manzana': manzana, 'villa': villa});
      if (!response.error) {
        return GeneralResponse(message: response.message, error: response.error, data: residentResponseFromJson(jsonEncode(response.data)));
      } else {
        return GeneralResponse(message: response.message, error: response.error);
      }

    } catch (error) {
      GlobalHelper.logger.e('error en metodo de getResident: $error');
      return GeneralResponse(message: 'Ocurrió, intentelo de nuevo.', error: true);
    }
  }
}
