import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import '../../services/auth_service.dart';
import 'cart_item.dart';

class CartService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getAccessToken();

    if (token == null || token.isEmpty) {
      throw StateError('Please sign in to access your cart.');
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
      message ?? 'Cart request failed: ${response.statusCode}',
    );
  }

  /// Load all saved cart items for the signed-in user from FastAPI.
  Future<List<CartItem>> loadCart() async {
    final token = await _authService.getAccessToken();
    if (token == null || token.isEmpty) {
      return [];
    }

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/cart/'),
      headers: await _headers(),
    );

    final data = _decodeResponse(response);
    _checkResponse(response);

    if (data is! Map || data['items'] is! List) {
      throw Exception('Invalid cart response.');
    }

    return (data['items'] as List).map((item) {
      return CartItem.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }

  /// Add an item or increase the quantity of an existing variant.
  /// Returns the server's updated CartItem (with assigned `cartItemId`).
  Future<CartItem> addItem(CartItem item) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/cart/'),
      headers: await _headers(),
      body: jsonEncode({
        if (item.variantId != null) 'variant_id': item.variantId,
        if (int.tryParse(item.productId) != null)
          'product_id': int.tryParse(item.productId),
        'size': item.size,
        'color': item.color,
        'quantity': item.quantity,
      }),
    );

    final data = _decodeResponse(response);
    _checkResponse(response);

    if (data is Map && data['item'] != null) {
      return CartItem.fromJson(Map<String, dynamic>.from(data['item']));
    }

    return item;
  }

  /// Update an item's quantity in FastAPI.
  Future<void> updateQuantity(
    CartItem item,
    int quantity,
  ) async {
    if (quantity < 1) {
      throw ArgumentError('Quantity must be at least 1.');
    }

    if (item.cartItemId == null) {
      // If we don't have a cartItemId yet, reload the cart first
      final freshItems = await loadCart();
      final matched = freshItems.cast<CartItem?>().firstWhere(
            (c) =>
                c != null &&
                (c.variantId != null && c.variantId == item.variantId ||
                    (c.productId == item.productId &&
                        c.size == item.size &&
                        c.color == item.color)),
            orElse: () => null,
          );
      if (matched?.cartItemId == null) {
        throw StateError('Cart item ID not found.');
      }
      return updateQuantity(matched!, quantity);
    }

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/cart/${item.cartItemId}'),
      headers: await _headers(),
      body: jsonEncode({'quantity': quantity}),
    );

    _checkResponse(response);
  }

  /// Remove an item from the cart.
  Future<void> removeItem(CartItem item) async {
    if (item.cartItemId == null) {
      final freshItems = await loadCart();
      final matched = freshItems.cast<CartItem?>().firstWhere(
            (c) =>
                c != null &&
                (c.variantId != null && c.variantId == item.variantId ||
                    (c.productId == item.productId &&
                        c.size == item.size &&
                        c.color == item.color)),
            orElse: () => null,
          );
      if (matched?.cartItemId == null) return;
      return removeItem(matched!);
    }

    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/cart/${item.cartItemId}'),
      headers: await _headers(),
    );

    _checkResponse(response);
  }

  /// Clear the current user's cart.
  Future<void> clearCart() async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/cart/clear'),
      headers: await _headers(),
    );

    _checkResponse(response);
  }
}
