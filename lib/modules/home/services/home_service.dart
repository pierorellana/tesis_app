// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:telcoai_app/modules/home/models/user_info_response.dart';
// import 'package:telcoai_app/shared/helpers/global_helper.dart';
// import 'package:telcoai_app/shared/models/general_response.dart';
// import 'package:telcoai_app/shared/services/http_interceptor.dart';

// class HomeService {
//   InterceptorHttp interceptorHttp = InterceptorHttp();

//   //  Future<GeneralResponse<CheckAuthResponse>> checkAuth(BuildContext context) async {
//   //   try {
//   //     const url = 'auth/check-auth';
//   //     GeneralResponse response = await interceptorHttp.request(context, 'POST', url, null);

//   //     CheckAuthResponse? userDataResponse;

//   //     if(!response.error){
//   //       userDataResponse = checkAuthResponseFromJson(jsonEncode(response.data));
//   //     }

//   //     return GeneralResponse(message: response.message, error: response.error, data: userDataResponse);

//   //   } catch (error) {
//   //     GlobalHelper.logger.e('error en metodo de checkAuth: $error');
//   //     return GeneralResponse(message: 'Ocurrió, intentelo de nuevo.', error: true);
//   //   }
//   // }

//   // Future<GeneralResponse<UserResponse>> user(BuildContext context, String userId) async {
//   //   try {
//   //     String url = 'users/$userId';
//   //     GeneralResponse response = await interceptorHttp.request(context, 'GET', url, null);

//   //     UserResponse? userDataResponse;

//   //     if(!response.error){
//   //       userDataResponse = userResponseFromJson(jsonEncode(response.data));
//   //     }

//   //     return GeneralResponse(message: response.message, error: response.error, data: userDataResponse);

//   //   } catch (error) {
//   //     GlobalHelper.logger.e('error en metodo de user: $error');
//   //     return GeneralResponse(message: 'Ocurrió, intentelo de nuevo.', error: true);
//   //   }
//   // }
// }