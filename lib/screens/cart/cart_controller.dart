// ─────────────────────────────────────────────────────────────────────────────
// screens/cart/cart_controller.dart
// Singleton controller that owns the in-memory cart state.
//
// Usage:
//   CartController.instance.addItem(item);
//   CartController.instance.items; // read-only list
// ─────────────────────────────────────────────────────────────────────────────

import 'cart_item.dart';

/// In-memory shopping-cart manager.
///
/// [CartController] uses the singleton pattern - access it via
/// [CartController.instance]. It holds the list of [CartItem]s and provides
/// add, update, and remove operations.
///
/// > **Note:** This is a plain Dart class, not a [ChangeNotifier]. Widgets
/// > that need to react to cart changes must call `setState` themselves after
/// > calling a mutating method (e.g. in [CartScreen]).
class CartController {
  CartController._(); // private constructor - use [instance] instead

  /// The single, globally-shared [CartController] instance.
  static final CartController instance = CartController._();

  // ── State ──────────────────────────────────────────────────────────────

  /// Mutable list of cart items.
  ///
  /// Items are uniquely keyed by (productId + size + color).
  final List<CartItem> items = [];

  // ── Mutations ─────────────────────────────────────────────────────────────

  /// Adds [newItem] to the cart.
  ///
  /// If an item with the same [CartItem.productId], [CartItem.size], and
  /// [CartItem.color] already exists, its quantity is incremented instead of
  /// adding a duplicate entry.
  void addItem(CartItem newItem) {
    final existingIndex = items.indexWhere(
      (item) =>
          item.productId == newItem.productId &&
          item.size == newItem.size &&
          item.color == newItem.color,
    );

    if (existingIndex != -1) {
      // Merge into existing line item.
      items[existingIndex].quantity += newItem.quantity;
    } else {
      items.add(newItem);
    }
  }

  /// Updates the quantity of [item] to [quantity].
  ///
  /// Quantities below 1 are ignored; use [removeItem] to delete a line.
  void updateQuantity(CartItem item, int quantity) {
    if (quantity >= 1) {
      item.quantity = quantity;
    }
  }

  /// Removes [item] from the cart entirely.
  void removeItem(CartItem item) {
    items.remove(item);
  }
}
