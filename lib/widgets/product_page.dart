import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../screens/cart/cart_screen.dart';
import '../theme/appcolors.dart';
import '../screens/account/account_action_button.dart';
import 'product_details.dart';

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
  // ============================================================
  // STATE
  // ============================================================

  int _currentPage = 0;

  late final AnimationController _borderController;
  late final PageController _pageController;
  late final List<String> _images;

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      bottomNavigationBar: _buildCartFooter(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 5, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 25),
                _buildHeader(),
                const SizedBox(height: 25),
                _buildProductImage(),
                const SizedBox(height: 12),
                _buildImageIndicators(),
                const SizedBox(height: 24),
                ProductDetails(product: widget.product),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        _buildHeaderButton(
          icon: Icons.arrow_back,
          onTap: () => Navigator.of(context).maybePop(),
        ),
        const Spacer(),
        _buildHeaderButton(
          icon: Icons.shopping_cart,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CartScreen(),
              ),
            );
            // Cart navigation will be added later.
          },
        ),
      ],
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
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
        onPressed: onTap,
        icon: Icon(
          icon,
          color: AppColors.text,
          size: 20,
        ),
      ),
    );
  }

  // ============================================================
  // PRODUCT IMAGE CAROUSEL
  // ============================================================

  Widget _buildProductImage() {
    return AnimatedBuilder(
      animation: _borderController,
      builder: (context, child) {
        return CustomPaint(
          painter: _ProductBorderPainter(
            progress: _borderController.value,
          ),
          child: Container(
            width: double.infinity,
            height: 250,
            margin: const EdgeInsets.all(2.5),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.appBackground,
              borderRadius: BorderRadius.circular(10.8),
            ),
            child: _images.isEmpty
                ? _buildImagePlaceholder()
                : PageView.builder(
                    controller: _pageController,
                    itemCount: _images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _openFullScreenImage(index),
                        child: Image.network(
                          _images[index],
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder();
                          },
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  Widget _buildImagePlaceholder() {
    return const Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.error,
        size: 40,
      ),
    );
  }

  // ============================================================
  // IMAGE PAGE INDICATORS
  // ============================================================

  Widget _buildImageIndicators() {
    if (_images.length <= 1) {
      return const SizedBox.shrink();
    }

    return Row(
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
    );
  }

  // ============================================================
  // FULL-SCREEN IMAGE VIEWER
  // ============================================================

  void _openFullScreenImage(int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, animation, secondaryAnimation) {
          return _FullScreenImageViewer(
            images: _images,
            initialIndex: initialIndex,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  // ============================================================
  // FIXED ADD TO CART FOOTER
  // ============================================================

  Widget _buildCartFooter() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: AccountActionButton(
          icon: Icons.shopping_cart_outlined,
          title: 'Add to Cart',
          onTap: () {
            // Cart logic will be connected later.
          },
        ),
      ),
    );
  }

  // ============================================================
  // INITIALIZATION LOGIC
  // ============================================================

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeImages();
  }

  void _initializeControllers() {
    _pageController = PageController();

    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  void _initializeImages() {
    final imageUrl = widget.product['imageUrl'];
    final galleryImages = widget.product['galleryImages'];

    final images = <String>[];

    if (imageUrl is String && imageUrl.isNotEmpty) {
      images.add(imageUrl);
    }

    if (galleryImages is List) {
      for (final image in galleryImages) {
        if (image is String && image.isNotEmpty) {
          images.add(image);
        }
      }
    }

    _images = images.toSet().toList();
  }

  // ============================================================
  // CLEANUP
  // ============================================================

  @override
  void dispose() {
    _pageController.dispose();
    _borderController.dispose();
    super.dispose();
  }
}

// ================================================================
// FULL-SCREEN IMAGE VIEWER
// ================================================================

class _FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullScreenImageViewer({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FullScreenImageViewer> createState() =>
      _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late final PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(
      initialPage: widget.initialIndex,
    );
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Center(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Image.network(
                    widget.images[index],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white54,
                        size: 48,
                      );
                    },
                  ),
                ),
              );
            },
          ),

          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: IconButton(
              tooltip: 'Close image',
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),

          // Image counter
          if (widget.images.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 24,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.images.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Cleanup
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// ================================================================
// CUSTOM PAINTER: ROTATING GREEN GRADIENT BORDER
// ================================================================

class _ProductBorderPainter extends CustomPainter {
  final double progress;

  _ProductBorderPainter({
    required this.progress,
  });

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
