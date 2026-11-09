import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../services/auth_service.dart';
import 'wishlist_item.dart';
import 'wishlist_service.dart';

class WishlistController extends ChangeNotifier {
  WishlistController._() {
    unawaited(initialize());
  }

  static final WishlistController instance = WishlistController._();

  final WishlistService _service = WishlistService();
  final AuthService _authService = AuthService();

  List<WishlistItem> _items = [];
  final Set<String> _busyProductIds = {};

  bool _isLoading = true;
  bool _isSignedIn = false;
  bool _isInitialized = false;
  String? _error;

  Future<void>? _initialization;

  List<WishlistItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get isSignedIn => _isSignedIn;
  bool get isInitialized => _isInitialized;
  String? get error => _error;

  bool isWishlisted(String productId) {
    return _items.any((item) => item.productId == productId);
  }

  bool isBusy(String productId) {
    return _busyProductIds.contains(productId);
  }

  // Checks the saved access token and loads the wishlist.
  Future<void> initialize() {
    return _initialization ??= _initialize().whenComplete(() {
      _initialization = null;
    });
  }

  Future<void> _initialize() async {
    try {
      final token = await _authService.getAccessToken();

      _isSignedIn = token != null && token.isNotEmpty;
      _isInitialized = true;
      _error = null;

      if (!_isSignedIn) {
        _items = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      await refreshWishlist();
    } catch (error) {
      _error = error.toString();
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Fetches the latest wishlist from FastAPI.
  Future<void> refreshWishlist() async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _service.fetchWishlist();
      _error = null;
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Resets state when user logs out.
  void clear() {
    _items = [];
    _isSignedIn = false;
    _isInitialized = false;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // Adds an item if it is not saved; otherwise removes it.
  Future<bool> toggleItem(WishlistItem item) async {
    await initialize();

    if (!_isSignedIn) {
      throw StateError('Please sign in to use your wishlist.');
    }

    final productId = item.productId;

    if (_busyProductIds.contains(productId)) {
      return isWishlisted(productId);
    }

    _busyProductIds.add(productId);
    notifyListeners();

    try {
      if (isWishlisted(productId)) {
        await _service.removeItem(productId);
        _items.removeWhere((savedItem) => savedItem.productId == productId);
        return false;
      } else {
        await _service.addItem(productId);
        await refreshWishlist();
        return true;
      }
    } finally {
      _busyProductIds.remove(productId);
      notifyListeners();
    }
  }

  // Removes an item from the wishlist.
  Future<void> removeItem(String productId) async {
    await initialize();

    if (!_isSignedIn) {
      throw StateError('Please sign in to use your wishlist.');
    }

    if (_busyProductIds.contains(productId)) return;

    _busyProductIds.add(productId);
    notifyListeners();

    try {
      await _service.removeItem(productId);
      _items.removeWhere((item) => item.productId == productId);
      _error = null;
    } catch (error) {
      _error = error.toString();
      rethrow;
    } finally {
      _busyProductIds.remove(productId);
      notifyListeners();
    }
  }
}
