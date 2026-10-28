import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../screens/cart/cart_screen.dart';
import '../screens/cart/cart_controller.dart';
import '../screens/cart/cart_item.dart';
import '../screens/account/account_action_button.dart';
import 'product_details.dart';
import 'wishlist_icon.dart';

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
  String? _selectedSize;
  late Map<String, dynamic> _productData;

  late final AnimationController _borderController;
  late final PageController _pageController;
  late final List<String> _images;

  String get _productId {
    final product = _productData;

    for (final key in ['id', 'productId', 'slug']) {
      final value = product[key];

      if (value != null) {
        final id = value.toString().trim();

        if (id.isNotEmpty && id.toLowerCase() != 'null') {
          return id;
        }
      }
    }

    return '';
  }

  double get _productPrice {
    final value = _productData['price'];

    if (value is num) return value.toDouble();

    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  String get _productName =>
      (_productData['name'] ?? 'Product').toString();

  String get _productImage =>
      (_productData['imageUrl'] ?? '').toString();

  String get _productDescription =>
      (_productData['description'] ?? '').toString();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      bottomNavigationBar: _buildCartFooter(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 25),

                _buildHeader(),

                const SizedBox(height: 25),

                _buildProductImage(),

                const SizedBox(height: 25),

                _buildImageIndicators(),

                const SizedBox(height: 25),

                // Product information and wishlist stay together.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ProductDetails(
                        product: _productData,
                        onSizeChanged: (size) {
                          setState(() {
                            _selectedSize = size;
                          });
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    if (_productId.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 2,
                          right: 4,
                        ),
                        child: WishlistIcon(
                          productId: _productId,
                          name: _productName,
                          price: _productPrice,
                          imageUrl: _productImage,
                          description: _productDescription,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // FULL-WIDTH DESCRIPTION BOX.
                // This is outside the Row, so it isn't constrained
                // by the width reserved for the wishlist icon.
                ProductDescription(
                  product: _productData,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // HEADER

  Widget _buildHeader() {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        _buildHeaderButton(
          icon: Icons.arrow_back,
          onTap: () => Navigator.of(context).maybePop(),
        ),
        const Spacer(),
        ListenableBuilder(
          listenable: CartController.instance,
          builder: (context, _) {
            final count = CartController.instance.totalCount;

            return Badge.count(
              count: count,
              isLabelVisible: count > 0,
              backgroundColor: colors.primary,
              textColor: colors.onPrimary,
              alignment: const AlignmentDirectional(0.7, -0.6),
              child: IconButton(
                icon: Icon(
                  Icons.shopping_bag_outlined,
                  color: colors.onSurface,
                  size: 24,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CartScreen(),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        border: Border.all(
          color: colors.outline,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        icon: Icon(
          icon,
          color: colors.onSurface,
          size: 20,
        ),
      ),
    );
  }

  // PRODUCT IMAGE CAROUSEL

  Widget _buildProductImage() {
    final colors = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _borderController,
      builder: (context, child) {
        return CustomPaint(
          painter: _ProductBorderPainter(
            progress: _borderController.value,
            primaryColor: colors.primary,
            secondaryColor: colors.secondary,
            surfaceColor: colors.surface,
          ),
          child: Container(
            width: double.infinity,
            height: 325,
            margin: const EdgeInsets.all(2.5),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(21.5),
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
                          alignment: Alignment.center,
                          gaplessPlayback: true,
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
    return Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Theme.of(context).colorScheme.error,
        size: 40,
      ),
    );
  }

  // IMAGE PAGE INDICATORS

  Widget _buildImageIndicators() {
    if (_images.length <= 1) {
      return const SizedBox.shrink();
    }

    final colors = Theme.of(context).colorScheme;

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
                ? colors.onSurface
                : colors.outline,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }

  // FULL-SCREEN IMAGE VIEWER

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

  // ADD TO CART

  Future<void> _addToCart() async {
    if (_selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a size first.'),
        ),
      );
      return;
    }

    final productId = _productId;

    if (productId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to identify this product. Please try again.',
          ),
        ),
      );

      debugPrint('ADD TO CART: Missing product ID: ${widget.product}');
      return;
    }

    try {
      await CartController.instance.addItem(
        CartItem(
          productId: productId,
          name: _productName,
          imageUrl: _productImage,
          price: _productPrice,
          size: _selectedSize!,
          color: (_productData['color'] ?? 'Default').toString(),
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product added to cart!'),
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('ADD TO CART ERROR: $error');
      debugPrint('STACK TRACE: $stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cart error: $error'),
          duration: const Duration(seconds: 8),
        ),
      );
    }
  }

  Widget _buildCartFooter() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: AccountActionButton(
          icon: Icons.shopping_cart_outlined,
          title: 'Add to Cart',
          onTap: _addToCart,
        ),
      ),
    );
  }

  // INITIALIZATION

  @override
  void initState() {
    super.initState();
    _productData = Map<String, dynamic>.from(widget.product);
    _initializeControllers();
    _initializeImages();
    _fetchFullProductIfNeeded();
  }

  Future<void> _fetchFullProductIfNeeded() async {
    final sizes = _productData['sizes'];
    final bool hasSizes = sizes is List && sizes.isNotEmpty;
    final productId = _productId;
    if (productId.isEmpty || hasSizes) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();
      if (doc.exists && doc.data() != null && mounted) {
        setState(() {
          _productData = {
            ...doc.data()!,
            'id': doc.id,
            ..._productData,
            ...doc.data()!,
          };
          _initializeImages();
        });
      }
    } catch (e) {
      debugPrint('Error fetching product details: $e');
    }
  }

  void _initializeControllers() {
    _pageController = PageController();

    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  void _initializeImages() {
    final imageUrl = _productData['imageUrl'];
    final galleryImages = _productData['galleryImages'];

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

  @override
  void dispose() {
    _pageController.dispose();
    _borderController.dispose();
    super.dispose();
  }
}

// FULL-SCREEN IMAGE VIEWER

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// ROTATING THEME GRADIENT BORDER

class _ProductBorderPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color secondaryColor;
  final Color surfaceColor;

  _ProductBorderPainter({
    required this.progress,
    required this.primaryColor,
    required this.secondaryColor,
    required this.surfaceColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 2.5;
    final rect = Offset.zero & size;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = SweepGradient(
        colors: [
          secondaryColor,
          primaryColor,
          surfaceColor,
          primaryColor,
          secondaryColor,
        ],
        transform: GradientRotation(progress * 2 * math.pi),
      ).createShader(rect);

    final borderRect = RRect.fromRectAndRadius(
      rect.deflate(strokeWidth / 2),
      const Radius.circular(24),
    );

    canvas.drawRRect(borderRect, paint);
  }

  @override
  bool shouldRepaint(covariant _ProductBorderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.surfaceColor != surfaceColor;
  }
}