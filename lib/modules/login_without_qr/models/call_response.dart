import 'dart:convert';

CallResponse callResponseFromJson(String str) => CallResponse.fromJson(json.decode(str));

String callResponseToJson(CallResponse data) => json.encode(data.toJson());

class CallResponse {
    String callSid;
    String visitId;

    CallResponse({
        required this.callSid,
        required this.visitId,
    });

    factory CallResponse.fromJson(Map<String, dynamic> json) => CallResponse(
        callSid: json["callSid"],
        visitId: json["visitId"],
    );

    Map<String, dynamic> toJson() => {
        "callSid": callSid,
        "visitId": visitId,
    };
}
