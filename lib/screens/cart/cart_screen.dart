
import 'package:flutter/material.dart';

import 'cart_item.dart';
import 'cart_card.dart';
import 'cart_controller.dart';
import '../../checkout/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Cart starts empty until products are added.
  List<CartItem> get _cartItems => CartController.instance.items;
  
  bool _isLoading = true;
  String? _loadError;


  static const double _freeDeliveryThreshold = 1700;
  static const double _deliveryCharge = 99;

  double get _subtotal => _cartItems.fold(
        0.0,
        (sum, item) => sum + item.totalPrice,
      );

  double get _delivery {
    if (_cartItems.isEmpty || _subtotal >= _freeDeliveryThreshold) {
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

  String _formatPrice(double price) => '₹${price.toStringAsFixed(0)}';

  Future<void> _updateQuantity(CartItem item, int quantity) async {
    if (quantity < 1) return;

    try {
      await CartController.instance.updateQuantity(item, quantity);

      if (!mounted) return;
      setState(() {});
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not update quantity. Please try again.'),
        ),
      );
    }
  }

  Future<void> _removeItem(CartItem item) async {
    try {
      await CartController.instance.removeItem(item);

      if (!mounted) return;
      setState(() {});
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not remove item. Please try again.'),
        ),
      );
    }
  }

  
  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      await CartController.instance.loadCart();

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _loadError = 'Could not load your cart. Please try again.';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Existing header
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
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
                        color: colors.outlineVariant,
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
                      icon: Icon(
                        Icons.arrow_back,
                        color: colors.onSurface,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cart',
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _totalQuantity > 0
                              ? 'Almost yours · $_totalQuantity ${_totalQuantity == 1 ? 'item' : 'items'}'
                              : 'Almost yours',
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
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
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _loadError != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _loadError!,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton(
                                  onPressed: _loadCart,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _cartItems.isEmpty
                          ? _buildEmptyCart()
                          : _buildCartContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    final colors = Theme.of(context).colorScheme;

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
                border: Border.all(color: colors.outlineVariant),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                color: colors.primary,
                size: 34,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Your bag is empty',
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your next favorite piece is waiting.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurfaceVariant,
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
                foregroundColor: colors.primary,
                side: BorderSide(color: colors.primary),
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
    final colors = Theme.of(context).colorScheme;

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
                  color: colors.surface,
                  border: Border.all(color: colors.outlineVariant),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _subtotal >= _freeDeliveryThreshold
                          ? 'You unlocked free delivery!'
                          : 'Add ${_formatPrice(_freeDeliveryThreshold - _subtotal)} more for free delivery',
                      style: TextStyle(
                        color: colors.onSurface,
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
                        backgroundColor: colors.outlineVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colors.primary,
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
                valueColor: colors.primary,
              ),
              const SizedBox(height: 16),
              Divider(color: colors.outlineVariant),
              const SizedBox(height: 12),
              _priceRow(
                'Total',
                _formatPrice(_total),
                valueColor: colors.primary,
                bold: true,
              ),
            ],
          ),
        ),

        // Checkout bar
        Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(
              top: BorderSide(color: colors.outlineVariant),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'TOTAL',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatPrice(_total),
                      style: TextStyle(
                        color: colors.primary,
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
                    onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const CheckoutScreen(),
    ),
  );
},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.onSurface,
                      side: BorderSide(color: colors.outlineVariant),
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
    Color? valueColor,
    bool bold = false,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 12,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? colors.onSurface,
            fontSize: bold ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
