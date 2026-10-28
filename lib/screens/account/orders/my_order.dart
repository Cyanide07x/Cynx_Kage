
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../theme/theme_controller.dart';
import '../../../theme/apptheme.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  String _money(dynamic value) {
    final amount = value is num ? value.toDouble() : 0.0;
    return '₹${amount.toStringAsFixed(0)}';
  }

  String formatDate(dynamic value) {
    if (value is! Timestamp) return 'Date unavailable';

    final date = value.toDate();

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
          appBar: AppBar(
            backgroundColor: currentTheme.scaffoldBackgroundColor,
            foregroundColor: currentColors.onSurface,
            elevation: 0,
            title: const Text(
              'My Orders',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: user == null
              ? const Center(
                  child: Text('Please sign in to view your orders.'),
                )
              : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('orders')
                      .where('userId', isEqualTo: user.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Could not load your orders.\n'
                            'Please check your connection and try again.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: currentColors.onSurface,
                            ),
                          ),
                        ),
                      );
                    }

                    if (snapshot.connectionState ==
                            ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: accent,
                        ),
                      );
                    }

                    final orders = snapshot.data?.docs ?? [];

                    if (orders.isEmpty) {
                      return Center(
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
                                'Your orders will appear here '
                                'after you place an order.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: currentColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Newest orders first.
                    final sortedOrders = [...orders]
                      ..sort((a, b) {
                        final aDate = a.data()['createdAt'];
                        final bDate = b.data()['createdAt'];

                        final aMillis = aDate is Timestamp
                            ? aDate.millisecondsSinceEpoch
                            : 0;
                        final bMillis = bDate is Timestamp
                            ? bDate.millisecondsSinceEpoch
                            : 0;

                        return bMillis.compareTo(aMillis);
                      });

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: sortedOrders.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final document = sortedOrders[index];
                        final order = document.data();

                        final items = order['items'] is List
                            ? order['items'] as List
                            : <dynamic>[];

                        final status =
                            (order['orderStatus'] ?? 'placed')
                                .toString()
                                .replaceAll('_', ' ');

                        final paymentMethod =
                            (order['paymentMethod'] ?? 'N/A')
                                .toString();

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
      'Order #${document.id}',
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

                              const SizedBox(height: 14),
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
                                if (item is! Map) {
                                  return const SizedBox.shrink();
                                }

                                final name =
                                    (item['name'] ??
                                            item['title'] ??
                                            'Product')
                                        .toString();

                                final quantity = item['quantity'] ?? 1;

                                return Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          name,
                                          style: TextStyle(
                                            color:
                                                currentColors.onSurface,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '× $quantity',
                                        style: TextStyle(
                                          color: currentColors
                                              .onSurfaceVariant,
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
                                        color: currentColors
                                            .onSurfaceVariant,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _money(order['totalAmount']),
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
                    );
                  },
                ),
        );
      },
    );
  }
}
