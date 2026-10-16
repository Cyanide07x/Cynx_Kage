
import 'package:flutter/material.dart';
import '../theme/appcolors.dart';
import 'product_details.dart';
import 'dart:math' as math;

class ProductPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage>
    with SingleTickerProviderStateMixin {
  int _currentPage = 0;
  late final AnimationController _borderController;
  late final PageController _pageController;
  late List<String> _images;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

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

    _images = _images.toSet().toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _borderController.dispose();
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

              // Product image with rotating gradient border
              AnimatedBuilder(
                animation: _borderController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _ProductBorderPainter(
                      progress: _borderController.value,
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 250,
                      margin: const EdgeInsets.all(1.2),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: AppColors.appBackground,
                        borderRadius: BorderRadius.circular(10.8),
                      ),
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
                  );
                },
              ),

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

              const SizedBox(height: 24),

              ProductDetails(
                product: widget.product,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Rotating gradient border painter
class _ProductBorderPainter extends CustomPainter {
  final double progress;

  _ProductBorderPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 2.5;

    final rect = Offset.zero & size;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = SweepGradient(
        colors: const [
          Color(0xFFC5E37A),
          Color(0xFF5E8E6E),
          Color(0xFF1E3A2F),
          Color(0xFF5E8E6E),
          Color(0xFFC5E37A),
        ],
        transform: GradientRotation(progress * 2 * math.pi),
      ).createShader(rect);

    final borderRect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      const Radius.circular(12),
    );

    canvas.drawRRect(borderRect, paint);
  }

  @override
  bool shouldRepaint(covariant _ProductBorderPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
