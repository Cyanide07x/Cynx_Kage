
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/product_service.dart';

import 'product_page.dart';
import 'wishlist_icon.dart';

class NewArrivals extends StatefulWidget {
  const NewArrivals({super.key});

  @override
  State<NewArrivals> createState() => _NewArrivalsState();
}

class _NewArrivalsState extends State<NewArrivals>
    with SingleTickerProviderStateMixin {
  static const int _initialPage = 1000;

  late final PageController _pageController;
  late final AnimationController _newAnimationController;
  late final Future<List<Product>> _productsFuture;

  final ProductService _productService = ProductService();

  Timer? _timer;
  int _currentPage = _initialPage;

  @override
  void initState() {
    super.initState();

    // Fetch only products marked as New Arrivals.
    // Drafts are included for development/testing.
    _productsFuture = _productService.fetchProducts(
      includeDrafts: true,
      isNewArrival: true,
    );

    _pageController = PageController(
      initialPage: _initialPage,
    );

    _newAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    // Automatically move to the next product.
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted || !_pageController.hasClients) return;

      final page = _pageController.page?.round() ?? _currentPage;

      _pageController.animateToPage(
        page + 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _newAnimationController.dispose();
    super.dispose();
  }

  int _productIndex(int page, int count) {
    return ((page % count) + count) % count;
  }

  // Product prices currently live inside product variants.
  double _priceOf(Product product) {
    if (product.variants.isEmpty) return 0.0;

    return product.variants
        .map((variant) => variant.price)
        .reduce((a, b) => a < b ? a : b);
  }

  // Temporary compatibility map for the existing ProductPage.
  // We will migrate ProductPage to FastAPI separately.
  
Map<String, dynamic> _productToMap(Product product) {
  final imageUrl = product.primaryImageUrl ?? '';

  return {
    // Product information
    'id': product.productId.toString(),
    'productId': product.productId.toString(),
    'product_id': product.productId,
    'name': product.productName,
    'product_name': product.productName,
    'slug': product.slug,
    'description': product.description ?? '',
    'brand': product.brand ?? '',
    'status': product.status ?? '',

    // Product pricing
    'price': _priceOf(product),

    // Complete variant information
    'variants': product.variants.map((variant) {
      return {
        'variant_id': variant.variantId,
        'size': variant.size,
        'color': variant.color,
        'price': variant.price,
        'mrp': variant.mrp,
        'stock_quantity': variant.stockQuantity,
        'is_active': true,
      };
    }).toList(),

    // Complete image information
    'images': product.images.map((image) {
      return {
        'image_id': image.imageId,
        'image_url': image.imageUrl,
        'alt_text': image.altText,
        'is_primary': image.isPrimary,
        'display_order': image.displayOrder,
      };
    }).toList(),

    // Existing image compatibility
    'imageUrl': imageUrl,
    'galleryImages': product.images
        .map((image) => image.imageUrl)
        .where((url) => url.isNotEmpty)
        .toList(),
  };
}


  void _openProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ProductPage(
          product: _productToMap(product),
        ),
      ),
    );
  }

  Widget _imagePlaceholder(Color color) {
    return Center(
      child: Icon(
        Icons.image_not_supported,
        color: color,
        size: 48,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'New Arrivals',
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'See all',
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        FutureBuilder<List<Product>>(
          future: _productsFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              debugPrint(
                'New Arrivals API error: ${snapshot.error}',
              );

              return SizedBox(
                height: 325,
                child: Center(
                  child: Text(
                    'Unable to load new arrivals.',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const SizedBox(
                height: 325,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final products = snapshot.data!;

            if (products.isEmpty) {
              return SizedBox(
                height: 325,
                child: Center(
                  child: Text(
                    'No new arrivals yet.',
                    style: TextStyle(
                      color: colors.onSurface,
                    ),
                  ),
                ),
              );
            }

            final safePage = _productIndex(
              _currentPage,
              products.length,
            );

            final currentProduct = products[safePage];

            final String imageUrl = currentProduct.primaryImageUrl ?? '';

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Container(
                    height: 325,
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: PageView.builder(
                            controller: _pageController,

                            // Infinite scrolling.
                            onPageChanged: (index) {
                              if (!mounted) return;

                              setState(() {
                                _currentPage = index;
                              });
                            },

                            itemBuilder: (context, index) {
                              final productIndex = _productIndex(
                                index,
                                products.length,
                              );

                              final product = products[productIndex];

                              final String image = product.primaryImageUrl ?? '';

                              return GestureDetector(
                                onTap: () => _openProduct(product),
                                child: image.isEmpty
                                    ? _imagePlaceholder(
                                        colors.onSurfaceVariant,
                                      )
                                    : CachedNetworkImage(
                                        imageUrl: image,
                                        fit: BoxFit.cover,
                                        alignment: Alignment.topCenter,
                                        memCacheWidth: 800,
                                        placeholder: (context, url) =>
                                            Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: colors.primary,
                                          ),
                                        ),
                                        errorWidget:
                                            (context, url, error) =>
                                                _imagePlaceholder(
                                          colors.onSurfaceVariant,
                                        ),
                                      ),
                              );
                            },
                          ),
                        ),

                        // Animated NEW badge.
                        Positioned(
                          top: 12,
                          left: 12,
                          child: FadeTransition(
                            opacity: _newAnimationController,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '* NEW',
                                style: TextStyle(
                                  color: colors.onPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Wishlist icon for the current product.
                        Positioned(
                          top: 10,
                          right: 10,
                          child: WishlistIcon(
                            productId:
                                currentProduct.productId.toString(),
                            name: currentProduct.productName,
                            price: _priceOf(currentProduct),
                            imageUrl: imageUrl,
                            description:
                                currentProduct.description ?? '',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Carousel page indicators.
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    products.length,
                    (index) => _dot(index == safePage),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _dot(bool active) {
    final colors = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 28 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active
            ? colors.primary
            : colors.outlineVariant,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
