import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tesis_app/modules/login_without_qr/models/access_visit_response.dart';
import 'package:tesis_app/modules/login_without_qr/models/create_access_response.dart';
import 'package:tesis_app/shared/helpers/global_helper.dart';
import 'package:tesis_app/shared/models/general_response.dart';
import 'package:tesis_app/shared/services/http_interceptor.dart';

class CreateAccessService {
  InterceptorHttp interceptorHttp = InterceptorHttp();

  Future<GeneralResponse<CreateAccessResponse>> getAccess(BuildContext context, {required Map<String, dynamic> dataAccess}) async {
    try {
      final url = 'accesos';

      GeneralResponse response = await interceptorHttp.request(context, 'POST', url, dataAccess, showLoading: false);
      if (!response.error) {
        return GeneralResponse(message: response.message, error: response.error, data: createAccessResponseFromJson(jsonEncode(response.data)));
      } else {
        return GeneralResponse(message: response.message, error: response.error);
      }
    } catch (error) {
      GlobalHelper.logger.e('error en metodo de getAccess: $error');
      return GeneralResponse(message: 'Ocurrió, intentelo de nuevo.', error: true);
    }
  }
}

class AccessVisitService {
  InterceptorHttp interceptorHttp = InterceptorHttp();

  Future<GeneralResponse<AccessVisitResponse>> getAccessVisit(
    BuildContext context, {
    required int accesoPk,
  }) async {
    try {
      final url = 'accesos/$accesoPk/estado';
      GeneralResponse response = await interceptorHttp.request(
        context,
        'GET',
        url,
        null,
        showLoading: false,
      );
      if (!response.error) {
        return GeneralResponse(
          message: response.message,
          error: response.error,
          data: accessVisitResponseFromJson(jsonEncode(response.data)),
        );
      } else {
        return GeneralResponse(message: response.message, error: response.error);
      }

    } catch (error) {
      GlobalHelper.logger.e('error en metodo de getAccessVisit: $error');
      return GeneralResponse(message: 'Ocurrió, intentelo de nuevo.', error: true);
    }
  }
}

