
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../screens/cart/cart_screen.dart';
import '../screens/cart/cart_controller.dart';
import '../screens/cart/cart_item.dart';
import '../screens/account/account_action_button.dart';
import 'product_details.dart';
import 'wishlist_icon.dart';
import 'reviews/reviews_section.dart';
import '../services/product_service.dart';

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

  final GlobalKey _reviewsKey = GlobalKey();

  String? _selectedSize;
  String? _selectedColor;
  Map<String, dynamic>? _selectedVariant;

  late Map<String, dynamic> _productData;
  late final AnimationController _borderController;
  late final PageController _pageController;

  List<String> _images = [];

  // PRODUCT DATA

  String get _productId {
    for (final key in ['product_id', 'id', 'productId', 'slug']) {
      final value = _productData[key];

      if (value != null) {
        final id = value.toString().trim();

        if (id.isNotEmpty && id.toLowerCase() != 'null') {
          return id;
        }
      }
    }

    return '';
  }

  int? get _selectedVariantId {
    final id = _selectedVariant?['variant_id'];

    if (id is num) return id.toInt();

    return int.tryParse(id?.toString() ?? '');
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();

    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  double get _productPrice {
    if (_selectedVariant != null) {
      return _toDouble(_selectedVariant!['price']);
    }

    final price = _productData['price'];

    if (price != null) return _toDouble(price);

    final variants = _productData['variants'];

    if (variants is List) {
      for (final item in variants) {
        if (item is Map) {
          final variant = Map<String, dynamic>.from(item);

          final active = variant['is_active'];
          final isActive = active == true || active == 1;

          if (isActive) {
            return _toDouble(variant['price']);
          }
        }
      }
    }

    return 0.0;
  }

  String get _productName {
    return (_productData['product_name'] ??
            _productData['name'] ??
            'Product')
        .toString();
  }

  String get _productDescription {
    return (_productData['description'] ?? '').toString();
  }

  String get _productImage {
    if (_images.isNotEmpty) return _images.first;

    final imageUrl = _productData['imageUrl'];

    if (imageUrl is String && imageUrl.isNotEmpty) {
      return imageUrl;
    }

    return '';
  }

  // REVIEWS

  void _scrollToReviews() {
    final targetContext = _reviewsKey.currentContext;

    if (targetContext != null) {
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  // COLOR SELECTION

  void _onColorChanged(String? color) {
    setState(() {
      _selectedColor = color;
      _selectedSize = null;
      _selectedVariant = null;
      _currentPage = 0;
    });

    // Color-specific image switching will be added after
    // product_images has a color mapping in MySQL.
  }

  // VARIANT SELECTION

  void _onVariantChanged(Map<String, dynamic>? variant) {
    setState(() {
      _selectedVariant = variant;
    });
  }

  // BUILD

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
                        onColorChanged: _onColorChanged,
                        onVariantChanged: _onVariantChanged,
                        onRatingTap: _scrollToReviews,
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

                ProductDescription(
                  product: _productData,
                ),

                const SizedBox(height: 24),

                ReviewsSection(
                  key: _reviewsKey,
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
                        child: CachedNetworkImage(
                          imageUrl: _images[index],
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          memCacheWidth: 1000,
                          placeholder: (context, url) =>
                              _buildImagePlaceholder(),
                          errorWidget: (context, url, error) =>
                              _buildImagePlaceholder(),
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

  // IMAGE INDICATORS

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
  // This still uses your existing local CartController.
  // We will connect it to the FastAPI cart endpoint separately.

  Future<void> _addToCart() async {
    if (_selectedColor == null || _selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a color and size first.'),
        ),
      );
      return;
    }

    if (_selectedVariant == null || _selectedVariantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a valid product variant.'),
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
          variantId: _selectedVariantId,
          productId: productId,
          name: _productName,
          imageUrl: _productImage,
          price: _productPrice,
          size: _selectedSize!,
          color: _selectedColor!,
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

    final rawVariants = _productData['variants'];
    if ((rawVariants is! List || rawVariants.isEmpty) && _productId.isNotEmpty) {
      _loadFullProductData();
    }
  }

  Future<void> _loadFullProductData() async {
    try {
      final fullProduct = await ProductService().fetchProduct(_productId);
      if (!mounted) return;
      setState(() {
        _productData = fullProduct.toProductPageMap();
        _initializeImages();
      });
    } catch (e) {
      debugPrint('ProductPage: Failed to load full product: $e');
    }
  }

  void _initializeControllers() {
    _pageController = PageController();

    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  // Supports both the old image format (List<String>)
  // and the FastAPI format (List<Map> with image_url).

  void _initializeImages() {
    final images = <String>[];

    final directImage = _productData['imageUrl'] ??
        _productData['image_url'];

    if (directImage is String && directImage.isNotEmpty) {
      images.add(directImage);
    }

    final gallery = _productData['images'] ??
        _productData['galleryImages'] ??
        _productData['gallery'];

    if (gallery is List) {
      final imageEntries = gallery
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      imageEntries.sort((a, b) {
        final aOrder = a['display_order'] is num
            ? (a['display_order'] as num).toInt()
            : 0;

        final bOrder = b['display_order'] is num
            ? (b['display_order'] as num).toInt()
            : 0;

        return aOrder.compareTo(bOrder);
      });

      // Put the primary image first when available.
      imageEntries.sort((a, b) {
        final aPrimary = a['is_primary'] == true ||
            a['is_primary'] == 1;

        final bPrimary = b['is_primary'] == true ||
            b['is_primary'] == 1;

        if (aPrimary == bPrimary) return 0;

        return aPrimary ? -1 : 1;
      });

      for (final image in imageEntries) {
        final url = image['image_url'] ?? image['imageUrl'];

        if (url is String && url.isNotEmpty) {
          images.add(url);
        }
      }

      // Also support older APIs that return a list of strings.
      for (final item in gallery.whereType<String>()) {
        if (item.isNotEmpty) {
          images.add(item);
        }
      }
    }

    _images = images.toSet().toList();

    _currentPage = 0;

    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
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

class _FullScreenImageViewerState
    extends State<_FullScreenImageViewer> {
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
                  child: CachedNetworkImage(
                    imageUrl: widget.images[index],
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white54,
                      size: 48,
                    ),
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
