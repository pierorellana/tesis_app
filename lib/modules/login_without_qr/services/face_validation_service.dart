import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tesis_app/modules/login_without_qr/models/face_validation_response.dart';
import 'package:tesis_app/shared/helpers/global_helper.dart';
import 'package:tesis_app/shared/models/general_response.dart';
import 'package:tesis_app/shared/services/http_interceptor.dart';

class FaceValidationService {
  InterceptorHttp interceptorHttp = InterceptorHttp();

   Future<GeneralResponse<FaceValidationResponse>> getFace(BuildContext context,  {required Map<String, dynamic> queryParameters}) async {
    try {
      final url = 'ocr/face-compare';

      GeneralResponse response = await interceptorHttp.request(context, 'POST', url, null, queryParameters:queryParameters, showLoading: false);
      if(!response.error){
        return GeneralResponse(message: response.message, error: response.error, data: faceValidationResponseFromJson(jsonEncode(response.data)));
      }else{
        return GeneralResponse(message: response.message, error: response.error);
      }

    } catch (error) {
      GlobalHelper.logger.e('error en metodo de getFace: $error');
      return GeneralResponse(message: 'Ocurrió, intentelo de nuevo.', error: true);
    }
  }
}
