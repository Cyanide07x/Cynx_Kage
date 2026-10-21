import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'wishlist_item.dart';
import 'wishlist_service.dart';

class WishlistController extends ChangeNotifier {
  WishlistController._() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
      _handleAuthChange,
    );
  }

  static final WishlistController instance = WishlistController._();

  final WishlistService _service = WishlistService();

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<List<WishlistItem>>? _wishlistSubscription;

  List<WishlistItem> _items = [];
  final Set<String> _busyProductIds = {};

  bool _isLoading = true;
  bool _isSignedIn = false;
  String? _error;

  List<WishlistItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get isSignedIn => _isSignedIn;
  String? get error => _error;

  bool isWishlisted(String productId) {
    return _items.any((item) => item.productId == productId);
  }

  bool isBusy(String productId) {
    return _busyProductIds.contains(productId);
  }

  void _handleAuthChange(User? user) {
    _wishlistSubscription?.cancel();
    _wishlistSubscription = null;

    _isSignedIn = user != null;
    _items = [];
    _error = null;
    _isLoading = user != null;

    notifyListeners();

    if (user == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _wishlistSubscription = _service.watchWishlist().listen(
      (items) {
        _items = items;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (Object error) {
        _error = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> toggleItem(WishlistItem item) async {
    if (FirebaseAuth.instance.currentUser == null) {
      throw StateError('Please sign in to use your wishlist.');
    }

    if (_busyProductIds.contains(item.productId)) {
      return isWishlisted(item.productId);
    }

    _busyProductIds.add(item.productId);
    notifyListeners();

    try {
      return await _service.toggleItem(item);
    } finally {
      _busyProductIds.remove(item.productId);
      notifyListeners();
    }
  }

  Future<void> removeItem(String productId) async {
    if (FirebaseAuth.instance.currentUser == null) {
      throw StateError('Please sign in to use your wishlist.');
    }

    await _service.removeItem(productId);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _wishlistSubscription?.cancel();
    super.dispose();
  }
}