import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../screens/address/saved_address.dart';
import 'auth_service.dart';

class AddressService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getAccessToken();

    if (token == null || token.isEmpty) {
      throw StateError('Please sign in to manage your addresses.');
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
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
      message ?? 'Address request failed: ${response.statusCode}',
    );
  }

  /// Fetch all saved addresses for the current user.
  Future<List<SavedAddress>> fetchAddresses() async {
    final token = await _authService.getAccessToken();
    if (token == null || token.isEmpty) {
      return [];
    }

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/addresses/'),
      headers: await _headers(),
    );

    final data = _decodeResponse(response);
    _checkResponse(response);

    if (data is! Map || data['addresses'] is! List) {
      throw Exception('Invalid addresses response.');
    }

    return (data['addresses'] as List).map((json) {
      return SavedAddress.fromJson(Map<String, dynamic>.from(json));
    }).toList();
  }

  /// Create a new address.
  Future<SavedAddress> addAddress(SavedAddress address) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/addresses/'),
      headers: await _headers(),
      body: jsonEncode(address.toJson()),
    );

    final data = _decodeResponse(response);
    _checkResponse(response);

    if (data is Map && data['address'] != null) {
      return SavedAddress.fromJson(Map<String, dynamic>.from(data['address']));
    }

    return address;
  }

  /// Update an existing address.
  Future<SavedAddress> updateAddress(int addressId, SavedAddress address) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/addresses/$addressId'),
      headers: await _headers(),
      body: jsonEncode(address.toJson()),
    );

    final data = _decodeResponse(response);
    _checkResponse(response);

    if (data is Map && data['address'] != null) {
      return SavedAddress.fromJson(Map<String, dynamic>.from(data['address']));
    }

    return address;
  }

  /// Delete an address.
  Future<void> deleteAddress(int addressId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/addresses/$addressId'),
      headers: await _headers(),
    );

    _checkResponse(response);
  }

  /// Mark an address as the default.
  Future<void> setDefaultAddress(int addressId) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/addresses/$addressId/default'),
      headers: await _headers(),
    );

    _checkResponse(response);
  }
}
