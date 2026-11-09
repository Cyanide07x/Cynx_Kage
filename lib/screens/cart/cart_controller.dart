import 'package:flutter/foundation.dart';
import 'cart_item.dart';
import 'cart_service.dart';

/// Coordinates in-memory cart state and FastAPI persistence.
class CartController extends ChangeNotifier {
  CartController._();

  static final CartController instance = CartController._();

  final CartService _cartService = CartService();

  /// Current in-memory cart items.
  final List<CartItem> items = [];

  /// Total units across all items in the cart.
  int get totalCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Total cost of items currently in the cart.
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// Loads the signed-in user's cart from FastAPI.
  Future<void> loadCart() async {
    try {
      final savedItems = await _cartService.loadCart();

      items
        ..clear()
        ..addAll(savedItems);
      notifyListeners();
    } catch (e) {
      debugPrint('CartController: Failed to load cart: $e');
    }
  }

  /// Adds an item or increases the quantity of an existing variation.
  Future<void> addItem(CartItem newItem) async {
    // Save to FastAPI first so we get the server-assigned cartItemId
    final savedItem = await _cartService.addItem(newItem);

    final existingIndex = items.indexWhere(
      (item) =>
          (savedItem.cartItemId != null &&
              item.cartItemId == savedItem.cartItemId) ||
          (savedItem.variantId != null &&
              item.variantId == savedItem.variantId) ||
          (item.productId == newItem.productId &&
              item.size == newItem.size &&
              item.color == newItem.color),
    );

    if (existingIndex != -1) {
      items[existingIndex] = savedItem;
    } else {
      items.add(savedItem);
    }
    notifyListeners();
  }

  /// Updates an item's quantity and persists the change.
  Future<void> updateQuantity(
    CartItem item,
    int quantity,
  ) async {
    if (quantity < 1) return;

    await _cartService.updateQuantity(item, quantity);

    final existingItem = items.cast<CartItem?>().firstWhere(
      (current) =>
          current != null &&
          ((item.cartItemId != null &&
                  current.cartItemId == item.cartItemId) ||
              (item.variantId != null &&
                  current.variantId == item.variantId) ||
              (current.productId == item.productId &&
                  current.size == item.size &&
                  current.color == item.color)),
      orElse: () => null,
    );

    if (existingItem != null) {
      existingItem.quantity = quantity;
      notifyListeners();
    }
  }

  /// Removes an item from FastAPI and local state.
  Future<void> removeItem(CartItem item) async {
    await _cartService.removeItem(item);

    items.removeWhere(
      (current) =>
          (item.cartItemId != null && current.cartItemId == item.cartItemId) ||
          (item.variantId != null && current.variantId == item.variantId) ||
          (current.productId == item.productId &&
              current.size == item.size &&
              current.color == item.color),
    );
    notifyListeners();
  }

  /// Clears the user's cart in both FastAPI and memory.
  Future<void> clearCart() async {
    await _cartService.clearCart();
    items.clear();
    notifyListeners();
  }

  /// Resets in-memory cart on logout.
  void clear() {
    items.clear();
    notifyListeners();
  }
}
