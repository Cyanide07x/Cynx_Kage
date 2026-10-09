import 'package:flutter/material.dart';
import '../../theme/appcolors.dart';
import '../../Widgets/trending.dart';

class MenScreen extends StatelessWidget {
  const MenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = [
      {'name': 'Oversized T-shirt', 'price': 'Rs. 999'},
      {'name': 'Cargo Pants', 'price': 'Rs. 1,499'},
      {'name': 'Straight Jeans', 'price': 'Rs. 999'},
      {'name': 'Jackets', 'price': 'Rs. 2,999'},
      {'name': 'Boxer Shirts', 'price': 'Rs. 999'},
      {'name': 'Boxer Fit Jacket', 'price': 'Rs. 1,999'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 25, bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Men's Collection",
              style: TextStyle(
                color: AppColors.text,
                fontSize: 26,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Explore the latest styles for men.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 22),
          GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              final product = products[index];

              return TrendingProductCard(
                name: product['name']!,
                price: product['price']!,
              );
            },
          ),
        ],
      ),
    );
  }
}