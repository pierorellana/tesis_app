import 'dart:convert';

FaceValidationResponse faceValidationResponseFromJson(String str) => FaceValidationResponse.fromJson(json.decode(str));

String faceValidationResponseToJson(FaceValidationResponse data) => json.encode(data.toJson());

class FaceValidationResponse {
    bool match;
    double distance;

    FaceValidationResponse({
        required this.match,
        required this.distance,
    });

    factory FaceValidationResponse.fromJson(Map<String, dynamic> json) => FaceValidationResponse(
        match: json["match"],
        distance: json["distance"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "match": match,
        "distance": distance,
    };
}
