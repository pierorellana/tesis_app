import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tesis_app/modules/login_without_qr/models/catalogue_response.dart';
import 'package:tesis_app/shared/helpers/global_helper.dart';
import 'package:tesis_app/shared/models/general_response.dart';
import 'package:tesis_app/shared/services/http_interceptor.dart';


class CatalogueService {
  InterceptorHttp interceptorHttp = InterceptorHttp();

  Future<GeneralResponse<List<CatalogueResponse>>> getCatalogue(BuildContext context) async {
    try {
      const url = 'catalogo/viviendas';
      GeneralResponse response = await interceptorHttp.request(context, 'GET', url, null, showLoading: false);
      if(!response.error){
        return GeneralResponse(message: response.message, error: response.error, data: catalogueResponseFromJson(jsonEncode(response.data)));
      }else{
        return GeneralResponse(message: response.message, error: response.error);
      }

    } catch (error) {
      GlobalHelper.logger.e('error en metodo de getCatalogue: $error');
      return GeneralResponse(message: 'Ocurrió, intentelo de nuevo.', error: true);
    }
  }
}
