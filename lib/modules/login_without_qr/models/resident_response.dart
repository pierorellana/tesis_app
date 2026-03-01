import 'dart:convert';

ResidentResponse residentResponseFromJson(String str) => ResidentResponse.fromJson(json.decode(str));

String residentResponseToJson(ResidentResponse data) => json.encode(data.toJson());

class ResidentResponse {
    int viviendaPk;
    String celular;

    ResidentResponse({
        required this.viviendaPk,
        required this.celular,
    });

    factory ResidentResponse.fromJson(Map<String, dynamic> json) => ResidentResponse(
        viviendaPk: json["vivienda_pk"],
        celular: json["celular"],
    );

    Map<String, dynamic> toJson() => {
        "vivienda_pk": viviendaPk,
        "celular": celular,
    };
}
