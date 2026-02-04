import 'dart:convert';

PlateResponse plateResponseFromJson(String str) => PlateResponse.fromJson(json.decode(str));

String plateResponseToJson(PlateResponse data) => json.encode(data.toJson());

class PlateResponse {
    String placa;

    PlateResponse({
        required this.placa,
    });

    factory PlateResponse.fromJson(Map<String, dynamic> json) => PlateResponse(
        placa: json["placa"],
    );

    Map<String, dynamic> toJson() => {
        "placa": placa,
    };
}
