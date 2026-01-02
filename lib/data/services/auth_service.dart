import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _tokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  // ValueNotifier để notify khi có thay đổi
  final ValueNotifier<UserModel?> userNotifier = ValueNotifier<UserModel?>(null);
  final ValueNotifier<String?> tokenNotifier = ValueNotifier<String?>(null);

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _init();
  }

  // Initialize và load auth data
  Future<void> _init() async {
    final token = await getToken();
    final user = await getUser();
    tokenNotifier.value = token;
    userNotifier.value = user;
  }

  // Check if user is logged in
  bool get isLoggedIn {
    return userNotifier.value != null && tokenNotifier.value != null;
  }

  // Get current token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      return null;
    }
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_refreshTokenKey);
    } catch (e) {
      return null;
    }
  }

  // Get current user
  Future<UserModel?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userJson = prefs.getString(_userKey);
      if (userJson == null || userJson.isEmpty) {
        return null;
      }
      final Map<String, dynamic> decoded = json.decode(userJson);
      return UserModel.fromJson(decoded);
    } catch (e) {
      return null;
    }
  }

  // Save auth data
  Future<bool> saveAuthData({
    required String token,
    String? refreshToken,
    required UserModel user,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      if (refreshToken != null) {
        await prefs.setString(_refreshTokenKey, refreshToken);
      }
      final String userJson = json.encode(user.toJson());
      await prefs.setString(_userKey, userJson);

      // Update notifiers
      tokenNotifier.value = token;
      userNotifier.value = user;

      return true;
    } catch (e) {
      return false;
    }
  }

  // Update token
  Future<bool> updateToken(String token, {String? refreshToken}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      if (refreshToken != null) {
        await prefs.setString(_refreshTokenKey, refreshToken);
      }
      tokenNotifier.value = token;
      return true;
    } catch (e) {
      return false;
    }
  }

  // Logout
  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_userKey);

      // Update notifiers
      tokenNotifier.value = null;
      userNotifier.value = null;

      return true;
    } catch (e) {
      return false;
    }
  }
}

