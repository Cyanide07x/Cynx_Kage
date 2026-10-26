
import 'package:flutter/material.dart';
import 'package:cynx_cage/theme/theme_controller.dart';
import 'package:cynx_cage/theme/apptheme.dart';

import 'payment_method_card.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;

  const PaymentScreen({
    super.key,
    required this.totalAmount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _selectedPaymentMethod;

  void _confirmSelection() {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method.'),
        ),
      );
      return;
    }

    Navigator.pop(context, _selectedPaymentMethod);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;

        final isCynx =
            themeController.selectedTheme == CynxThemeMode.cynx;

        final accent = isCynx
            ? const Color(0xFFE50046)
            : const Color(0xFFBBD58E);

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: colors.outlineVariant,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () =>
                              Navigator.of(context).maybePop(),
                          icon: Icon(
                            Icons.arrow_back,
                            color: colors.onSurface,
                            size: 18,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Payment',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Amount
                Text(
                  'Amount to pay',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '₹${widget.totalAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),

                const SizedBox(height: 36),

                // Payment method heading
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Payment method',
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // UPI
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: PaymentMethodCard(
                    icon: Icons.phone_iphone_outlined,
                    title: 'UPI',
                    subtitle: 'Google Pay, PhonePe, Paytm',
                    isSelected: _selectedPaymentMethod == 'UPI',
                    onTap: () {
                      setState(() {
                        _selectedPaymentMethod = 'UPI';
                      });
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Credit / Debit card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: PaymentMethodCard(
                    icon: Icons.credit_card_outlined,
                    title: 'Credit / Debit card',
                    subtitle: 'Visa, Mastercard, RuPay',
                    isSelected: _selectedPaymentMethod == 'CARD',
                    onTap: () {
                      setState(() {
                        _selectedPaymentMethod = 'CARD';
                      });
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Cash on delivery
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: PaymentMethodCard(
                    icon: Icons.payments_outlined,
                    title: 'Cash on delivery',
                    subtitle: 'Pay when it arrives',
                    isSelected: _selectedPaymentMethod == 'COD',
                    onTap: () {
                      setState(() {
                        _selectedPaymentMethod = 'COD';
                      });
                    },
                  ),
                ),

                const Spacer(),

                // Bottom confirmation area
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    20, 14, 20, 16,
                  ),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    border: Border(
                      top: BorderSide(
                        color: colors.outlineVariant,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selectedPaymentMethod == 'COD'
                                ? Icons.payments_outlined
                                : Icons.lock_outline,
                            color: accent,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _selectedPaymentMethod == null
                                ? 'Choose a payment method'
                                : _selectedPaymentMethod == 'COD'
                                    ? 'Cash on delivery selected'
                                    : _selectedPaymentMethod == 'UPI'
                                        ? 'UPI selected'
                                        : 'Card selected',
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: _confirmSelection,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: accent,
                            side: BorderSide(color: accent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Confirm Selection',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
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
