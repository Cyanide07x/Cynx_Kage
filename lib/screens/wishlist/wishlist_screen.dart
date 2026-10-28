import 'package:flutter/material.dart';

import '../../theme/appcolors.dart';
import '../../widgets/product_page.dart';
import '../../widgets/trending.dart';
import 'wishlist_controller.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final WishlistController _wishlist = WishlistController.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),

              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.border,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () =>
                          Navigator.of(context).maybePop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.text,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: AnimatedBuilder(
                      animation: _wishlist,
                      builder: (context, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Wishlist',
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_wishlist.items.length} saved pieces',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.border,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {},
                      icon: const Icon(
                        Icons.ios_share,
                        color: AppColors.text,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              Expanded(
                child: AnimatedBuilder(
                  animation: _wishlist,
                  builder: (context, child) {
                    if (!_wishlist.isSignedIn) {
                      return const Center(
                        child: Text(
                          'Please sign in to view your wishlist.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                          ),
                        ),
                      );
                    }

                    if (_wishlist.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (_wishlist.error != null) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Unable to load your wishlist.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () {
                                // The live Firestore subscription will
                                // retry when the stream reconnects.
                              },
                              child: const Text('Please try again'),
                            ),
                          ],
                        ),
                      );
                    }

                    final items = _wishlist.items;

                    if (items.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: 48,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Your wishlist is empty',
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Tap the heart on a product to save it.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.only(
                        top: 10,
                        bottom: 20,
                      ),
                      itemCount: items.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemBuilder: (context, index) {
                        final item = items[index];

                        return TrendingProductCard(
                          productId: item.productId,
                          name: item.name,
                          price: 'Rs. ${item.price.toStringAsFixed(0)}',
                          productPrice: item.price,
                          imageAsset: item.imageUrl,
                          description: item.description,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (context) => ProductPage(
                                  product: {
                                    'id': item.productId,
                                    'productId': item.productId,
                                    'name': item.name,
                                    'price': item.price,
                                    'imageUrl': item.imageUrl,
                                    'description': item.description,
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}