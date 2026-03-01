import 'dart:convert';

AccessVisitResponse accessVisitResponseFromJson(String str) => AccessVisitResponse.fromJson(json.decode(str));

String accessVisitResponseToJson(AccessVisitResponse data) => json.encode(data.toJson());

class AccessVisitResponse {
    int accesoPk;
    String estado;
    bool finalizado;
    bool puedeContinuar;
    String resultadoPersistido;
    String motivo;
    dynamic digit;
    dynamic callSid;
    dynamic fechaActualizado;
    dynamic usuarioActualizado;

    AccessVisitResponse({
        required this.accesoPk,
        required this.estado,
        required this.finalizado,
        required this.puedeContinuar,
        required this.resultadoPersistido,
        required this.motivo,
        required this.digit,
        required this.callSid,
        required this.fechaActualizado,
        required this.usuarioActualizado,
    });

    factory AccessVisitResponse.fromJson(Map<String, dynamic> json) => AccessVisitResponse(
        accesoPk: json["accesoPk"],
        estado: json["estado"],
        finalizado: json["finalizado"],
        puedeContinuar: json["puedeContinuar"],
        resultadoPersistido: json["resultadoPersistido"],
        motivo: json["motivo"],
        digit: json["digit"],
        callSid: json["callSid"],
        fechaActualizado: json["fechaActualizado"],
        usuarioActualizado: json["usuarioActualizado"],
    );

    Map<String, dynamic> toJson() => {
        "accesoPk": accesoPk,
        "estado": estado,
        "finalizado": finalizado,
        "puedeContinuar": puedeContinuar,
        "resultadoPersistido": resultadoPersistido,
        "motivo": motivo,
        "digit": digit,
        "callSid": callSid,
        "fechaActualizado": fechaActualizado,
        "usuarioActualizado": usuarioActualizado,
    };
}
