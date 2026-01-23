import 'dart:convert';

QrResponse qrResponseFromJson(String str) => QrResponse.fromJson(json.decode(str));

String qrResponseToJson(QrResponse data) => json.encode(data.toJson());

class QrResponse {
    int qrId;

    QrResponse({
        required this.qrId,
    });

    factory QrResponse.fromJson(Map<String, dynamic> json) => QrResponse(
        qrId: json["qr_id"],
    );

    Map<String, dynamic> toJson() => {
        "qr_id": qrId,
    };
}
