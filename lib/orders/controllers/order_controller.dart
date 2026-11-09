import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../services/auth_service.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderController extends ChangeNotifier {
  OrderController._() {
    unawaited(initialize());
  }

  static final OrderController instance = OrderController._();

  final OrderService _service = OrderService();
  final AuthService _authService = AuthService();

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  bool _isSignedIn = false;
  String? _error;

  Future<void>? _initialization;

  List<OrderModel> get orders => List.unmodifiable(_orders);
  int get orderCount => _orders.length;
  bool get isLoading => _isLoading;
  bool get isSignedIn => _isSignedIn;
  String? get error => _error;

  /// Check authentication and load orders.
  Future<void> initialize() {
    return _initialization ??= _initialize().whenComplete(() {
      _initialization = null;
    });
  }

  Future<void> _initialize() async {
    try {
      final token = await _authService.getAccessToken();
      _isSignedIn = token != null && token.isNotEmpty;
      _error = null;

      if (!_isSignedIn) {
        _orders = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      await loadOrders();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reload orders from FastAPI backend.
  Future<void> loadOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _authService.getAccessToken();
      if (token == null || token.isEmpty) {
        _orders = [];
        _isSignedIn = false;
      } else {
        _isSignedIn = true;
        _orders = await _service.fetchOrders();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear orders upon sign out.
  void clear() {
    _orders = [];
    _isSignedIn = false;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
