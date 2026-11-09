
import 'package:flutter/material.dart';

class ProductDetails extends StatefulWidget {
  final Map<String, dynamic> product;
  final ValueChanged<String?> onSizeChanged;
  final ValueChanged<String?>? onColorChanged;
  final ValueChanged<Map<String, dynamic>?>? onVariantChanged;
  final VoidCallback? onRatingTap;

  const ProductDetails({
    super.key,
    required this.product,
    required this.onSizeChanged,
    this.onColorChanged,
    this.onVariantChanged,
    this.onRatingTap,
  });

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  String? selectedSize;
  String? selectedColor;
  Map<String, dynamic>? selectedVariant;

  List<Map<String, dynamic>> get variants {
    final raw = widget.product['variants'];

    if (raw is! List) return [];

    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .where((item) {
          final active = item['is_active'];
          return active == null || active == true || active == 1;
        })
        .toList();
  }

  List<String> get availableColors {
    return variants
        .map((variant) => variant['color']?.toString() ?? '')
        .where((color) => color.isNotEmpty)
        .toSet()
        .toList();
  }

  List<Map<String, dynamic>> get selectedColorVariants {
    return variants.where((variant) {
      return variant['color']?.toString() == selectedColor;
    }).toList();
  }

  List<String> get availableSizes {
    return selectedColorVariants
        .map((variant) => variant['size']?.toString() ?? '')
        .where((size) => size.isNotEmpty)
        .toSet()
        .toList();
  }

  double get selectedPrice {
    final price = selectedVariant?['price'];

    if (price is num) return price.toDouble();

    return double.tryParse(price?.toString() ?? '') ??
        _productPrice;
  }

  double get _productPrice {
    final price = widget.product['price'];

    if (price is num) return price.toDouble();

    return double.tryParse(price?.toString() ?? '') ?? 0;
  }

  int _stock(Map<String, dynamic> variant) {
    final value = variant['stock_quantity'];

    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  void _selectColor(String color) {
    setState(() {
      selectedColor = color;
      selectedSize = null;
      selectedVariant = null;
    });

    widget.onColorChanged?.call(color);
    widget.onSizeChanged(null);
    widget.onVariantChanged?.call(null);
  }

  void _selectSize(String size) {
    final matching = selectedColorVariants.where(
      (variant) => variant['size']?.toString() == size,
    );

    if (matching.isEmpty) return;

    final variant = matching.first;

    if (_stock(variant) <= 0) return;

    setState(() {
      selectedSize = size;
      selectedVariant = variant;
    });

    widget.onSizeChanged(size);
    widget.onVariantChanged?.call(variant);
  }

  @override
  void initState() {
    super.initState();

    final colors = availableColors;

    if (colors.isNotEmpty) {
      selectedColor = colors.first;

      final sizes = availableSizes;

      if (sizes.isNotEmpty) {
        final inStock = selectedColorVariants.where(
          (variant) => _stock(variant) > 0,
        );

        if (inStock.isNotEmpty) {
          selectedSize = inStock.first['size']?.toString();
          selectedVariant = inStock.first;
        }
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      widget.onColorChanged?.call(selectedColor);
      widget.onSizeChanged(selectedSize);
      widget.onVariantChanged?.call(selectedVariant);
    });
  }

  Color _swatchColor(String color) {
    switch (color.toLowerCase().trim()) {
      case 'black':
        return const Color(0xFF171717);
      case 'white':
        return const Color(0xFFF5F5F5);
      case 'red':
        return const Color(0xFFC62828);
      case 'blue':
        return const Color(0xFF2457A6);
      case 'navy':
        return const Color(0xFF18294A);
      case 'green':
        return const Color(0xFF39734B);
      case 'olive':
        return const Color(0xFF697447);
      case 'grey':
      case 'gray':
        return const Color(0xFF858585);
      case 'brown':
        return const Color(0xFF795548);
      case 'beige':
        return const Color(0xFFD7C4A5);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final colors = Theme.of(context).colorScheme;

    final productName =
        product['name'] ?? product['product_name'] ?? 'Product Name';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product name
        Text(
          productName.toString(),
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        // Ratings
        InkWell(
          onTap: widget.onRatingTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: colors.outlineVariant,
                      width: 0.8,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: Color(0xFFFFB800),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '4.8',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '128 ratings',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 14,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Dynamic price
        Text(
          '₹${selectedPrice.toStringAsFixed(0)}',
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 22),

        // Color selection
        Text(
          'Select Color',
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        if (availableColors.isEmpty)
          Text(
            'No colors available',
            style: TextStyle(color: colors.onSurfaceVariant),
          )
        else
          Wrap(
            spacing: 14,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: availableColors.map((color) {
              final isSelected = selectedColor == color;
              final swatch = _swatchColor(color);

              return GestureDetector(
                onTap: () => _selectColor(color),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 42,
                      height: 42,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? colors.primary
                              : colors.outline,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: swatch,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: color.toLowerCase() == 'white'
                                ? colors.outlineVariant
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      color,
                      style: TextStyle(
                        color: isSelected
                            ? colors.primary
                            : colors.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

        const SizedBox(height: 22),

        // Size selection
        Text(
          'Select Size',
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        if (availableSizes.isEmpty)
          Text(
            'No sizes available for this color.',
            style: TextStyle(color: colors.onSurfaceVariant),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: availableSizes.map((size) {
              final isSelected = selectedSize == size;

              final matching = selectedColorVariants.where(
                (variant) => variant['size']?.toString() == size,
              );

              final inStock = matching.isNotEmpty &&
                  _stock(matching.first) > 0;

              return GestureDetector(
                onTap: inStock ? () => _selectSize(size) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 45,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: !inStock
                        ? colors.surfaceContainerHighest
                        : isSelected
                            ? colors.primary
                            : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? colors.primary
                          : colors.outline,
                      width: isSelected ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    size,
                    style: TextStyle(
                      color: !inStock
                          ? colors.onSurface.withValues(alpha: 0.35)
                          : isSelected
                              ? colors.onPrimary
                              : colors.onSurface,
                      fontSize: 14,
                      decoration: inStock
                          ? null
                          : TextDecoration.lineThrough,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

// Full-width Product Description
class ProductDescription extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDescription({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            (product['description'] ?? 'No description available.')
                .toString(),
            style: TextStyle(
              color: colors.onSurface.withValues(alpha: 0.75),
              fontSize: 14,
              height: 1.75,
            ),
          ),
        ],
      ),
    );
  }
}
