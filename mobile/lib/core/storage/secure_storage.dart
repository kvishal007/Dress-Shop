import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const String _keyToken = 'jwt_auth_token';
  static const String _keyUser = 'cached_user_profile';

  static Future<void> saveToken(String token) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyToken, token);
    } else {
      await _storage.write(key: _keyToken, value: token);
    }
  }

  static Future<String?> getToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyToken);
    } else {
      return await _storage.read(key: _keyToken);
    }
  }

  static Future<void> deleteToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyToken);
    } else {
      await _storage.delete(key: _keyToken);
    }
  }

  static Future<void> saveUserData(String jsonString) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUser, jsonString);
    } else {
      await _storage.write(key: _keyUser, value: jsonString);
    }
  }

  static Future<String?> getUserData() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUser);
    } else {
      return await _storage.read(key: _keyUser);
    }
  }

  static Future<void> clearAll() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } else {
      await _storage.deleteAll();
    }
  }
}
