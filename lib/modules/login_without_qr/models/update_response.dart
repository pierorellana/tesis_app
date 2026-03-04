import 'dart:convert';

UpdatePlateResponse updatePlateResponseFromJson(String str) => UpdatePlateResponse.fromJson(json.decode(str));

String updatePlateResponseToJson(UpdatePlateResponse data) => json.encode(data.toJson());

class UpdatePlateResponse {
    int accesoPk;
    String placaDetectada;
    DateTime fechaActualizado;
    String usuarioActualizado;

    UpdatePlateResponse({
        required this.accesoPk,
        required this.placaDetectada,
        required this.fechaActualizado,
        required this.usuarioActualizado,
    });

    factory UpdatePlateResponse.fromJson(Map<String, dynamic> json) => UpdatePlateResponse(
        accesoPk: json["accesoPk"],
        placaDetectada: json["placaDetectada"],
        fechaActualizado: DateTime.parse(json["fechaActualizado"]),
        usuarioActualizado: json["usuarioActualizado"],
    );

    Map<String, dynamic> toJson() => {
        "accesoPk": accesoPk,
        "placaDetectada": placaDetectada,
        "fechaActualizado": fechaActualizado.toIso8601String(),
        "usuarioActualizado": usuarioActualizado,
    };
}
