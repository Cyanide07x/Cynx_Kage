
import 'package:flutter/material.dart';

class ProductDetails extends StatefulWidget {
  final Map<String, dynamic> product;
  final ValueChanged<String?> onSizeChanged;

  const ProductDetails({
    super.key,
    required this.product,
    required this.onSizeChanged,
  });

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  String? selectedSize;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Name
        Text(
          product['name']?.toString() ?? 'Product Name',
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        // Product Price
        Text(
          '₹${product['price'] ?? 0}',
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 20),

        // Available Sizes
        Text(
          'Available Sizes',
          style: TextStyle(
            color: colors.onSurface,
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

                // Send the selected size to ProductPage.
                widget.onSizeChanged(sizeValue);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 45,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: colors.outline,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  sizeValue,
                  style: TextStyle(
                    color: isSelected
                        ? colors.onPrimary
                        : colors.onSurface,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 12),

        // Product Description Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border.all(
              color: colors.outline,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PRODUCT DESCRIPTION',
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                (product['description'] ??
                        'No description available.')
                    .toString(),
                style: TextStyle(
                  color: colors.onSurface.withValues(alpha: 0.75),
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
