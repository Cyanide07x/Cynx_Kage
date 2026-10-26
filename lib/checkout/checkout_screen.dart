import 'package:flutter/material.dart';

import '../screens/cart/cart_card.dart';
import '../screens/cart/cart_controller.dart';
import '../screens/cart/cart_item.dart';
import '../screens/address/address_screen.dart';
import '../screens/address/saved_address.dart';
import 'payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const double _freeDeliveryThreshold = 1700;
  static const double _deliveryCharge = 99;

  SavedAddress? _selectedAddress;

  Future<void> _selectDeliveryAddress() async {
    final address = await Navigator.push<SavedAddress>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddressScreen(
          selectionMode: true,
        ),
      ),
    );

    if (!mounted || address == null) return;

    setState(() {
      _selectedAddress = address;
    });
  }

  bool _isLoading = true;
  String? _loadError;

  List<CartItem> get _cartItems => CartController.instance.items;

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
        _loadError = 'Unable to load your bag. Please try again.';
      });
    }
  }

  Future<void> _updateQuantity(CartItem item, int quantity) async {
    if (quantity < 1) return;

    try {
      await CartController.instance.updateQuantity(item, quantity);

      if (!mounted) return;
      setState(() {});
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update quantity.')),
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
        const SnackBar(content: Text('Could not remove this item.')),
      );
    }
  }

  String _money(double amount) => '₹${amount.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          border: Border.all(color: colors.outline),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: Icon(
                            Icons.arrow_back,
                            color: colors.onSurface,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Checkout',
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 60),
                    child: Text(
                      'Nearly Home',
                      style: TextStyle(
                        color: theme.textTheme.bodySmall?.color,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),

            // Checkout content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
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
                                  style: TextStyle(color: colors.onSurface),
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton(
                                  onPressed: _loadCart,
                                  child: const Text('Try again'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _cartItems.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.shopping_bag_outlined,
                                      size: 56,
                                      color: colors.onSurfaceVariant,
                                    ),
                                    const SizedBox(height: 16),
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
                                      'Add some items before checking out.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    OutlinedButton(
                                      onPressed: () =>
                                          Navigator.of(context).maybePop(),
                                      child: const Text('Back to bag'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your order ($_totalQuantity items)',
                                    style: TextStyle(
                                      color: colors.onSurface,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Uses the exact same cart items and card
                                  // widget as the Bag screen.
                                  ..._cartItems.map(
                                    (item) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: CartCard(
                                        item: item,
                                        onRemove: () => _removeItem(item),
                                        onQuantityChanged: (quantity) =>
                                            _updateQuantity(item, quantity),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),
                                  Divider(color: colors.outlineVariant),
                                  const SizedBox(height: 12),

                                  Text(
                                    'Order summary',
                                    style: TextStyle(
                                      color: colors.onSurface,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  _summaryRow(
                                    'Subtotal',
                                    _money(_subtotal),
                                  ),
                                  const SizedBox(height: 12),
                                  _summaryRow(
                                    'Delivery',
                                    _delivery == 0 && _cartItems.isNotEmpty
                                        ? 'Free'
                                        : _money(_delivery),
                                  ),
                                  if (_subtotal < _freeDeliveryThreshold &&
                                      _cartItems.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    Text(
                                      'Add ${_money(_freeDeliveryThreshold - _subtotal)} more for free delivery.',
                                      style: TextStyle(
                                        color: colors.primary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  Divider(color: colors.outlineVariant),
                                  const SizedBox(height: 12),
                                  _summaryRow(
                                    'Total',
                                    _money(_total),
                                    isTotal: true,
                                  ),

                                  const SizedBox(height: 24),

                                  // Delivery address selection.
                                  InkWell(
                                    onTap: _selectDeliveryAddress,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: colors.outlineVariant,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.location_on_outlined,
                                            color: colors.primary,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Delivery address',
                                                  style: TextStyle(
                                                    color: colors.onSurface,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                if (_selectedAddress == null)
                                                  Text(
                                                    'Select your delivery address',
                                                    style: TextStyle(
                                                      color: colors.onSurfaceVariant,
                                                      fontSize: 13,
                                                    ),
                                                  )
                                                else ...[
                                                  Text(
                                                    _selectedAddress!.name,
                                                    style: TextStyle(
                                                      color: colors.onSurface,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Text(
                                                    '${_selectedAddress!.address}, '
                                                    '${_selectedAddress!.city}, '
                                                    '${_selectedAddress!.state} - '
                                                    '${_selectedAddress!.pin}',
                                                    style: TextStyle(
                                                      color: colors.onSurfaceVariant,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Text(
                                                    _selectedAddress!.phone,
                                                    style: TextStyle(
                                                      color: colors.onSurfaceVariant,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            _selectedAddress == null
                                                ? Icons.chevron_right
                                                : Icons.edit_outlined,
                                            color: colors.onSurfaceVariant,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _sectionPlaceholder(
                                    context,
                                    icon: Icons.local_shipping_outlined,
                                    title: 'Delivery speed',
                                    subtitle: 'Delivery options can be added next',
                                  ),
                                  const SizedBox(height: 12),

InkWell(
  onTap: () async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PaymentScreen(),
      ),
    );
  },
  borderRadius: BorderRadius.circular(12),
  child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
    ),
    child: Row(
      children: [
        Icon(
          Icons.payment_outlined,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment method',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose how you want to pay',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ],
    ),
  ),
),
                                ],
                              ),
                            ),
            ),
          ],
        ),
      ),

      // Fixed bottom total and UI-only button.
      bottomNavigationBar: !_isLoading &&
              _loadError == null &&
              _cartItems.isNotEmpty
          ? SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  border: Border(
                    top: BorderSide(color: colors.outlineVariant),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _money(_total),
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Checkout UI is ready. Order placement is not connected yet.',
                              ),
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Continue'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool isTotal = false,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? colors.onSurface : colors.onSurfaceVariant,
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _sectionPlaceholder(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
        ],
      ),
    );
  }
}