import 'dart:convert';

GeneralResponse generalResponseFromJson(String str) => GeneralResponse.fromJson(json.decode(str));

String generalResponseToJson(GeneralResponse data) => json.encode(data.toJson());

class GeneralResponse<T> {
  GeneralResponse({
    this.data,
    required this.message,
    required this.error,
  });

  T? data;
  String message;
  bool error;


  factory GeneralResponse.fromJson(Map<String, dynamic> json) => GeneralResponse(
          data: json["data"],
          message: (json["message"] ?? json["error"]?["message"] ?? "").toString(),
          error: json["success"] == false || json["error"] != null,
        );

  Map<String, dynamic> toJson() => {
        "data": data,
        "message": message,
      };
}
