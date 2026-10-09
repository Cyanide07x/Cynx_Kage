import 'package:flutter/material.dart';

import '../../theme/appcolors.dart';
import '../../Widgets/trending.dart';

class WomenScreen extends StatelessWidget {
  const WomenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = [
      {'name': 'Oversized T-shirt', 'price': 'Rs. 999'},
      {'name': 'Wide-Leg Jeans', 'price': 'Rs. 1,499'},
      {'name': 'Crop Top', 'price': 'Rs. 799'},
      {'name': "Women's Jacket", 'price': 'Rs. 2,499'},
      {'name': 'Cargo Pants', 'price': 'Rs. 1,299'},
      {'name': 'Casual Shirt', 'price': 'Rs. 1,199'},
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Women's Collection",
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
              'Discover your next favourite look.',
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