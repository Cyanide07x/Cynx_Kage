import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/appcolors.dart';

class Trending extends StatelessWidget {
  const Trending({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Trending heading
        const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trending Now',
                  style: TextStyle(
                    color: AppColors.text,
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
        ),

        const SizedBox(height: 12),

        // Product grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: const [
            TrendingProductCard(
              name: 'Oversized T-shirt',
              price: 'Rs. 999',
            ),
            TrendingProductCard(
              name: 'Cargo Pants',
              price: 'Rs. 1,499',
            ),
            TrendingProductCard(
              name: 'Straight Jeans',
              price: 'Rs. 999',
            ),
            TrendingProductCard(
              name: 'Jackets',
              price: 'Rs. 2,999',
            ),
            TrendingProductCard(
              name: 'Boxer-Shirts',
              price: 'Rs. 999',
            ),
            TrendingProductCard(
              name: 'Boxer Fit Jacket',
              price: 'Rs. 1,999',
            ),
          ],
        ),
      ],
    );
  }
}

class TrendingProductCard extends StatefulWidget {
  final String name;
  final String price;

  const TrendingProductCard({
    super.key,
    required this.name,
    required this.price,
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ProductBorderPainter(
            progress: _controller.value,
          ),
          child: Container(
            width: double.infinity,
            height: 250,
            margin: const EdgeInsets.all(1.2),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18.8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.price,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProductBorderPainter extends CustomPainter {
  final double progress;

  _ProductBorderPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 1.2;

    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = SweepGradient(
        transform: GradientRotation(progress * 2 * math.pi),
        colors: const [
          Color(0xFFC5E37A),
          Color(0xFF5E8E6E),
          Color(0xFF1E3A2F),
          Color(0xFF5E8E6E),
          Color(0xFFC5E37A),
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
    return oldDelegate.progress != progress;
  }
}