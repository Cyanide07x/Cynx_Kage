
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Trending extends StatelessWidget {
  const Trending({super.key});

  @override
  Widget build(BuildContext context) {
    final productsStream = FirebaseFirestore.instance
        .collection('catalogProducts')
        .where('isActive', isEqualTo: true)
        .where('isFeatured', isEqualTo: true)
        .snapshots();

    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Trending heading
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

        // Featured products from Firestore
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: productsStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Unable to load trending products.',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(30),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final products = snapshot.data!.docs;

            if (products.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'No featured products available.',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                    ),
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
                final product = products[index].data();

                return TrendingProductCard(
                  name: (product['name'] ?? 'Unnamed product')
                      .toString(),
                  price: 'Rs. ${(product['price'] ?? 0).toString()}',
                  imageAsset: (product['imageUrl'] ?? '').toString(),
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

  const TrendingProductCard({
    super.key,
    required this.name,
    required this.price,
    this.imageAsset,
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

  // Fallback when an image cannot be loaded.
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

  // Supports both online URLs and local asset paths.
  Widget _buildProductImage() {
    final image = widget.imageAsset;

    if (image == null || image.isEmpty) {
      return _imagePlaceholder();
    }

    if (image.startsWith('http://') ||
        image.startsWith('https://')) {
      return Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _imagePlaceholder();
        },
      );
    }

    return Image.asset(
      image,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _imagePlaceholder();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ProductBorderPainter(
            progress: _controller.value,
            accentColor: colors.primary,
            secondaryColor: colors.secondary,
            surfaceColor: colors.surface,
          ),
          child: Container(
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
                // Product image
                _buildProductImage(),

                // Dark gradient for readable product details
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

                // Product name and price
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
              ],
            ),
          ),
        );
      },
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
