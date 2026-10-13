class CartItem {
  final String productId;
  final String name;
  final String imageUrl;
  final double price;
  final String size;
  final String color;

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

  // Total price for this cart item
  double get totalPrice => price * quantity;

  // Increase quantity
  void increaseQuantity() {
    quantity++;
  }

  // Decrease quantity without going below 1
  void decreaseQuantity() {
    if (quantity > 1) {
      quantity--;
    }
  }

  // Create a copy with updated values
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