import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import '../../services/auth_service.dart';
import '../models/order_model.dart';
import '../../screens/cart/cart_item.dart';
import '../../screens/address/saved_address.dart';

class OrderService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getAccessToken();

    if (token == null || token.isEmpty) {
      throw StateError('Please sign in before placing an order.');
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
      message ?? 'Order request failed with status: ${response.statusCode}',
    );
  }

  /// Create a new order via FastAPI backend.
  Future<String> createOrder({
    required List<CartItem> cartItems,
    required SavedAddress address,
    required double subtotal,
    required double deliveryCharge,
    required double totalAmount,
    required String paymentMethod,
    String? couponCode,
    double discountAmount = 0.0,
  }) async {
    if (cartItems.isEmpty) {
      throw Exception('Your cart is empty.');
    }

    final method = paymentMethod.toUpperCase().trim();
    if (method != 'COD' && method != 'UPI' && method != 'CARD') {
      throw Exception('Please select a valid payment method.');
    }

    final headers = await _headers();

    final payload = {
      'items': cartItems.map((item) {
        return {
          'variant_id': item.variantId,
          'product_id': int.tryParse(item.productId),
          'productId': item.productId,
          'name': item.name,
          'size': item.size,
          'color': item.color,
          'price': item.price,
          'quantity': item.quantity,
          'imageUrl': item.imageUrl,
        };
      }).toList(),
      'address': {
        'address_id': address.addressId,
        'name': address.name,
        'phone': address.phone,
        'address': address.address,
        'city': address.city,
        'state': address.state,
        'pin': address.pin,
      },
      'subtotal': subtotal,
      'deliveryCharge': deliveryCharge,
      'delivery_charge': deliveryCharge,
      'totalAmount': totalAmount,
      'total_amount': totalAmount,
      'paymentMethod': method.toLowerCase(),
      'payment_method': method.toLowerCase(),
      'couponCode': couponCode,
      'coupon_code': couponCode,
      'discountAmount': discountAmount,
      'discount_amount': discountAmount,
    };

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/orders/'),
      headers: headers,
      body: jsonEncode(payload),
    );

    _checkResponse(response);
    final data = _decodeResponse(response);

    // Return the user-facing order number (e.g. CK-20261109-A1B2C3) or order id
    final orderNumber = data['order_number'] ?? data['order_id'];
    return orderNumber.toString();
  }

  /// Fetch all orders placed by the current authenticated user.
  Future<List<OrderModel>> fetchOrders() async {
    final token = await _authService.getAccessToken();
    if (token == null || token.isEmpty) {
      return [];
    }

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/orders/'),
      headers: await _headers(),
    );

    _checkResponse(response);
    final data = _decodeResponse(response);

    if (data is! Map || data['orders'] is! List) {
      return [];
    }

    final ordersJson = data['orders'] as List;
    return ordersJson
        .map((it) => OrderModel.fromJson(Map<String, dynamic>.from(it as Map)))
        .toList();
  }

  /// Fetch details of a single order by ID or order number.
  Future<OrderModel?> fetchOrderById(String orderId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/orders/$orderId'),
      headers: await _headers(),
    );

    _checkResponse(response);
    final data = _decodeResponse(response);

    if (data is! Map || data['order'] == null) {
      return null;
    }

    return OrderModel.fromJson(Map<String, dynamic>.from(data['order'] as Map));
  }
}
