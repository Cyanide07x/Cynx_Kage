import 'package:flutter/material.dart';
import '../theme/appcolors.dart';

class ProductDetails extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetails({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  String? selectedSize;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Name
        Text(
          product['name'] ?? 'Product Name',
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        // Product Price
        Text(
          '₹${product['price'] ?? 0}',
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 20),

        // Available Sizes
        const Text(
          'Available Sizes',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: ((product['sizes'] as List?) ?? []).map((size) {
            final sizeValue = size.toString();
            final isSelected = selectedSize == sizeValue;

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedSize = sizeValue;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 45,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.secondary
                      : Colors.transparent,
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  sizeValue,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 50),

        // Product Description Heading
        const Text(
          'Product Description',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 10),

        // Product Description
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