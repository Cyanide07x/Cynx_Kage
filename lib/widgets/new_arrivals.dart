
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'product_page.dart';
import 'wishlist_icon.dart';

class NewArrivals extends StatefulWidget {
  const NewArrivals({super.key});

  @override
  State<NewArrivals> createState() => _NewArrivalsState();
}

class _NewArrivalsState extends State<NewArrivals>
    with SingleTickerProviderStateMixin {
  // Start far into the page sequence to allow scrolling in either direction.
  static const int _initialPage = 1000;

  late final PageController _pageController;
  Timer? _timer;

  int _currentPage = _initialPage;

  late AnimationController _newAnimationController;

  final Stream<QuerySnapshot<Map<String, dynamic>>> _productsStream =
      FirebaseFirestore.instance
          .collection('catalogProducts')
          .where('isActive', isEqualTo: true)
          .snapshots();

  @override
  void initState() {
    super.initState();

    _pageController = PageController(
      initialPage: _initialPage,
    );

    _newAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    // Automatically advance forever.
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

  void _openProduct(Map<String, dynamic> product) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ProductPage(product: product),
      ),
    );
  }

  double _priceOf(Map<String, dynamic> product) {
    final value = product['price'];

    if (value is num) return value.toDouble();

    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  // Handles both forward and backward page positions.
  int _productIndex(int page, int productCount) {
    return ((page % productCount) + productCount) % productCount;
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

        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _productsStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              debugPrint('Firestore error: ${snapshot.error}');

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

            final products = snapshot.data!.docs.where((doc) {
              return doc.data()['isNewArrival'] == true;
            }).toList()
              ..sort((a, b) {
                final aOrder = a.data()['sortOrder'] as num? ?? 0;
                final bOrder = b.data()['sortOrder'] as num? ?? 0;

                return aOrder.compareTo(bOrder);
              });

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

            final currentDocument = products[safePage];

            final currentProduct = <String, dynamic>{
              ...currentDocument.data(),
              // Always pass the actual Firestore document ID.
              'id': currentDocument.id,
            };

            final imageUrl =
                (currentProduct['imageUrl'] ?? '').toString();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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

                            // No itemCount: keep scrolling indefinitely.
                            onPageChanged: (index) {
                              if (!mounted) return;

                              setState(() {
                                _currentPage = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              // Reuse the product list in both directions.
                              final productIndex = _productIndex(
                                index,
                                products.length,
                              );

                              final document = products[productIndex];

                              final product = <String, dynamic>{
                                ...document.data(),
                                'id': document.id,
                              };

                              final image =
                                  (product['imageUrl'] ?? '').toString();

                              if (image.isEmpty) {
                                return Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: colors.onSurfaceVariant,
                                    size: 48,
                                  ),
                                );
                              }

                              return GestureDetector(
                                onTap: () => _openProduct(product),
                                child: Image.network(
                                  image,
                                  fit: BoxFit.cover,
                                  gaplessPlayback: true,
                                  errorBuilder:
                                      (context, error, stackTrace) {
                                    return Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        color: colors.onSurfaceVariant,
                                        size: 48,
                                      ),
                                    );
                                  },
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

                        // Persistent wishlist heart for the current product.
                        Positioned(
                          top: 10,
                          right: 10,
                          child: WishlistIcon(
                            productId: currentDocument.id,
                            name: (currentProduct['name'] ?? 'Product')
                                .toString(),
                            price: _priceOf(currentProduct),
                            imageUrl: imageUrl,
                            description:
                                (currentProduct['description'] ?? '')
                                    .toString(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Indicator follows the currently displayed product.
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
        color: active ? colors.primary : colors.outlineVariant,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
