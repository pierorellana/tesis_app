// To parse this JSON data, do
//
//     final createAccessResponse = createAccessResponseFromJson(jsonString);

import 'dart:convert';

CreateAccessResponse createAccessResponseFromJson(String str) => CreateAccessResponse.fromJson(json.decode(str));

String createAccessResponseToJson(CreateAccessResponse data) => json.encode(data.toJson());

class CreateAccessResponse {
    int accesoPk;
    String visitId;
    String estado;
    String resultadoPersistido;
    String motivo;
    String tipo;
    int viviendaPk;
    bool schemaSupportsPendiente;

    CreateAccessResponse({
        required this.accesoPk,
        required this.visitId,
        required this.estado,
        required this.resultadoPersistido,
        required this.motivo,
        required this.tipo,
        required this.viviendaPk,
        required this.schemaSupportsPendiente,
    });

    factory CreateAccessResponse.fromJson(Map<String, dynamic> json) => CreateAccessResponse(
        accesoPk: json["accesoPk"],
        visitId: json["visitId"],
        estado: json["estado"],
        resultadoPersistido: json["resultadoPersistido"],
        motivo: json["motivo"],
        tipo: json["tipo"],
        viviendaPk: json["viviendaPk"],
        schemaSupportsPendiente: json["schemaSupportsPendiente"],
    );

    Map<String, dynamic> toJson() => {
        "accesoPk": accesoPk,
        "visitId": visitId,
        "estado": estado,
        "resultadoPersistido": resultadoPersistido,
        "motivo": motivo,
        "tipo": tipo,
        "viviendaPk": viviendaPk,
        "schemaSupportsPendiente": schemaSupportsPendiente,
    };
}
