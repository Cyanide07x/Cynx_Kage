import 'dart:async';

import 'package:flutter/material.dart';
import '../theme/appcolors.dart';

class NewArrivals extends StatefulWidget {
  const NewArrivals({super.key});

  @override
  State<NewArrivals> createState() => _NewArrivalsState();
}

class _NewArrivalsState extends State<NewArrivals>
    with SingleTickerProviderStateMixin {
  Set<int> wishlistedProducts = {};

  final PageController _pageController = PageController();

  Timer? _timer;

  int _currentPage = 0;

  final List<String> products = [
    'assets/images/new_arrival_1.jpg',
    'assets/images/new_arrival_2.jpg',
    'assets/images/new_arrival_3.jpg',
    'assets/images/new_arrival_4.jpg',
    'assets/images/new_arrival_5.jpg',
  ];

  late AnimationController _newAnimationController;

  @override
  void initState() {
    super.initState();

    _newAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    // Preload all product images
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final image in products) {
        precacheImage(
          AssetImage(image),
          context,
        );
      }
    });

    // Automatic carousel
    _timer = Timer.periodic(
      const Duration(seconds: 2),
      (_) {
        if (!_pageController.hasClients || products.isEmpty) {
          return;
        }

        final nextPage = _currentPage + 1;

        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _newAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Heading
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'New Arrivals',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'See all',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Product card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 325,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.text,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Stack(
              children: [
                // Product image carousel
                Positioned.fill(
                  child: PageView.builder(
                    controller: _pageController,

                    // Extra page = duplicate first image
                    // for seamless looping.
                    itemCount: products.length + 1,

                    onPageChanged: (index) {
                      if (index == products.length) {
                        setState(() {
                          _currentPage = 0;
                        });

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_pageController.hasClients) {
                            _pageController.jumpToPage(0);
                          }
                        });
                      } else {
                        setState(() {
                          _currentPage = index;
                        });
                      }
                    },

                    itemBuilder: (context, index) {
                      return Image.asset(
                        products[index % products.length],
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      );
                    },
                  ),
                ),

                // NEW badge
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
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '* NEW',
                        style: TextStyle(
                          color: AppColors.deepForest,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                // Wishlist button
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        wishlistedProducts.contains(_currentPage)
                            ? Icons.favorite
                            : Icons.favorite_border,
                      ),
                      color: wishlistedProducts.contains(_currentPage)
                          ? Colors.red
                          : AppColors.text,
                      onPressed: () {
                        setState(() {
                          if (wishlistedProducts.contains(_currentPage)) {
                            wishlistedProducts.remove(_currentPage);
                          } else {
                            wishlistedProducts.add(_currentPage);
                          }
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 15),

        // Page indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            products.length,
            (index) => _dot(index == _currentPage),
          ),
        ),
      ],
    );
  }

  Widget _dot(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 28 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}