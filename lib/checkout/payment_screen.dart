
import 'package:flutter/material.dart';
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
  String _selectedPaymentMethod = 'null';

  static const Color _accentColor = Color(0xFFC5E86C);

  void _confirmSelection() {
    Navigator.pop(context, _selectedPaymentMethod);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
                        color: const Color(0xFF333333),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: _confirmSelection,
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),

                  const Expanded(
                    child: Text(
                      'Payment',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 40),
                ],
              ),
            ),

            // Amount to pay
            const SizedBox(height: 24),

            const Text(
              'Amount to pay',
              style: TextStyle(
                color: Color(0xFF999999),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              '₹${widget.totalAmount.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),

            const SizedBox(height: 36),

            // Payment method heading
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Payment method',
                  style: TextStyle(
                    color: Colors.white,
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
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              decoration: const BoxDecoration(
                color: Color(0xFF0A0A0A),
                border: Border(
                  top: BorderSide(
                    color: Color(0xFF222222),
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
                        color: _accentColor,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _selectedPaymentMethod == 'COD'
                            ? 'Cash on delivery selected'
                            : _selectedPaymentMethod == 'UPI'
                                ? 'UPI selected'
                                : 'Card selected',
                        style: const TextStyle(
                          color: Color(0xFF999999),
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
                        foregroundColor: Colors.white,
                        side: const BorderSide(
                          color: Color(0xFF333333),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Confirm Selection',
                        style: const TextStyle(
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
  }
}
