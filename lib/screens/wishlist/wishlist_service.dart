import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import '../../services/auth_service.dart';
import 'wishlist_item.dart';

class WishlistService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getAccessToken();

    if (token == null || token.isEmpty) {
      throw StateError('Please sign in to use your wishlist.');
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

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return;
    }

    if (response.statusCode == 401) {
      throw StateError(
        'Your session has expired. Please sign in again.',
      );
    }

    final message = data is Map
        ? data['detail']?.toString()
        : null;

    throw Exception(
      message ?? 'Wishlist request failed: ${response.statusCode}',
    );
  }

  // Fetch wishlist from FastAPI.
  Future<List<WishlistItem>> fetchWishlist() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/wishlist/'),
      headers: await _headers(),
    );

    final data = _decodeResponse(response);
    _checkResponse(response);

    if (data is! Map || data['items'] is! List) {
      throw Exception('Invalid wishlist response.');
    }

    return (data['items'] as List).map((item) {
      final product = Map<String, dynamic>.from(item);

      return WishlistItem.fromMap(
        product['product_id'].toString(),
        {
          'name': product['product_name'],
          'price': product['price'],
          'description': product['description'],
          'imageUrl': product['image_url'],
        },
      );
    }).toList();
  }

  // Add a product to wishlist.
  Future<void> addItem(String productId) async {
    final parsedId = int.tryParse(productId);
    if (parsedId == null) {
      throw ArgumentError('Invalid product ID: $productId');
    }

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/wishlist/'),
      headers: await _headers(),
      body: jsonEncode({
        'product_id': parsedId,
      }),
    );

    _checkResponse(response);
  }

  // Remove a product from wishlist.
  Future<void> removeItem(String productId) async {
    final response = await http.delete(
      Uri.parse(
        '${ApiConfig.baseUrl}/wishlist/$productId',
      ),
      headers: await _headers(),
    );

    _checkResponse(response);
  }
}
