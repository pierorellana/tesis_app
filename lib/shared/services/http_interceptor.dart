import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:tesis_app/shared/providers/functional_provider.dart';
import '../../env/environment.dart';
import '../helpers/global_helper.dart';
import '../models/general_response.dart';
import '../widgets/alert_template.dart';

class InterceptorHttp {
  Future<GeneralResponse> request(
    BuildContext context,
    String method,
    String urlEndPoint,
    dynamic body, {
    bool showAlertError = true,
    bool showLoading = true,
    Map<String, dynamic>? queryParameters,
    List<http.MultipartFile>? multipartFiles,
    Map<String, String>? multipartFields,
    String requestType = "JSON",
    Function(int sentBytes, int totalBytes)? onProgressLoad,
  }) async {
    final urlService = Environment().config?.serviceUrl ?? "no url";

    String url =
        "$urlService$urlEndPoint?${Uri(queryParameters: queryParameters).query}";

    GlobalHelper.logger.t('URL $method: $url');

    body != null
        ? GlobalHelper.logger.log(Level.trace, 'body: ${json.encode(body)}')
        : null;
    queryParameters != null
        ? GlobalHelper.logger.log(
            Level.trace,
            'queryParameters: ${json.encode(queryParameters)}',
          )
        : null;

    GeneralResponse generalResponse = GeneralResponse(
      data: null,
      message: "",
      error: true,
    );

    final fp = Provider.of<FunctionalProvider>(context, listen: false);
    final keyLoading = GlobalHelper.genKey();
    // final keyError = GlobalHelper.genKey();

    // String? messageButton;
    // void Function()? onPress;

    int responseStatusCode = 0;

    try {
      http.Response response;
      Uri uri = Uri.parse(url);

      if (showLoading) {
        fp.showAlert(key: keyLoading, content: const AlertLoading());
        await Future.delayed(const Duration(milliseconds: 600));
      }

      //? Envio de TOKEN
      // LoginResponse? userData = await UserDataStorage().getUserData();

      // String tokenSesion = "";

      // if (userData != null) {
      //   tokenSesion = userData.token;
      // }

      Map<String, String> headers = {
        "Content-Type": "application/json",
        // "Authorization": (requestType == 'JSON')
        //     ? "Bearer $tokenSesion"
        //     : "Bearer $tokenSesion",
      };

      // GlobalHelper.logger.log(Level.trace, 'headers: ${json.encode(headers)}');

      String responseBody = "";

      String _extractMessage(dynamic decoded) {
        try {
          if (decoded == null) return "Ocurrió un problema inesperado.";

          if (decoded is Map<String, dynamic>) {
            final msg = decoded["message"];
            if (msg is String && msg.isNotEmpty) return msg;

            final err = decoded["error"];
            if (err is Map<String, dynamic>) {
              final errMsg = err["message"];
              if (errMsg is String && errMsg.isNotEmpty) return errMsg;
            }

            final detail = decoded["detail"];
            if (detail is String && detail.isNotEmpty) return detail;
          }

          return "Hubo un problema al procesar la información. Intente nuevamente más tarde.";
        } catch (_) {
          return "Hubo un problema al procesar la información. Intente nuevamente más tarde.";
        }
      }

      dynamic _tryDecodeJson(String value) {
        final trimmed = value.trimLeft();
        if (trimmed.isEmpty) return null;
        if (!(trimmed.startsWith('{') || trimmed.startsWith('['))) {
          return null;
        }
        try {
          return json.decode(value);
        } catch (_) {
          return null;
        }
      }

      switch (requestType) {
        case "JSON":
          switch (method) {
            case "POST":
              response = await http.post(
                uri,
                headers: headers,
                body: body != null ? json.encode(body) : null,
              );
              break;
            case "GET":
              response = await http.get(uri, headers: headers);
              break;
            case "PUT":
              response = await http.put(
                uri,
                headers: headers,
                body: body != null ? json.encode(body) : null,
              );
              break;
            case "PATCH":
              response = await http.patch(
                uri,
                headers: headers,
                body: body != null ? json.encode(body) : null,
              );
              break;

            default:
              response = await http.post(uri, body: jsonEncode(body));
              break;
          }
          responseStatusCode = response.statusCode;
          responseBody = response.body;

          GlobalHelper.logger.w('statusCode: $responseStatusCode');
          final decoded = _tryDecodeJson(responseBody);
          if (decoded != null) {
            GlobalHelper.logger.log(Level.trace, decoded);
          } else {
            GlobalHelper.logger.log(Level.trace, 'responseBody: $responseBody');
          }

          break;
        case "FORM":
          final httpClient = getHttpClient();
          final request = await httpClient.postUrl(Uri.parse(url));

          int byteCount = 0;
          var requestMultipart = http.MultipartRequest(method, Uri.parse(url));

          if (multipartFiles != null) {
            requestMultipart.files.addAll(multipartFiles);
          }
          if (multipartFields != null) {
            requestMultipart.fields.addAll(multipartFields);
          }

          if (multipartFields != null && multipartFields.isNotEmpty) {
            GlobalHelper.logger.log(
              Level.trace,
              'multipartFields: ${json.encode(multipartFields)}',
            );
          }
          if (multipartFiles != null && multipartFiles.isNotEmpty) {
            final filesDebug = multipartFiles
                .map(
                  (f) => {
                    'field': f.field,
                    'filename': f.filename,
                  },
                )
                .toList();
            GlobalHelper.logger.log(
              Level.trace,
              'multipartFiles: ${json.encode(filesDebug)}',
            );
          }

          // requestMultipart.headers['Authorization'] = 'Bearer $tokenSesion';

          var msStream = requestMultipart.finalize();
          var totalByteLength = requestMultipart.contentLength;

          request.contentLength = totalByteLength;
          request.headers.set(
            HttpHeaders.contentTypeHeader,
            requestMultipart.headers[HttpHeaders.contentTypeHeader]!,
          );

          // request.headers.add('Authorization', 'Bearer $tokenSesion');

          Stream<List<int>> streamUpload = msStream.transform(
            StreamTransformer.fromHandlers(
              handleData: (data, sink) {
                sink.add(data);
                byteCount += data.length;
                if (onProgressLoad != null) {
                  onProgressLoad(byteCount, totalByteLength);
                }
              },
              handleError: (error, stack, sink) {
                generalResponse.error = true;
                throw error;
              },
              handleDone: (sink) {
                sink.close();
              },
            ),
          );

          await request.addStream(streamUpload);

          final httpResponse = await request.close();
          var statusCode = httpResponse.statusCode;

          responseStatusCode = statusCode;
          responseBody = await readResponseAsString(httpResponse);
          if (statusCode ~/ 100 != 2) {
            GlobalHelper.logger.e("Error en la solicitud: $responseBody");
          }

          GlobalHelper.logger.w('statusCode: $responseStatusCode');
          final decoded = _tryDecodeJson(responseBody);
          if (decoded != null) {
            GlobalHelper.logger.log(Level.trace, decoded);
          } else {
            GlobalHelper.logger.log(Level.trace, 'responseBody: $responseBody');
          }
        
          break;
      }

      switch (responseStatusCode) {
        case 200:
          final responseDecoded = _tryDecodeJson(responseBody);
          if (responseDecoded is Map<String, dynamic>) {
            generalResponse.data = responseDecoded["data"];
            generalResponse.message = responseDecoded["message"];
            generalResponse.error = false;
          } else {
            generalResponse.error = true;
            generalResponse.message =
                "Respuesta inválida del servidor. Revise los logs.";
          }
          break;
        case 201:
          final responseDecoded = _tryDecodeJson(responseBody);
          if (responseDecoded is Map<String, dynamic>) {
            generalResponse.data = responseDecoded["data"];
            generalResponse.message = responseDecoded["message"];
            generalResponse.error = false;
          } else {
            generalResponse.error = true;
            generalResponse.message =
                "Respuesta inválida del servidor. Revise los logs.";
          }
          break;
        case 400:
          final responseDecoded = _tryDecodeJson(responseBody);
          generalResponse.message = _extractMessage(responseDecoded);
          generalResponse.error = true;
          fp.dismissAlert(key: keyLoading);
          break;
        case 401:
          final responseDecoded = _tryDecodeJson(responseBody);
          generalResponse.message = _extractMessage(responseDecoded);
          generalResponse.error = true;
          fp.dismissAlert(key: keyLoading);
          break;
        case 404:
          final responseDecoded = _tryDecodeJson(responseBody);
          generalResponse.message = _extractMessage(responseDecoded);
          generalResponse.error = true;
          fp.dismissAlert(key: keyLoading);
          break;
        default:
          final responseDecoded = _tryDecodeJson(responseBody);
          generalResponse.error = true;
          generalResponse.message = _extractMessage(responseDecoded);
          fp.dismissAlert(key: keyLoading);
          break;
      }
    } on HandshakeException catch (e) {
      GlobalHelper.logger.e("Error de certificado SSL: $e");
      generalResponse.error = true;
      generalResponse.message =
          "No se pudo establecer una conexión segura con el servidor. Verifique su conexión o contacte al soporte técnico.";
      fp.dismissAlert(key: keyLoading);
    } on TimeoutException catch (e) {
      GlobalHelper.logger.e("ERROR ON TimeoutException->: $e");
      generalResponse.error = true;
      generalResponse.message =
          'La conexión tardó demasiado y se agotó el tiempo. Por favor, intente nuevamente más tarde.';
      fp.dismissAlert(key: keyLoading);
    } on FormatException catch (ex) {
      generalResponse.error = true;
      generalResponse.message =
          "Hubo un problema al procesar la información. Intente nuevamente más tarde.";
      GlobalHelper.logger.e(ex);
      fp.dismissAlert(key: keyLoading);
    } on SocketException catch (exSock) {
      GlobalHelper.logger.e("Error por conexion: $exSock");
      generalResponse.error = true;
      generalResponse.message =
          "Verifique su conexión a internet y vuelva a intentar.";
      fp.dismissAlert(key: keyLoading);
    } on Exception catch (e, stacktrace) {
      GlobalHelper.logger.e("Error en request: $stacktrace");
      generalResponse.error = true;
      generalResponse.message =
          "Ocurrió un problema inesperado. Por favor, intente nuevamente más tarde.";
      fp.dismissAlert(key: keyLoading);
    } on Error catch (e, stacktrace) {
      GlobalHelper.logger.e("Error en request: $stacktrace");
      generalResponse.error = true;
      generalResponse.message =
          "Ha ocurrido un error inesperado. Intente nuevamente más tarde.";
      fp.dismissAlert(key: keyLoading);
    }
    if (!generalResponse.error) {
      if (showLoading) {
        fp.dismissAlert(key: keyLoading);
      }
    } else {
      // if (showAlertError) {
      //   if (responseStatusCode != 404) {
      //     fp.showAlert(
      //       key: keyError,
      //       content: AlertGeneric(
      //         content: ErrorGeneric(
      //           keyToClose: keyError,
      //           message: generalResponse.message,
      //           messageButton: messageButton,
      //           onPress: onPress,
      //         ),
      //       ),
      //     );
      //   } else {
      //     // final keyNotification = GlobalHelper.genKey();
      //     // fp.addNotification(
      //     //   seconds: 2,
      //     //   key: keyNotification,
      //     //   content: NotificationGeneric(
      //     //     keyToClose: keyNotification,
      //     //     isWarning: true,
      //     //     message: generalResponse.message,
      //     //   )
      //     // );
      //   }
      // }
    }
    return generalResponse;
  }

  HttpClient getHttpClient() {
    bool trustSelfSigned = true;
    HttpClient httpClient = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10)
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => trustSelfSigned);

    return httpClient;
  }

  Future<String> readResponseAsString(HttpClientResponse response) {
    var completer = Completer<String>();
    var contents = StringBuffer();
    response.transform(utf8.decoder).listen((String data) {
      contents.write(data);
    }, onDone: () => completer.complete(contents.toString()));
    return completer.future;
  }
}
