import '../models/user_model.dart';
import 'api_service.dart';

class AuthApiService {
  final ApiService _apiService;

  AuthApiService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // Login
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
    int expiresInMins = 30,
  }) async {
    final response = await _apiService.post(
      'https://dummyjson.com/auth/login',
      data: {
        'username': username,
        'password': password,
        'expiresInMins': expiresInMins,
      },
    );

    return {
      'user': UserModel.fromJson(response.data),
      'token': response.data['accessToken'] ?? response.data['token'],
      'refreshToken': response.data['refreshToken'],
    };
  }

  // Refresh token
  Future<Map<String, dynamic>> refreshToken({
    required String refreshToken,
    int expiresInMins = 30,
  }) async {
    final response = await _apiService.post(
      'https://dummyjson.com/auth/refresh',
      data: {
        'refreshToken': refreshToken,
        'expiresInMins': expiresInMins,
      },
    );

    return {
      'token': response.data['accessToken'] ?? response.data['token'],
      'refreshToken': response.data['refreshToken'],
    };
  }
}

