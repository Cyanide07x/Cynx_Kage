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

  /// Converts this Product into the complete Map expected by ProductPage
  Map<String, dynamic> toProductPageMap() {
    final imageUrl = primaryImageUrl ?? '';
    final minPrice = variants.isEmpty
        ? 0.0
        : variants.map((v) => v.price).reduce((a, b) => a < b ? a : b);

    return {
      'id': productId.toString(),
      'productId': productId.toString(),
      'product_id': productId,
      'name': productName,
      'product_name': productName,
      'slug': slug,
      'description': description ?? '',
      'brand': brand ?? '',
      'status': status ?? '',
      'price': minPrice,
      'imageUrl': imageUrl,
      'variants': variants.map((variant) {
        return {
          'variant_id': variant.variantId,
          'variantId': variant.variantId,
          'size': variant.size ?? '',
          'color': variant.color ?? '',
          'price': variant.price,
          'mrp': variant.mrp,
          'stock_quantity': variant.stockQuantity,
          'stockQuantity': variant.stockQuantity,
          'is_active': true,
        };
      }).toList(),
      'images': images.map((image) {
        return {
          'image_id': image.imageId,
          'image_url': image.imageUrl,
          'imageUrl': image.imageUrl,
          'alt_text': image.altText,
          'altText': image.altText,
          'is_primary': image.isPrimary,
          'isPrimary': image.isPrimary,
          'display_order': image.displayOrder,
        };
      }).toList(),
      'galleryImages': images
          .map((image) => image.imageUrl)
          .where((url) => url.isNotEmpty)
          .toList(),
    };
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
