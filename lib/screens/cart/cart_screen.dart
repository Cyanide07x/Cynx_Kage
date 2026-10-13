import 'package:flutter/material.dart';

import '../../theme/appcolors.dart';
import 'cart_item.dart';
import 'cart_card.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Cart starts empty until products are added.
  final List<CartItem> _cartItems = [
  CartItem(
    productId: 'test-001',
    name: 'Oversized Graphic Tee',
    imageUrl: 'assets/images/Trending_image/Trending_2.jpg',
    price: 799,
    size: 'L',
    color: 'Black',
    quantity: 1,
  ),
  CartItem(
    productId: 'test-002',
    name: 'Essential Hoodie',
    imageUrl: 'assets/images/Trending_image/Trending_3.jpg',
    price: 1299,
    size: 'M',
    color: 'Bone',
    quantity: 1,
  ),
  CartItem(
    productId: 'test-003',
    name: 'Cargo Pants',
    imageUrl: 'assets/images/Trending_image/Trending_6.jpg',
    price: 999,
    size: '32',
    color: 'Olive',
    quantity: 1,
  ),
];

  static const double _freeDeliveryThreshold = 1700;
  static const double _deliveryCharge = 99;

  double get _subtotal => _cartItems.fold(
        0.0,
        (sum, item) => sum + item.totalPrice,
      );

  double get _delivery {
    if (_cartItems.isEmpty ||
        _subtotal >= _freeDeliveryThreshold) {
      return 0;
    }
    return _deliveryCharge;
  }

  double get _total => _subtotal + _delivery;

  int get _totalQuantity => _cartItems.fold(
        0,
        (sum, item) => sum + item.quantity,
      );

  double get _deliveryProgress =>
      (_subtotal / _freeDeliveryThreshold).clamp(0.0, 1.0);

  String _formatPrice(double price) =>
      '₹${price.toStringAsFixed(0)}';

  void _updateQuantity(CartItem item, int quantity) {
    if (quantity < 1) return;

    setState(() {
      item.quantity = quantity;
    });
  }

  void _removeItem(CartItem item) {
    setState(() {
      _cartItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Existing header
            Padding(
              padding: const EdgeInsets.only(
                left: 5,
                right: 20,
                top: 25,
              ),
              child: Row(
                children: [
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
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.text,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cart',
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _totalQuantity > 0
                              ? 'Almost yours · $_totalQuantity ${_totalQuantity == 1 ? 'item' : 'items'}'
                              : 'Almost yours',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: _cartItems.isEmpty
                  ? _buildEmptyCart()
                  : _buildCartContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: AppColors.primary,
                size: 34,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your bag is empty',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your next favorite piece is waiting.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(
                  color: AppColors.primary,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
              ),
              child: const Text('CONTINUE SHOPPING'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            children: [
              // Free delivery progress
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _subtotal >= _freeDeliveryThreshold
                          ? 'You unlocked free delivery!'
                          : 'Add ${_formatPrice(_freeDeliveryThreshold - _subtotal)} more for free delivery',
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: _deliveryProgress,
                        minHeight: 5,
                        backgroundColor: AppColors.border,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Reusable product cards
              ..._cartItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CartCard(
                    item: item,
                    onQuantityChanged: (quantity) {
                      _updateQuantity(item, quantity);
                    },
                    onRemove: () {
                      _removeItem(item);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              _priceRow('Subtotal', _formatPrice(_subtotal)),
              const SizedBox(height: 12),
              _priceRow(
                'Delivery',
                _delivery == 0 ? 'FREE' : _formatPrice(_delivery),
                valueColor: AppColors.primary,
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.border),
              const SizedBox(height: 12),
              _priceRow(
                'Total',
                _formatPrice(_total),
                valueColor: AppColors.primary,
                bold: true,
              ),
            ],
          ),
        ),

        // Checkout bar
        Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: AppColors.border),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'TOTAL',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatPrice(_total),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton(
                    onPressed: _cartItems.isEmpty
                        ? null
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Checkout will be connected next.',
                                ),
                              ),
                            );
                          },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.text,
                      side: const BorderSide(
                        color: AppColors.border,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Checkout',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 17),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _priceRow(
    String label,
    String value, {
    Color valueColor = AppColors.text,
    bool bold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: bold ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}