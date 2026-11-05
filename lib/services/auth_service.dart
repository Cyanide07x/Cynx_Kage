import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';

class AuthService {
  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  /// Helper to extract human-readable error messages from FastAPI responses.
  String _extractErrorMessage(dynamic data, String fallback) {
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail;
      }
      if (detail is List && detail.isNotEmpty) {
        final firstItem = detail.first;
        if (firstItem is Map && firstItem['msg'] != null) {
          return firstItem['msg'].toString();
        }
        return detail.first.toString();
      }
      if (data['message'] is String && (data['message'] as String).trim().isNotEmpty) {
        return data['message'];
      }
    }
    return fallback;
  }

  /// Login using FastAPI.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      );

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = null;
      }

      if (response.statusCode == 200 && data != null) {
        return await _saveTokens(data);
      }

      throw Exception(
        _extractErrorMessage(data, 'Unable to log in. Please check your credentials.'),
      );
    } on SocketException {
      throw Exception('Unable to reach the server. Please ensure the backend is running.');
    } on http.ClientException {
      throw Exception('Unable to connect to the server.');
    } on FormatException {
      throw Exception('Invalid response received from the server.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Login failed: $e');
    }
  }

  /// Register a new user using FastAPI.
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'full_name': fullName.trim(),
          'email': email.trim(),
          'password': password,
          if (phone != null && phone.trim().isNotEmpty)
            'phone': phone.trim(),
        }),
      );

      dynamic data;
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = null;
      }

      if ((response.statusCode == 200 || response.statusCode == 201) && data != null) {
        return await _saveTokens(data);
      }

      throw Exception(
        _extractErrorMessage(data, 'Unable to create your account.'),
      );
    } on SocketException {
      throw Exception('Unable to reach the server. Please ensure the backend is running.');
    } on http.ClientException {
      throw Exception('Unable to connect to the server.');
    } on FormatException {
      throw Exception('Invalid response received from the server.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Registration failed: $e');
    }
  }

  /// Save access and refresh tokens securely.
  Future<Map<String, dynamic>> _saveTokens(
    dynamic data,
  ) async {
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid authentication response.');
    }

    final accessToken = data['access_token'];
    final refreshToken = data['refresh_token'];

    if (accessToken == null || refreshToken == null) {
      throw Exception('Authentication tokens were not received.');
    }

    await _storage.write(
      key: _accessTokenKey,
      value: accessToken.toString(),
    );

    await _storage.write(
      key: _refreshTokenKey,
      value: refreshToken.toString(),
    );

    return data;
  }

  /// Retrieve the saved access token.
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Retrieve the saved refresh token.
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Clear locally stored authentication tokens.
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
