import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import '../constants/api_endpoints.dart';

class SessionManager {
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'auth_user';
  static const String _keyBaseUrl = 'custom_base_url';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final savedBaseUrl = _prefs.getString(_keyBaseUrl);
    if (savedBaseUrl != null && savedBaseUrl.isNotEmpty) {
      ApiEndpoints.setBaseUrl(savedBaseUrl);
    }
  }

  static Future<void> saveBaseUrl(String url) async {
    await _prefs.setString(_keyBaseUrl, url);
    ApiEndpoints.setBaseUrl(url);
  }

  static String getSavedBaseUrl() {
    return _prefs.getString(_keyBaseUrl) ?? ApiEndpoints.baseUrl;
  }

  static Future<void> saveAuth({
    required String token,
    required UserModel user,
  }) async {
    await _prefs.setString(_keyToken, token);
    await _prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  static String? getToken() {
    return _prefs.getString(_keyToken);
  }

  static bool hasToken() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  static UserModel? getUser() {
    final userJson = _prefs.getString(_keyUser);
    if (userJson == null || userJson.isEmpty) return null;
    try {
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  static String? getRole() {
    return getUser()?.role;
  }

  static Future<void> clearAuth() async {
    await _prefs.remove(_keyToken);
    await _prefs.remove(_keyUser);
  }
}
