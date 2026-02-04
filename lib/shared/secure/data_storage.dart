import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tesis_app/modules/login_without_qr/models/catalogue_response.dart';

class CatalogueStorage {
  static AndroidOptions _getAndroidOptions() =>
      const AndroidOptions(encryptedSharedPreferences: true);

  final _storage = FlutterSecureStorage(aOptions: _getAndroidOptions());

  static const _keyCatalogue = 'catalogue_data';

  static List<CatalogueResponse>? _cachedCatalogue;

  Future<void> setCatalogue(List<CatalogueResponse> items) async {
    _cachedCatalogue = items;
    final jsonList = items.map((e) => e.toJson()).toList();
    await _storage.write(key: _keyCatalogue, value: jsonEncode(jsonList));
  }

  Future<List<CatalogueResponse>?> getCatalogue() async {
    if (_cachedCatalogue != null) return _cachedCatalogue;

    final raw = await _storage.read(key: _keyCatalogue);
    if (raw == null) return null;

    final decoded = jsonDecode(raw);
    if (decoded is! List) return null;

    _cachedCatalogue = decoded
        .map((e) => CatalogueResponse.fromJson(e as Map<String, dynamic>))
        .toList();

    return _cachedCatalogue;
  }

  Future<void> preloadCatalogue() async {
    await getCatalogue();
  }

}
