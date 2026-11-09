import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../models/coupon_model.dart';
import 'auth_service.dart';

class CouponService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _headers({bool requireAuth = true}) async {
    final token = await _authService.getAccessToken();

    if (requireAuth && (token == null || token.isEmpty)) {
      throw StateError('Please sign in to apply a coupon.');
    }

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  dynamic _decodeResponse(http.Response response) {
    try {
      return jsonDecode(response.body);
    } catch (_) {
      throw Exception('Invalid response received from server.');
    }
  }

  void _checkResponse(http.Response response) {
    final data = _decodeResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    if (response.statusCode == 401) {
      throw StateError('Your session has expired. Please sign in again.');
    }

    final message = data is Map ? data['detail']?.toString() : null;
    throw Exception(
      message ?? 'Coupon request failed with status: ${response.statusCode}',
    );
  }

  /// Fetch all active and available coupons from FastAPI.
  Future<List<CouponModel>> fetchCoupons() async {
    final headers = await _headers(requireAuth: false);

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/coupons/'),
      headers: headers,
    );

    _checkResponse(response);
    final data = _decodeResponse(response);

    if (data is! Map || data['coupons'] is! List) {
      return [];
    }

    final list = data['coupons'] as List;
    return list
        .map((it) => CouponModel.fromJson(Map<String, dynamic>.from(it as Map)))
        .toList();
  }

  /// Validate a coupon code against current subtotal.
  Future<Map<String, dynamic>> validateCoupon({
    required String code,
    required double subtotal,
  }) async {
    final normalizedCode = code.trim().toUpperCase();
    if (normalizedCode.isEmpty) {
      throw Exception('Please enter a valid coupon code.');
    }

    final headers = await _headers(requireAuth: true);

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/coupons/validate/'),
      headers: headers,
      body: jsonEncode({
        'code': normalizedCode,
        'subtotal': subtotal,
      }),
    );

    _checkResponse(response);
    final data = _decodeResponse(response);

    return Map<String, dynamic>.from(data as Map);
  }
}
