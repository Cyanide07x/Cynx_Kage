// ─────────────────────────────────────────────────────────────────────────────
// screens/cart/cart_item.dart
// Data model for a single item in the shopping cart.
// ─────────────────────────────────────────────────────────────────────────────

/// Represents one product line in the shopping cart.
class CartItem {
  /// Unique database primary key from `cart_items` in MySQL.
  final int? cartItemId;

  /// Unique variant identifier from `product_variants` in MySQL.
  final int? variantId;

  /// Product identifier (integer ID or slug as string).
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
    this.cartItemId,
    this.variantId,
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

  // ── Serialization ──────────────────────────────────────────────────

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final rawPrice = json['price'];
    final priceVal = rawPrice is num
        ? rawPrice.toDouble()
        : double.tryParse(rawPrice?.toString() ?? '') ?? 0.0;

    return CartItem(
      cartItemId: json['cart_item_id'] as int?,
      variantId: json['variant_id'] as int?,
      productId: (json['product_id'] ?? json['productId'] ?? '').toString(),
      name: (json['name'] ?? json['product_name'] ?? 'Product').toString(),
      imageUrl: (json['imageUrl'] ?? json['image_url'] ?? '').toString(),
      price: priceVal,
      size: (json['size'] ?? '').toString(),
      color: (json['color'] ?? 'Default').toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (cartItemId != null) 'cart_item_id': cartItemId,
      if (variantId != null) 'variant_id': variantId,
      'productId': productId,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'size': size,
      'color': color,
      'quantity': quantity,
    };
  }

  // ── Copy helper ─────────────────────────────────────────────────

  /// Returns a new [CartItem] with the specified fields replaced.
  CartItem copyWith({
    int? cartItemId,
    int? variantId,
    String? productId,
    String? name,
    String? imageUrl,
    double? price,
    String? size,
    String? color,
    int? quantity,
  }) {
    return CartItem(
      cartItemId: cartItemId ?? this.cartItemId,
      variantId: variantId ?? this.variantId,
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
