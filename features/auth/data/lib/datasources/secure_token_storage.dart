import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenStorage {
  static const String _tokenKey = 'auth_token';
  final FlutterSecureStorage _storage;
  final StreamController<void> _cleared = StreamController<void>.broadcast();

  SecureTokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  /// Emits every time the stored token is removed (logout or failed refresh).
  Stream<void> get onCleared => _cleared.stream;

  Future<void> saveToken(Map<String, dynamic> tokenJson) async {
    final encoded = jsonEncode(tokenJson);
    await _storage.write(key: _tokenKey, value: encoded);
  }

  Future<Map<String, dynamic>?> getToken() async {
    final encoded = await _storage.read(key: _tokenKey);
    if (encoded == null) return null;
    return jsonDecode(encoded) as Map<String, dynamic>;
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
    _cleared.add(null);
  }
}
