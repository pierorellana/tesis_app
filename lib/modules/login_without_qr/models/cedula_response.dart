import 'dart:convert';

CedulaResponse cedulaResponseFromJson(String str) => CedulaResponse.fromJson(json.decode(str));

String cedulaResponseToJson(CedulaResponse data) => json.encode(data.toJson());

class CedulaResponse {
    String cedula;
    bool esCedula;
    String nombres;
    String fotoBase64;
    String fotoFormato;

    CedulaResponse({
        required this.cedula,
        required this.esCedula,
        required this.nombres,
        required this.fotoBase64,
        required this.fotoFormato,
    });

    factory CedulaResponse.fromJson(Map<String, dynamic> json) => CedulaResponse(
        cedula: json["cedula"],
        esCedula: json["es_cedula"],
        nombres: json["nombres"],
        fotoBase64: json["foto_base64"],
        fotoFormato: json["foto_formato"],
    );

    Map<String, dynamic> toJson() => {
        "cedula": cedula,
        "es_cedula": esCedula,
        "nombres": nombres,
        "foto_base64": fotoBase64,
        "foto_formato": fotoFormato,
    };
}
