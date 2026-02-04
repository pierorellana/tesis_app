import 'dart:convert';

List<CatalogueResponse> catalogueResponseFromJson(String str) => List<CatalogueResponse>.from(json.decode(str).map((x) => CatalogueResponse.fromJson(x)));

String catalogueResponseToJson(List<CatalogueResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CatalogueResponse {
    String manzana;
    List<String> villas;

    CatalogueResponse({
        required this.manzana,
        required this.villas,
    });

    factory CatalogueResponse.fromJson(Map<String, dynamic> json) => CatalogueResponse(
        manzana: json["manzana"],
        villas: List<String>.from(json["villas"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "manzana": manzana,
        "villas": List<dynamic>.from(villas.map((x) => x)),
    };
}
