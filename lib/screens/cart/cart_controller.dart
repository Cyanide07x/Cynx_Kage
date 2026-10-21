
import 'cart_item.dart';
import 'cart_service.dart';

/// Coordinates in-memory cart state and Firestore persistence.
class CartController {
  CartController._();

  static final CartController instance = CartController._();

  final CartService _cartService = CartService();

  /// Current in-memory cart items.
  final List<CartItem> items = [];

  /// Loads the signed-in user's cart from Firestore.
  Future<void> loadCart() async {
    final savedItems = await _cartService.loadCart();

    items
      ..clear()
      ..addAll(savedItems);
  }

  /// Adds an item or increases the quantity of an existing variation.
  Future<void> addItem(CartItem newItem) async {
    // Save first so failed Firestore writes don't change local state.
    await _cartService.addItem(newItem);

    final existingIndex = items.indexWhere(
      (item) =>
          item.productId == newItem.productId &&
          item.size == newItem.size &&
          item.color == newItem.color,
    );

    if (existingIndex != -1) {
      items[existingIndex].quantity += newItem.quantity;
    } else {
      items.add(newItem);
    }
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
          current.productId == item.productId &&
          current.size == item.size &&
          current.color == item.color,
      orElse: () => null,
    );

    if (existingItem != null) {
      existingItem.quantity = quantity;
    }
  }

  /// Removes an item from Firestore and local state.
  Future<void> removeItem(CartItem item) async {
    await _cartService.removeItem(item);

    items.removeWhere(
      (current) =>
          current.productId == item.productId &&
          current.size == item.size &&
          current.color == item.color,
    );
  }

  /// Clears the signed-in user's cart.
  Future<void> clearCart() async {
    await _cartService.clearCart();
    items.clear();
  }
}
