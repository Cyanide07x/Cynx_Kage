import 'package:flutter/material.dart';
import '../theme/appcolors.dart';

class ProductDetails extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetails({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product['name'] ?? 'Product Name',
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          '₹${product['price'] ?? 0}',
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          product['description'] ?? '',
          style: TextStyle(
            color: AppColors.text.withValues(alpha: 0.7),
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}