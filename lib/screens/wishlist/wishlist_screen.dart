import 'package:flutter/material.dart';
import '../../theme/appcolors.dart';
import '../../Widgets/trending.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final List<Map<String, String>> wishlistItems = [
    {'name': 'Oversized T-shirt', 'price': 'Rs. 999'},
    {'name': 'Cargo Pants', 'price': 'Rs. 1,499'},
    {'name': 'Straight Jeans', 'price': 'Rs. 999'},
    {'name': 'Jackets', 'price': 'Rs. 2,999'},
  ];

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

              // Wishlist header
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

                  const SizedBox(width: 20),

                  // Wishlist title and count
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Wishlist',
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${wishlistItems.length} saved pieces',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Share button
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
                      onPressed: () {},
                      icon: const Icon(
                        Icons.ios_share,
                        color: AppColors.text,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // Wishlist products grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.only(
                    top: 10,
                    bottom: 20,
                  ),
                  itemCount: wishlistItems.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, index) {
                    final product = wishlistItems[index];

                    return TrendingProductCard(
  name: product['name']!,
  price: product['price']!,
);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}