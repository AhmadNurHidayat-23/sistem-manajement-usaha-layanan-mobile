import '../core/constants/api_endpoints.dart';
import '../core/utils/session_manager.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  static Future<ApiResponse<UserModel>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post(
      ApiEndpoints.login,
      body: {
        'email': email.trim(),
        'password': password,
        'device_name': 'SIMAUL Mobile App',
      },
    );

    if (response.success && response.data != null) {
      try {
        final data = response.data as Map<String, dynamic>;
        final token = data['token'] as String;
        final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

        await SessionManager.saveAuth(token: token, user: user);

        return ApiResponse(
          success: true,
          message: response.message,
          data: user,
          statusCode: response.statusCode,
        );
      } catch (e) {
        return ApiResponse(
          success: false,
          message: 'Format data respon tidak valid.',
          statusCode: response.statusCode,
        );
      }
    }

    return ApiResponse(
      success: false,
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  static Future<ApiResponse<UserModel>> fetchCurrentUser() async {
    final response = await ApiService.get(ApiEndpoints.me);

    if (response.success && response.data != null) {
      try {
        final user = UserModel.fromJson(response.data as Map<String, dynamic>);
        final token = SessionManager.getToken() ?? '';
        await SessionManager.saveAuth(token: token, user: user);

        return ApiResponse(
          success: true,
          message: 'Berhasil',
          data: user,
          statusCode: response.statusCode,
        );
      } catch (_) {}
    }

    return ApiResponse(
      success: false,
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  static Future<void> logout() async {
    try {
      await ApiService.post(ApiEndpoints.logout);
    } catch (_) {}
    await SessionManager.clearAuth();
  }
}
