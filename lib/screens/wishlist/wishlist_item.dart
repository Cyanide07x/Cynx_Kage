class WishlistItem {
  final String productId;
  final String name;
  final double price;
  final String description;
  final String imageUrl;

  const WishlistItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
  });

  factory WishlistItem.fromMap(
    String productId,
    Map<String, dynamic> data,
  ) {
    final rawPrice = data['price'];

    return WishlistItem(
      productId: productId,
      name: (data['name'] ?? 'Unnamed product').toString(),
      price: rawPrice is num
          ? rawPrice.toDouble()
          : double.tryParse(rawPrice?.toString() ?? '') ?? 0.0,
      description: (data['description'] ?? '').toString(),
      imageUrl: (data['imageUrl'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}