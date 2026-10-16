import 'package:flutter/material.dart';
import '../theme/appcolors.dart';

class ProductPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  int _currentPage = 0;

  late final PageController _pageController;
  late List<String> _images;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    final imageUrl = widget.product['imageUrl'];
    final galleryImages = widget.product['galleryImages'];

    _images = [];

    if (imageUrl is String && imageUrl.isNotEmpty) {
      _images.add(imageUrl);
    }

    if (galleryImages is List) {
      for (final image in galleryImages) {
        if (image is String && image.isNotEmpty) {
          _images.add(image);
        }
      }
    }

    // Remove duplicate image URLs.
    _images = _images.toSet().toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 5, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),

              // Back and Add to Cart buttons
              Row(
                children: [
                  // Back button
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
                      onPressed: () {
                        Navigator.of(context).maybePop();
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.text,
                        size: 20,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Add to Cart button
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
                      onPressed: () {
                        // Add to cart logic later.
                      },
                      icon: const Icon(
                        Icons.shopping_cart,
                        color: AppColors.text,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // Product image carousel
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: _images.isEmpty
                      ? const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: AppColors.error,
                            size: 40,
                          ),
                        )
                      : PageView.builder(
                          controller: _pageController,
                          itemCount: _images.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Image.network(
                              _images[index],
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (
                                context,
                                error,
                                stackTrace,
                              ) {
                                return const Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    color: AppColors.error,
                                    size: 40,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ),

              // Space between image and dots
              const SizedBox(height: 12),

              // Image page indicators
              if (_images.length > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_images.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppColors.text
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  }),
                ),
            ],
          ),
        ),
      ),
    );
  }
}