import 'package:flutter/material.dart';
import '../theme/appcolors.dart';

class NewArrivals extends StatefulWidget {
  const NewArrivals({super.key});

  @override
  State<NewArrivals> createState() => _NewArrivalsState();
}

class _NewArrivalsState extends State<NewArrivals>
    with SingleTickerProviderStateMixin {
  bool isWishlisted = false;

  late AnimationController _newAnimationController;

  @override
  void initState() {
    super.initState();

    _newAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
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
            decoration: BoxDecoration(
              color: AppColors.text,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Stack(
              children: [
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
                        isWishlisted
                            ? Icons.favorite
                            : Icons.favorite_border,
                      ),
                      color: isWishlisted
                          ? Colors.red
                          : AppColors.text,
                      onPressed: () {
                        setState(() {
                          isWishlisted = !isWishlisted;
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
          children: [
            _dot(true),
            _dot(false),
            _dot(false),
            _dot(false),
          ],
        ),
      ],
    );
  }

  Widget _dot(bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 38,
      height: 20,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.border,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}