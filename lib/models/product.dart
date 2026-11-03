
class Product {
  final int productId;
  final String productName;
  final String slug;
  final String? description;
  final String? brand;
  final String? status;

  final List<ProductVariant> variants;
  final List<ProductImage> images;

  Product({
    required this.productId,
    required this.productName,
    required this.slug,
    this.description,
    this.brand,  
    this.status,
    required this.variants,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id'],
      productName: json['product_name'],
      slug: json['slug'],
      description: json['description'],
      brand: json['brand'],
      status: json['status'],

      variants: (json['variants'] as List? ?? [])
          .map(
            (variant) => ProductVariant.fromJson(
              Map<String, dynamic>.from(variant),
            ),
          )
          .toList(),

      images: (json['images'] as List? ?? [])
          .map(
            (image) => ProductImage.fromJson(
              Map<String, dynamic>.from(image),
            ),
          )
          .toList(),
    );
  }

  // Automatically select the primary image.
  String? get primaryImageUrl {
    if (images.isEmpty) return null;

    final primaryImages = images.where(
      (image) => image.isPrimary,
    );

    if (primaryImages.isNotEmpty) {
      return primaryImages.first.imageUrl;
    }

    return images.first.imageUrl;
  }
}

class ProductVariant {
  final int variantId;
  final String? size;
  final String? color;
  final double price;
  final double mrp;
  final int stockQuantity;

  ProductVariant({
    required this.variantId,
    this.size,
    this.color,
    required this.price,
    required this.mrp,
    required this.stockQuantity,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      variantId: json['variant_id'],
      size: json['size'],
      color: json['color'],
      price: (json['price'] as num).toDouble(),
      mrp: (json['mrp'] as num).toDouble(),
      stockQuantity: json['stock_quantity'],
    );
  }
}

class ProductImage {
  final int imageId;
  final String imageUrl;
  final String? altText;
  final bool isPrimary;
  final int displayOrder;

  ProductImage({
    required this.imageId,
    required this.imageUrl,
    this.altText,
    required this.isPrimary,
    required this.displayOrder,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      imageId: json['image_id'],
      imageUrl: json['image_url'] ?? '',
      altText: json['alt_text'],
      isPrimary: json['is_primary'] == true ||
          json['is_primary'] == 1,
      displayOrder: json['display_order'] ?? 0,
    );
  }
}
