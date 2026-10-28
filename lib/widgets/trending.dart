import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'wishlist_icon.dart';
import 'product_page.dart';

class Trending extends StatelessWidget {
  const Trending({super.key});

  static final Stream<QuerySnapshot<Map<String, dynamic>>> _featuredStream =
      FirebaseFirestore.instance
          .collection('catalogProducts')
          .where('isActive', isEqualTo: true)
          .where('isFeatured', isEqualTo: true)
          .snapshots();

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trending Now',
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
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _featuredStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Unable to load trending products.',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(30),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final products = snapshot.data!.docs;

            if (products.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'No featured products available.',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: products.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, index) {
                final document = products[index];
                final product = document.data();
                final rawPrice = product['price'];

                final price = rawPrice is num
                    ? rawPrice.toDouble()
                    : double.tryParse(rawPrice?.toString() ?? '') ?? 0.0;

                final imageUrl =
                    (product['imageUrl'] ?? '').toString();

                final fullProduct = <String, dynamic>{
                  ...product,
                  'id': document.id,
                };

                return TrendingProductCard(
                  productId: document.id,
                  name: (product['name'] ?? 'Unnamed product').toString(),
                  price: 'Rs. ${price.toStringAsFixed(0)}',
                  productPrice: price,
                  imageAsset: imageUrl,
                  description:
                      (product['description'] ?? '').toString(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => ProductPage(product: fullProduct),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class TrendingProductCard extends StatefulWidget {
  final String name;
  final String price;
  final String? imageAsset;

  // Optional to preserve compatibility with existing card usages.
  final String? productId;
  final double? productPrice;
  final String description;
  final VoidCallback? onTap;

  const TrendingProductCard({
    super.key,
    required this.name,
    required this.price,
    this.imageAsset,
    this.productId,
    this.productPrice,
    this.description = '',
    this.onTap,
  });

  @override
  State<TrendingProductCard> createState() =>
      _TrendingProductCardState();
}

class _TrendingProductCardState extends State<TrendingProductCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _imagePlaceholder() {
    final colors = Theme.of(context).colorScheme;

    return Container(
      color: colors.surface,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: colors.onSurfaceVariant,
        size: 35,
      ),
    );
  }

  Widget _buildProductImage() {
    final image = widget.imageAsset;

    if (image == null || image.isEmpty) {
      return _imagePlaceholder();
    }

    if (image.startsWith('http://') || image.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: image,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        memCacheWidth: 600,
        placeholder: (context, url) => _imagePlaceholder(),
        errorWidget: (context, url, error) => _imagePlaceholder(),
      );
    }

    return Image.asset(
      image,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      errorBuilder: (context, error, stackTrace) =>
          _imagePlaceholder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final cardContent = Container(
      width: double.infinity,
      height: 250,
      margin: const EdgeInsets.all(1.2),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18.8),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildProductImage(),

          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color(0x22000000),
                  Color(0xE6000000),
                ],
                stops: [0.35, 0.58, 1.0],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(15),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.price,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
              ),
            ),
          ),

          if (widget.productId != null)
            Positioned(
              top: 10,
              right: 10,
              child: WishlistIcon(
                productId: widget.productId!,
                name: widget.name,
                price: widget.productPrice ?? 0.0,
                imageUrl: widget.imageAsset ?? '',
                description: widget.description,
              ),
            ),
        ],
      ),
    );

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        child: cardContent,
        builder: (context, child) {
          return CustomPaint(
            painter: _ProductBorderPainter(
              progress: _controller.value,
              accentColor: colors.primary,
              secondaryColor: colors.secondary,
              surfaceColor: colors.surface,
            ),
            child: child,
          );
        },
      ),
    );
  }
}

class _ProductBorderPainter extends CustomPainter {
  final double progress;
  final Color accentColor;
  final Color secondaryColor;
  final Color surfaceColor;

  _ProductBorderPainter({
    required this.progress,
    required this.accentColor,
    required this.secondaryColor,
    required this.surfaceColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 1.2;

    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = SweepGradient(
        transform: GradientRotation(progress * 2 * math.pi),
        colors: [
          accentColor,
          secondaryColor,
          surfaceColor,
          secondaryColor,
          accentColor,
        ],
      ).createShader(rect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.deflate(strokeWidth / 2),
        const Radius.circular(20),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProductBorderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.surfaceColor != surfaceColor;
  }
}