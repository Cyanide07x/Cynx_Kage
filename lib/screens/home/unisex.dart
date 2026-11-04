
import 'package:flutter/material.dart';

import '../../theme/appcolors.dart';
import '../../widgets/trending.dart';
import '../../widgets/product_page.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';

class UnisexScreen extends StatefulWidget {
  const UnisexScreen({super.key});

  @override
  State<UnisexScreen> createState() => _MenScreenState();
}

class _MenScreenState extends State<UnisexScreen> {
  final ProductService _productService = ProductService();

  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();

    _productsFuture = _productService.fetchProducts(
      includeDrafts: true,
      collection: 'unisex',
    );
  }

  // Get the lowest available variant price.
  double _getProductPrice(Product product) {
    if (product.variants.isEmpty) return 0.0;

    final prices = product.variants
        .map((variant) => variant.price)
        .toList();

    prices.sort();

    return prices.first.toDouble();
  }

  // Convert API product data into the legacy ProductPage map.
  Map<String, dynamic> _productToMap(Product product) {
    final price = _getProductPrice(product);

    return {
      'id': product.productId.toString(),
      'name': product.productName,
      'price': price,
      'imageUrl': product.primaryImageUrl ?? '',
      'description': product.description ?? '',
      'brand': product.brand ?? '',
      'slug': product.slug,
      'images': product.images.map((image) {
        return {
          'imageUrl': image.imageUrl,
          'altText': image.altText,
          'isPrimary': image.isPrimary,
        };
      }).toList(),
      'variants': product.variants.map((variant) {
        return {
          'variantId': variant.variantId,
          'size': variant.size,
          'color': variant.color,
          'price': variant.price,
          'mrp': variant.mrp,
          'stockQuantity': variant.stockQuantity,
        };
      }).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 0, bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section heading
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "unisex's Collection",
              style: TextStyle(
                color: AppColors.text,
                fontSize: 26,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 8),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Explore the latest styles for unisex.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(height: 22),

          // Product grid
          FutureBuilder<List<Product>>(
            future: _productsFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Something went wrong while loading products.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final products = snapshot.data ?? [];

              if (products.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No products available in this collection.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final product = products[index];

                  final price = _getProductPrice(product);
                  final fullProduct = _productToMap(product);

                  return TrendingProductCard(
                    productId: product.productId.toString(),
                    name: product.productName,
                    price: 'Rs. ${price.toStringAsFixed(0)}',
                    productPrice: price,
                    imageAsset: product.primaryImageUrl ?? '',
                    description: product.description ?? '',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              ProductPage(product: fullProduct),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
