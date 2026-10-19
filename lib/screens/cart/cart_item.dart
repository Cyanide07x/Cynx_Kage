// ─────────────────────────────────────────────────────────────────────────────
// screens/cart/cart_item.dart
// Data model for a single item in the shopping cart.
// ─────────────────────────────────────────────────────────────────────────────

/// Represents one product line in the shopping cart.
///
/// A [CartItem] is uniquely identified by the combination of
/// [productId], [size], and [color]. Two items with the same product but
/// different sizes or colours are treated as separate cart entries.
class CartItem {
  /// Unique product identifier (Firestore document ID, slug, or name).
  final String productId;

  /// Human-readable product name displayed in the cart.
  final String name;

  /// Remote URL of the product's primary image.
  final String imageUrl;

  /// Unit price in the app's base currency (INR).
  final double price;

  /// Selected size string (e.g. "S", "M", "L", "XL").
  final String size;

  /// Selected colour name (e.g. "Black", "Olive").
  final String color;

  /// Number of units of this item in the cart. Must be >= 1.
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.size,
    required this.color,
    this.quantity = 1,
  }) : assert(quantity >= 1, 'Quantity must be at least 1');

  // ── Computed properties ──────────────────────────────────────────────

  /// Returns [price] x [quantity] - the total cost for this line item.
  double get totalPrice => price * quantity;

  // ── Quantity helpers ───────────────────────────────────────────────

  /// Increments [quantity] by 1.
  void increaseQuantity() {
    quantity++;
  }

  /// Decrements [quantity] by 1, but never below 1.
  void decreaseQuantity() {
    if (quantity > 1) {
      quantity--;
    }
  }

  // ── Copy helper ─────────────────────────────────────────────────

  /// Returns a new [CartItem] with the specified fields replaced.
  CartItem copyWith({
    String? productId,
    String? name,
    String? imageUrl,
    double? price,
    String? size,
    String? color,
    int? quantity,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      size: size ?? this.size,
      color: color ?? this.color,
      quantity: quantity ?? this.quantity,
    );
  }
}