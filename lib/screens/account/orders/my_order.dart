import 'package:flutter/material.dart';

import '../../../orders/controllers/order_controller.dart';
import '../../../theme/theme_controller.dart';
import '../../../theme/apptheme.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final OrderController _controller = OrderController.instance;

  @override
  void initState() {
    super.initState();
    _controller.loadOrders();
  }

  String _money(num amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        final currentTheme = Theme.of(context);
        final currentColors = currentTheme.colorScheme;

        final isCynx =
            themeController.selectedTheme == CynxThemeMode.cynx;

        final accent = isCynx
            ? const Color(0xFFE50046)
            : const Color(0xFFBBD58E);

        return Scaffold(
          backgroundColor: currentTheme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 25,
                    bottom: 15,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: currentColors.outlineVariant,
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
                            color: currentColors.onSurface,
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
                              'My Orders',
                              style: TextStyle(
                                color: currentColors.onSurface,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Track & manage your orders',
                              style: TextStyle(
                                color: currentColors.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      if (_controller.isLoading && _controller.orders.isEmpty) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: accent,
                          ),
                        );
                      }

                      if (_controller.error != null && _controller.orders.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Could not load your orders.\n${_controller.error}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: currentColors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                OutlinedButton(
                                  onPressed: () => _controller.loadOrders(),
                                  child: const Text('Try Again'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final orders = _controller.orders;

                      if (orders.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: () => _controller.loadOrders(),
                          color: accent,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.5,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.shopping_bag_outlined,
                                          size: 64,
                                          color: currentColors.onSurfaceVariant,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No orders yet',
                                          style: TextStyle(
                                            color: currentColors.onSurface,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Your orders will appear here after you place an order.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: currentColors.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () => _controller.loadOrders(),
                        color: accent,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: orders.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            final items = order.items;
                            final status = order.orderStatus.replaceAll('_', ' ');
                            final paymentMethod = order.paymentMethod;

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: currentTheme.cardColor,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: currentColors.outlineVariant,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.receipt_long_outlined,
                                        color: accent,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Order #${order.orderId}',
                                            maxLines: 1,
                                            style: TextStyle(
                                              color: currentColors.onSurface,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        status.toUpperCase(),
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          color: accent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _formatDate(order.createdAt),
                                    style: TextStyle(
                                      color: currentColors.onSurfaceVariant,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Divider(color: currentColors.outlineVariant),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Items',
                                    style: TextStyle(
                                      color: currentColors.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...items.map<Widget>((item) {
                                    final name = (item['name'] ?? item['product_name'] ?? item['title'] ?? 'Product').toString();
                                    final quantity = item['quantity'] ?? 1;
                                    final size = item['size']?.toString() ?? '';
                                    final color = item['color']?.toString() ?? '';
                                    final variantDesc = [if (size.isNotEmpty) size, if (color.isNotEmpty) color].join(' • ');

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  name,
                                                  style: TextStyle(
                                                    color: currentColors.onSurface,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                if (variantDesc.isNotEmpty)
                                                  Text(
                                                    variantDesc,
                                                    style: TextStyle(
                                                      color: currentColors.onSurfaceVariant,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '× $quantity',
                                            style: TextStyle(
                                              color: currentColors.onSurfaceVariant,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Payment: $paymentMethod',
                                          style: TextStyle(
                                            color: currentColors.onSurfaceVariant,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        _money(order.totalAmount),
                                        style: TextStyle(
                                          color: currentColors.onSurface,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
