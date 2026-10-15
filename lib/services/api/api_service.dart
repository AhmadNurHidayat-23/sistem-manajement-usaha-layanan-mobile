import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/utils/session_manager.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.statusCode,
  });
}

class ApiService {
  static const Duration _timeoutDuration = Duration(seconds: 15);

  static Map<String, String> _buildHeaders() {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    final token = SessionManager.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  static Future<ApiResponse<dynamic>> get(String url) async {
    try {
      final response = await http
          .get(Uri.parse(url), headers: _buildHeaders())
          .timeout(_timeoutDuration);

      return _handleResponse(response);
    } on SocketException {
      return ApiResponse(
        success: false,
        message: 'Tidak dapat terhubung ke server. Periksa URL server dan koneksi internet Anda.',
        statusCode: 0,
      );
    } on TimeoutException {
      return ApiResponse(
        success: false,
        message: 'Koneksi ke server waktu habis (timeout). Silakan coba lagi.',
        statusCode: 408,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  static Future<ApiResponse<dynamic>> post(String url, {Map<String, dynamic>? body}) async {
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: _buildHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeoutDuration);

      return _handleResponse(response);
    } on SocketException {
      return ApiResponse(
        success: false,
        message: 'Tidak dapat terhubung ke server Laravel. Pastikan server aktif.',
        statusCode: 0,
      );
    } on TimeoutException {
      return ApiResponse(
        success: false,
        message: 'Koneksi ke server waktu habis (timeout).',
        statusCode: 408,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  static Future<ApiResponse<dynamic>> patch(String url, {Map<String, dynamic>? body}) async {
    try {
      final response = await http
          .patch(
            Uri.parse(url),
            headers: _buildHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeoutDuration);

      return _handleResponse(response);
    } on SocketException {
      return ApiResponse(
        success: false,
        message: 'Tidak dapat terhubung ke server Laravel.',
        statusCode: 0,
      );
    } on TimeoutException {
      return ApiResponse(
        success: false,
        message: 'Waktu koneksi habis.',
        statusCode: 408,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
        statusCode: 500,
      );
    }
  }

  static ApiResponse<dynamic> _handleResponse(http.Response response) {
    try {
      final dynamic decoded = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded is Map<String, dynamic>) {
          return ApiResponse(
            success: decoded['success'] == true,
            message: decoded['message']?.toString() ?? 'Berhasil',
            data: decoded['data'],
            statusCode: response.statusCode,
          );
        }
        return ApiResponse(
          success: true,
          message: 'Berhasil',
          data: decoded,
          statusCode: response.statusCode,
        );
      }

      // Handle 401 Unauthorized
      if (response.statusCode == 401) {
        SessionManager.clearAuth();
      }

      String message = 'Terjadi kesalahan';
      if (decoded is Map<String, dynamic>) {
        message = decoded['message']?.toString() ?? message;
      }

      return ApiResponse(
        success: false,
        message: message,
        data: decoded is Map<String, dynamic> ? decoded['data'] : null,
        statusCode: response.statusCode,
      );
    } catch (_) {
      return ApiResponse(
        success: false,
        message: 'Gagal memproses respon server (${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }
  }
}
