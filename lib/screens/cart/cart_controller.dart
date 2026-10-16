
import 'cart_item.dart';

class CartController {
  CartController._();

  static final CartController instance = CartController._();

  final List<CartItem> items = [];

  void addItem(CartItem newItem) {
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

  void updateQuantity(CartItem item, int quantity) {
    if (quantity >= 1) {
      item.quantity = quantity;
    }
  }

  void removeItem(CartItem item) {
    items.remove(item);
  }
}
